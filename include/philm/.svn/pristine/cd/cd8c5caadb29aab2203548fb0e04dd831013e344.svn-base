% do_do_comppos.m MATLAB-Script to 
%
%           see  tapad_ph_rs

warning('off','MATLAB:dispatcher:InexactMatch'); % switch off warnigs concerning case-sensitive OS  
clear variables; 

%--------------------------------------------------------------------
% Comment the next line, if this is the first run of do_tapad_ds
% and there are no start values available. For any other case uncomment it!
use_startpos = true;							% 

% Edit lists of channels
chanlist=[1:10];

% Edit list of trials, eventually skip 'rest' and 'head' trials 
triallist=3:229;

% Copy sensor names to next line for documentation purpose
% ('t_back','t_mid','t_tip','ref','jaw','nose','lower_lip','upper_lip','maxill_left','maxill_right','occapex','occbase');
% Define which sensor should be considered as reference for the distances
compsensor = 6;       % nose

%--------------------------------------------------------------------

basepath = pwd;
basepath = fullfile(basepath, 'ampsfiltds', 'beststartl', 'rawpos');
basepath=[basepath pathchar];
%basepath=['ampsfiltadja\recursedsl\rawpos\'];
%basepath=['ampsfiltadja\recursevelrepl\rawpos\'];
altpath='';
%altpath=['ampsfiltadja\velrep\rawpos\'];
%compsensor=[];
compsensor=6;       %nose
autoflag=1; % durchlaufen
diaryfile='comppos_stats_dsbeststartl2nose.txt';
%diaryfile='comppos_stats_adjvelrep.txt';
%diaryfile='';

doshowtrial=0;


%outpath=[firstpath pathchar 'recursevelrepl' pathchar 'rawpos'];
%startpath=[basepath pathchar 'ampsfiltadja' pathchar 'velrep' pathchar 'rawpos'];


%triallist=setxor(triallist,restlist);



if ~doshowtrial
    %chanlist=[1];

    do_comppos_a_f(basepath,altpath,triallist,chanlist,compsensor,autoflag,diaryfile);

else
    %chanlist=[5 10 11];

    hf=[];
    [statxb,statsdb,nancntb,hf]=show_trialo(basepath,triallist(1),chanlist,hf);
    disp('position figures, then type return');
    keyboard;

    [statxb,statsdb,nancntb,hf]=show_trialo(basepath,triallist,chanlist,hf);


end;
