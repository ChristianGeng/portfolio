%load startpos_allds;

chanlist=[1:10];        %channel 11/12 not used (11 for palate)
%triallist=1:252;        %cv1
triallist=[244:252];        %cv1
%triallist=[100:150];        %cv1
mypath='S:\2005\mca2\cv1';

startpath=[mypath '\ampsadj\merge\rawpos'];
myoptions='-r';
%stats=tapad_ph(pwd,'ampsfiltds\amps','ampsfiltds\rawpos',triallist,chanlist,myoptions);
stats=tapad_ph(mypath,'ampsadj\amps','ampsadj\recursive\rawpos',triallist,chanlist,myoptions,startpath);

disp(stats);
