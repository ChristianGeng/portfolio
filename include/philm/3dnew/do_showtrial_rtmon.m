function do_showtrial_rtmon(localpath,chanlist,finalpath,tanflag)
% DO_SHOWTRIAL_RTMON Online display of position data
% function do_showtrial_rtmon(localpath,chanlist,finalpath,tanflag)
% do_showtrial_rtmon: Version 15.11.2012
%
%   Syntax
%       localpath: should be same as used for docopyds (i.e normally
%			terminated with backslash)
%		chanlist: List of channels to display (no defaults)
%		finalpath: Optional. Defaults to 'ampsfiltds/beststartl/rawpos/'
%			Position data must be in [localpath finalpath]
%		tanflag: Optional. Defaults to 1 (true)
%			Determines whether tangential velocity (if true) or 'parameter7' is shown (if false)
%			For tapad set to true.
%			For kalman setting to false is normally recommended. The
%			corresponding panels in the figures should be labelled
%			'fbdist'. For Kalman this normally provides a much better
%			indication of possibly dodgy data than the tangential velocity.
%			Note: This setting also affects the statistics available with
%			showstats (in modes 4, 6, and 8)
%
%	Description
%       Designed to be used in parallel with other instances of matlab that
%       are performing the position calculations as data becomes available.
%       If the user clicks in the first figure then the program jumps into
%       keyboard modus, giving the user the possibility to copy more raw
%       data from the machine running cs5recorder, or for example to
%       calculate start positions using statistics returned by show_trialox
%		(use the auxiliary function SHOWSTATS)
%
%   Updates
%       24.7.08: uses show_trialox
%               global ftpobj added, so that docopyds for linux can be
%               called 
%		16.3.09: Add input argument finalpath
%		09.2010: Add input argument tanflag
%       11.2012: Filter out filenames not consisting of digits
%
%   See Also SHOW_TRIALOX, DOCOPYDS, MAKESTART4RTMON, DO_TAPAD_RTMON,
%   CONNECT2CS, SHOWSTATS, SHOWTRIAL_RANGESET, DO_KALMAN_RTMON

global ftpobj

tmpstr=strrep('ampsfiltds\beststartl\rawpos\','\',pathchar);
if nargin>2 
	if ~isempty(finalpath)
	tmpstr=finalpath; 
	end;
end;

pospath=[localpath tmpstr];


dotan=1;
if nargin>3 dotan=tanflag; end;


plotstep=1;



donelist=[];
ndig=4;

%chanlist=7:8;
finished=0;

firstcall=1;

wait4trial=5; %length of pause in seconds

hf=[];
while ~finished

    dataready=0;
    while ~dataready
        dirlist=dir([pospath '*.mat']);
        nf=length(dirlist);

        if nf>0
            dataready=1;
        else
            clc
            disp('waiting for pos files');
            pause(wait4trial);
        end;

    end;

    dirc=cell(nf,1);
    [dirc{:}]=deal(dirlist.name);
    dirc=char(dirc);
    dirc=dirc(:,1:ndig);

    %show_trialox now stores a stats file in the folder with the pos files
    %assume this is sufficient to filter out any files where the filename
    %does not consist of digits
    vv=find(ismember(dirc(:,1),'0123456789'));
    dirc=dirc(vv,:);

    %this only works if filename consists exclusively of digits!!
    tnum=str2num(dirc(:,1:ndig));

    %   maxtrial=max(tnum);

    %    todolist=1:maxtrial;
    todolist=tnum';

    trial2do=setxor(donelist,todolist);


    if ~isempty(trial2do)
		if firstcall trial2do=trial2do(end); end;
        [statx,statsd,nancnt,hf]=show_trialox(pospath,trial2do,chanlist,hf,plotstep,dotan);
        donelist=[donelist trial2do];
        disp(['displaying ' int2str(trial2do)]);
		if firstcall
			disp('Arrange figures, if desired');
			keyboard;
			firstcall=0;
		end;
	else
        clc

        keyflag=0;
        try
            userdata=get(hf(1),'userdata');
            keyflag=userdata.userflag;
        catch
            disp('Problem getting user data from first figure; check hf(1)');
            keyboard;
        end;

        if keyflag
            disp('Examples of useful commands in keyboard mode:');
            disp('');
            disp('To copy more trials:');
            disp('docopyds(agpath,localpath,triallist)');
            disp('');
            disp('Statistics and start position calculation with showstats:');
            help showstats;
            
            
            
            keyboard;

            userdata.userflag=0;
            set(hf(1),'userdata',userdata);
            drawnow;

        else
            disp(['Waiting for more data ']);
            pause(wait4trial);
        end;
        %        keyboard;
    end;

end;
