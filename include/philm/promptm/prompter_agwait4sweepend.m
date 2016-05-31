function mytoc=prompter_agwait4sweepend
% function mytoc=prompter_agwait4sweepend

AG=prompter_gagd;
mantrig=strcmp(AG.agtriggermode,'manual');

if ~AG.usesybox
    if ~mantrig
        quietflag=1;
        stillactive=1;
        disp('Waiting for AG inactive (TCPIP)');
        while stillactive
            pause(0.05);
            timeout=prompter_getemaall(quietflag);
            stillactive=prompter_gagd('active');
            if timeout stillactive=0; end;
        end;
        
        mytoc=now;  %not very meaningful
    end;        %man trig
else
    
    
    
    
    A=AG.Alines;
    
    triggeredcb=1;
    while triggeredcb
        pause(0.05);
        AG=prompter_gagd;
        tmpstat=AG.statbuf;
        agstat=tmpstat(1,:);
        triggeredcb=all(~agstat([A.sweep A.trans]));
    end;
    
    mytoc=now;
    
    if agstat(A.trans)
        prompter_writelogfile(['!!Trial stopped by transmitter problem??' crlf]);
        disp('Wait for transmitters to be active before continuing');
        keyboard;
    end;
    
    
    
    prompter_resetagstatus;
end;