function do_tapad_rtmon(chanlist,igo,istep)
% DO_TAPAD_RTMON run tapad online during experiment
% function do_tapad_rtmon(chanlist,igo,istep)
% do_tapad_rtmon: Version 18.8.07
%
%   Description
%       reads path to input amps and output position from rtmon_cfg
%       whenever the path changes the list of completed trials is reset
%       thus there should be no need to restart the program for different parts of
%       a session stored in different subdirectories
%       currently beststartl (and rawpos (and rawpos\posamps)) is added to the output path
%       This version now linux-compatible
%       rtmon_cfg must contain a variable 'maxtrial'. do_tapad_rtmon always
%       processes the most recent available trial as given by maxtrial.
%       The program terminates when maxtrial is set to zero.
%       rtmon_cfg can contain a variable 'startpos'. If present, this is
%       used for the start positions.
%       rtmon_cfg should also contain a variable 'chanlist'. This takes
%       precedence over the input argument (so normally set chanlist to empty when calling do_tapad_rtmon) 

ndig=4;

basepath=pwd;

%tapad options. currently hardwired. But can be overridden by including a
%variable with this name in rtmon_cfg
myoptions='-l';

lastpath='';


%pause duration in seconds when waiting for rtmon_cfg to be created, or for
%new trial to calculate (reduces CPU load in while loops when program has nothing to do, see below)
wait4cfg=2;
wait4trial=2;


finished=0;

while ~finished
    %try and read cfg file
    cfgread=0;
    while ~cfgread
        if exist(['rtmon_cfg.mat'],'file')
            cfgread=1;
        else
            
            clc
            disp('Waiting for cfg file');
            pause(wait4cfg);
        end;
    end;
    cfgread=0;
    maxtrial=[];
    startpos=[];
    tapadpath=[];
    
    %cfg file must contain maxtrial
    while ~cfgread
        try
            load('rtmon_cfg');
            if isempty(maxtrial)
                clc
                disp('cfg file not valid?');
                pause(wait4cfg);
            else
                cfgread=1;
            end;
        catch
            clc
            disp('Unable to load cfg file?');
            pause(wait4cfg);
        end;
    end;
    
    warning off
    
    firstpath=tapadpath;
    
    %make linux compatible, as path probably set up by docopyds under windows
    firstpath=strrep(firstpath,'\',pathchar);
    
    if maxtrial<=0 finished=1; end;
    
    outpath=[firstpath pathchar 'beststartl' pathchar 'rawpos'];
    
    %this creates both rawpos\ and \rawpos\posamps
    %normally it doesn't seem to matter if you try and create a directory
    %when it already exists, but in practice the program has sometimes
    %crashed here
    if ~exist(outpath,'dir')
        mkdir([outpath pathchar 'posamps']);
    end;
    
    if ~strcmp(firstpath,lastpath)
        donelist=[];
        
        dirlist=dir([outpath pathchar '*.mat']);
        %       keyboard;
        nf=length(dirlist);
        
        if nf>0
            
            dirc=cell(nf,1);
            [dirc{:}]=deal(dirlist.name);
            dirc=char(dirc);
            
            %this only works if filename consists exclusively of digits!!
            tnum=str2num(dirc(:,1:ndig));
            disp('already done');
            donelist=tnum';
            disp(tnum);
            %            keyboard;
            %only keep those that could be in the todo list 
            donelist=intersect(donelist,igo:istep:maxtrial);
        end;
        
    end;
    
    lastpath=firstpath;
    
    warning on;
    
    trial2do=[];
    if maxtrial>0
        todolist=igo:istep:maxtrial;
        trial2do=max(setxor(donelist,todolist));
    end;
    
    
    if ~isempty(trial2do)
        %without startpos
        if isempty(startpos)
            stats=tapad_ph_rs(basepath,[firstpath pathchar 'amps'],outpath,trial2do,chanlist,myoptions);
        else
            %with startpos
            stats=tapad_ph_rs(basepath,[firstpath pathchar 'amps'],outpath,trial2do,chanlist,myoptions,startpos);
            
        end;
        
        donelist=[donelist trial2do];
        
    else
        clc;
        disp('Waiting for trial to process');
        pause(wait4trial);
        
    end;        %trial2do not empty
    
end;        %not finished
