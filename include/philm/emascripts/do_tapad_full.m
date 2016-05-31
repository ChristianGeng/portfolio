function do_tapad_full(igo,istep,iend)

basepath=pwd;

chanlist=[1:12];
%triallist=igo:istep:2;
triallist=igo:istep:iend;
restlist=[];

triallist=setxor(triallist,restlist);
myoptions='-l-r';
% subject='ss1';
% corpus='prosody';
% mypart=[subject '_' corpus filesep];
firstpath=['ampsfiltadja'];

%first full version
% outpath=[firstpath filesep 'recursedsl' filesep 'rawpos'];
% startpath=[basepath filesep 'ampsfiltdsadja' filesep 'beststartl' filesep 'rawpos'];

%second full version (for comparison with smoothed full version)
outpath=[firstpath filesep 'recursevelrepl' filesep 'rawpos'];
startpath=[firstpath filesep 'velrep' filesep 'rawpos'];

mkdir([outpath filesep 'posamps']);

stats=tapad_ph_rs(basepath,[firstpath filesep 'amps'],outpath,triallist,chanlist,myoptions,startpath);

disp(stats);

