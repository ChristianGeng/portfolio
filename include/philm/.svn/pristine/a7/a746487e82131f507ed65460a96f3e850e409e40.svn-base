function prompter_agusersetfunc
%prompter_agusersetfunc
%run ag500 using prompter_parallel_main with userset/start/stopfunc
% could useragsetfunc also be useful?

prompter_iniag500fig;

%Check tcpip connection is working
timeout0=prompter_getemaall;
disp('Check AG500 positions and amplitudes are plausible. Type return to continue');
keyboard;
irun=prompter_gagd('sweep');

prompter_smaind('irun',irun);

