function timeoutflag=prompter_startag
% function timeoutflag=prompter_startag
% Start AG500 via TCPIP connection and wait for attention signal

AG=prompter_gagd;

mantrig=strcmp(AG.agtriggermode,'manual');

%remote start AG500 recording
if ~mantrig
    try
        togglestatus;
    catch
        prompter_writelogfile(['prompter_startag: Error with togglestatus?' crlf]);
        disp(lasterr);
        disp('Type return, then start recording by hand');
        keyboard;
    end;
else
    disp(['Start AG by hand within ' int2str(AG.attn_timeout) ' s']);
end;


if ~AG.usesybox
    if ~mantrig
        timeoutflag=0;
        triggered=0;
        disp('waiting for AG active (TCPIP)');
        quietflag=1;
        while ~triggered & ~timeoutflag
            pause(0.1);
            timeoutflag=prompter_getemaall(quietflag);
            triggered=prompter_gagd('active');
        end;
        
        if timeoutflag
            
            %should reset autonext here!!! tell user to use a
            %command to resume autonext
            prompter_dotrafficlights('stop');
            
            prompter_writelogfile(['!!Timed out waiting for tcpip active !!' crlf]);
            disp('Type return to continue');
            keyboard;
        end;
    end;        %not mantrig
    
else
    timeoutflag=0;
    
    triggered=0;
    attn=0;
    disp('waiting for attention');
    
    A=AG.Alines;
    
    tic;
    
    
    %could also use this to break out while waiting for attention
    %(regardless of whether autonext is active or not)
    %i.e treat like time-out (except output a different message)
    %        autochk=get(hfinv,'userdata');
    %        if autonext
    %            if autochk
    %                autonext=0;
    %                set(hfinv,'userdata',0);
    %            end;
    %        end;
    
    
    
    while ~attn & ~timeoutflag
        agstat=prompter_parallelinctl('readlines');
        attn=~agstat(A.attn);
        tcheck=toc;
        timeoutflag=(tcheck>AG.attn_timeout) | agstat(A.trans);
        
    end;
    
    if timeoutflag
        
        %should reset autonext here!!! tell user to use a command to resume autonext
        prompter_dotrafficlights('stop');
        prompter_writelogfile(['!!Timed out waiting for attention !!' crlf]);
        if agstat(A.trans)
            prompter_writelogfile(['!!Transmitter not running while waiting for attention !!' crlf]);
        end;
        disp('Type return to continue');
        disp('If time-out caused by transmitter resynch, check transmitter status before continuing!!');
        keyboard;
        prompter_resetagstatus;
    end;
end;
