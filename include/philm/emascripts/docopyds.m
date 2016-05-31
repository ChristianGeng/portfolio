function docopyds(agpath,localpath,triallist);
% DOCOPYDS Copy and downsample AG500 data for online processing
% function docopyds(agpath,localpath,triallist);
% docopyds: Version 11.5.07
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
%
%   Input arguments
%       agpath: Specify with final backslash (normally .......amps\)
%           e.g agpath='U:\ag500data\dfgberlin\lz\lzema1\lzema1palpert\amps\';
%       localpath: Specify with final backslash (subdirectory where amps and e.g ampsfiltds will be created)
%           e.g 'lzema1palpert\'
%       triallist: list of trials to transfer from machine running mc5recorder
%
%   See Also
%       DO_TAPAD_RTMON
%       DO_SHOWTRIAL_RTMON



maxchan=12;
usersensornames=str2mat('t_back','t_mid','t_tip','ref','jaw','nose','upper_lip','lower_lip','head_left','head_right','occapex','occbase');
%
%channels to actually be processed by do_tapad_rtmon
chanlist=[1:10];

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
    startpos(P.t_tip,4:5)=[-90 0];
%tongue tip normal 3D
    %    startpos(P.t_tip,4:5)=[180 45];

%ref and jaw are the sensors most likely to need changing at short notice
%    startpos(P.ref,4:5)=[90 0];         %lead down
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
    copyfile([agpath int2str0(ii,ndig) '.amp'],[inpath int2str0(ii,ndig) '.amp']);
end;




filteramps(inpath,outpath,triallist,filterspecs,idownfac,usersensornames,usercomment);

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
