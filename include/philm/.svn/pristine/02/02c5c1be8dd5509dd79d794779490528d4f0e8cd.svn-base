function docopyds(agpath,localpath,triallist,ftpobj);
% DOCOPYDS Copy and downsample AG500 data for online processing
% function docopyds(agpath,localpath,triallist,ftpobj);
% docopyds: Version 23.7.08
%
%   Description
%       This function will usually be run once before starting
%       do_showtrial_rtmon, and then at various intervals during the
%       session from keyboard mode within do_showtrial_rtmon
%       This function must be edited for each new experimental session
%       in order to set up the sensornames, the filterspecs, and, if
%       possible a rough idea of the expected start position and
%       orientations (in practice a rough idea of the latter is probably
%       sufficient)
%       In addition, chanlist (list of channels to be processed by
%       do_tapad_rtmon) must be set up. (Can save quite a bit of time in
%       online processing if unused/defect sensors are excluded)
%       2.08: This version calls showpegelstats after using filteramps
%
%   Input arguments
%       agpath: Windows: Specify with final backslash (normally .......amps\)
%           e.g agpath='U:\ag500data\dfgberlin\lz\lzema1\lzema1palpert\amps\';
%           For linux system should simply be the base name of the subdirectory(ies) with
%           the experimental data of the current session), without any pathchar at end (if required as
%           part of the path use '/'), but usually starting with '/data/' 
%       localpath: Windows: Specify with final backslash (subdirectory where amps and e.g ampsfiltds will be created)
%           e.g 'lzema1palpert\'
%           For linux system should be the name of the subdirectory on the control server containing
%           the amp directory with the data to be transferred (without final
%           pathchar). This subdirectory is created below pwd on the local
%           machine
%       triallist: list of trials to transfer from machine running mc5recorder
%       Example of paths for linux:
%           first call to docopyds:
%               set agpath to '/data/dfgspp/lb'
%               set localpath to 'cluster'
%               this assumes the existence of
%               /srv/ftp/data/dfgspp/lb/cluster/amps
%               on the control server, and will result in the creation of
%               cluster/amps below the working directory on the local
%               machine
%           second call 
%               agpath can be empty (means the function can skip an
%               unnecessary cd)
%               local path determines whether data continues to be put in
%               'cluster/amps' (i.e still specified as 'cluster')
%               or e.g in 'prosody/amps' by specifying 'prosody' (but still below 'data/dfgspp/lb')
%           If there is an error message associated with the use of
%           mget,then  use the ftp versions of dir or cd (see matlab documentaion) to check that ftp
%           access to the control server is working as intended
%   See Also
%       DO_TAPAD_RTMON
%       DO_SHOWTRIAL_RTMON

FTP=[];
if nargin>3 FTP=ftpobj; end;


if ~isempty(FTP)
    if ~isempty(agpath)
disp('Changing ftp path');
    cd(FTP,[agpath])
end;
end;


maxchan=12;
usersensornames=str2mat('t_back','t_mid','t_tip','ref','jaw','nose','upper_lip','lower_lip','head_left','head_right','occapex','occbase');
%
%channels to actually be processed by do_tapad_rtmon
chanlist=[1:4];

P=desc2struct(usersensornames);

%this will happen if parameter names are ambiguous
if isempty(P) return; end;

%set up filtering

list1=[P.t_back P.t_mid P.lower_lip P.upper_lip P.jaw ];
list2=[P.ref P.nose P.head_left P.head_right P.occapex P.occbase];
list3=[P.t_tip];
ll=[list1 list2 list3];
if length(ll)~=length(unique(ll))
    disp('Filter lists probably wrong!');
    keyboard;
    return;
end;

filterspecs=cell(2,2);
filterspecs{1,1}='fir_20_30';
filterspecs{1,2}=list1;
filterspecs{2,1}='fir_05_15';
filterspecs{2,2}=list2;
filterspecs{3,1}='fir_40_50';
filterspecs{3,2}=list3;

%set up start positions
%orientation as phi/theta. This may change!!
dostart=1;
if dostart
    startpos=zeros(maxchan,5);
 
%orientations for nose, lips and head should not normally change
    startpos(P.nose,4:5)=[90 0];
    startpos(P.lower_lip,4:5)=[90 0];
    startpos(P.upper_lip,4:5)=[-90 0];

    startpos(P.head_left,4:5)=[180 0];
    startpos(P.head_right,4:5)=[0 0];
    
%tongue depends on whether maximum 3D or safe 2D approach
    
    startpos(P.t_back,4:5)=[180 -30];
    startpos(P.t_mid,4:5)=[180 0];

    %tongue 2D like upper lip -90 0
    %lead points back into mouth
    startpos(P.t_tip,4:5)=[-90 0];
%tongue tip normal 3D
    %    startpos(P.t_tip,4:5)=[180 45];

%ref and jaw are the sensors most likely to need changing at short notice
    %startpos(P.ref,4:5)=[90 0];         %lead down
    startpos(P.ref,4:5)=[-90 0];         %lead up
    startpos(P.jaw,4:5)=[-90 0];        %lead up
%    startpos(P.jaw,4:5)=[90 0];        %lead down
    
    %estimate x/y/z if desired, but should be less crucial than orientation
end;



ndig=4;
dodown=1;
mysuff='';
idownfac=1;
usercomment='Filter complete data for input to amp adjustment';

if dodown
    mysuff='ds';
    idownfac=8;
    usercomment='Filter and downsample data';
end;

mypart=localpath;
if mypart(end)~=pathchar
    mypart=[mypart pathchar];
end;
inpath=[mypart 'amps' pathchar];
outpath=[mypart 'ampsfilt' mysuff pathchar 'amps' pathchar];
tapadpath=[mypart 'ampsfilt' mysuff];

%this is used by do_tapad_rtmon, but is best to create here, as there have
%been access problems if it is created by a linux machine running
%do_tapad_rtmon
tapadpathall=[mypart 'ampsfilt' mysuff pathchar 'beststartl' pathchar 'rawpos' pathchar 'posamps'];

% doesn't matter if  path already set up
mkdir(outpath);
mkdir(inpath);
mkdir(tapadpathall);

%copy from ag500 machine

disp('copying');

for ii=triallist
    disp(ii);
    %comment out next line to downsample without copying
    if isempty(FTP)
    copyfile([agpath int2str0(ii,ndig) '.amp'],[inpath int2str0(ii,ndig) '.*']);
    else
        mgetresult=mget(FTP,[localpath '/amps/' int2str0(ii,ndig) '.*']);
        disp(mgetresult);
        if isempty(mgetresult)
            disp('mget: nothing copied?');
        end;
        
    end;
    
    end;




pegelstats=filteramps(inpath,outpath,triallist,filterspecs,idownfac,usersensornames,usercomment);
plotpegelstats(pegelstats,triallist,chanlist);

maxtrial=max(triallist);

%make sure maxtrial greater than any existing value???
%currently assume trials are copied consecutively

%startpos is only stored if rtmon_cfg does not yet exist, since it will
%probably be updated later using statistics from do_showtrial_rtmon

%similar procedure for chanlist

if exist('rtmon_cfg.mat','file')
    save('rtmon_cfg','maxtrial','tapadpath','-append');
else
    if exist('startpos','var')
                save('rtmon_cfg','maxtrial','tapadpath','chanlist','startpos');
    
    else
            save('rtmon_cfg','maxtrial','tapadpath','chanlist');

    end;
    
end;


disp('files filtered and downsampled');
