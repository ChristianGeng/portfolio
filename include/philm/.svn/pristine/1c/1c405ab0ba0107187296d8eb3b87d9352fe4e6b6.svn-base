function prompter_agstop
% function prompter_agstop

AG=prompter_gagd;

mantrig=strcmp(AG.agtriggermode,'manual');

if ~AG.usesybox
    if ~mantrig
        quietflag=1;
        timeout=prompter_getemaall(quietflag);
        AG=prompter_gagd;
        if AG.active
            try
                togglestatus;
                %                togglestatus_noconnect(s);
            catch
                prompter_writelogfile(['prompter_agstop: Error with togglestatus?' crlf]);
                disp(lasterr);
                disp('Stop recording by hand, if still running');
                keyboard;
            end;
        end;
    end;        %not man trigger    
else
    
    
    A=AG.Alines;
    statbuf=AG.statbuf;
    agstat=statbuf(1,:);
    
    %Only do togglestatus if AG500 not already stopped
    
    if ~agstat(A.sweep)
        if mantrig
            disp('Stop AG on control server');
            return;
        end;
        try
            togglestatus;
            %                togglestatus_noconnect(s);
        catch
            prompter_writelogfile(['prompter_agstop: Error with togglestatus?' crlf]);
            disp(lasterr);
            disp('Stop recording by hand, if still running');
            keyboard;
        end;
    end;
    
    
end;
