function timeoutsweep=prompter_wait4agsweep
% function timeoutsweep=prompter_wait4agsweep

timeoutsweep=0;
AG=prompter_gagd;
A=AG.Alines;

%if sybox is not in use and triggering is tcpip
%then prompter_startag will already have waited for the active flag
% in the tcpip data stream, so there is no point in testing again here
if ~AG.usesybox
    return;
end;



%wait for actual sweep active
%check not already triggered
agstat=prompter_parallelinctl('readlines');

triggered=~agstat(A.sweep);
if triggered
    %output to log file
    if ~isempty(AG.attn2sweeptooslow_msg)
        prompter_writelogfile([AG.attn2sweeptooslow_msg crlf]);
    end;
    
    
else
    disp('waiting for sweep');
    
end;

%8.10 not clear how this timeout can occur, if attention has been correctly
%detected, but it does seem to have happened
tic;
while ~triggered & ~timeoutsweep
    agstat=prompter_parallelinctl('readlines');
    triggered=~agstat(A.sweep);
    tcheck=toc;
    timeoutsweep=tcheck>AG.sweep_timeout;
end;
if timeoutsweep
    prompter_dotrafficlights('stop');
    prompter_writelogfile(['!!Timed out waiting for sweep !!' crlf]);
    disp('Type return to continue');
    keyboard;
    prompter_resetagstatus;
end;

    
