function tcptimeout=prompter_checkagready4next
% PROMPTER_CHECKAGREADY4NEXT Make sure AG500/1 is in expected state when 'next' command is issued
% function tcptimeout=prompter_checkagready4next
% prompter_agready4next: Version 28.11.2012

tcptimeout=0;
getemaquiet=1;      %could be configurable
P=prompter_gmaind;
AG=prompter_gagd;

mantrig=strcmp(AG.agtriggermode,'manual');
if ~AG.usesybox
    if ~mantrig
        
        timeout=prompter_getemaall(getemaquiet);
        if timeout
            tcptimeout=1;
            return;
        end;
        
        %also check not already active??
        %i.e trial number is only definitive after sorting out any potential
        %problems before togglestatus
        
        alreadyactive=prompter_gagd('active');
        
        if alreadyactive
            prompter_writelogfile(['!!Sweep already running; check trialnumbers are consecutive !!' crlf]);
            %timeout not necessary, if all sorted out
            %					timeoutflag=1;
            togglestatus;
            disp('Stop AG500 by hand if necessary before typing return');
            keyboard;
            %check sweep has not been missed completely
        end;
    end;        %not mantrig
    
else
    
    
    
    statbuf=AG.statbuf;
    A=AG.Alines;
    
    %check not already triggered
    agstat=statbuf(1,:);
    chstat=statbuf(2,:);
    %alternative
    %agstat=prompter_parallelinctl('readlines');
    
    %                triggered=any(~agstat([A.sweep A.attn]));
    triggered=any(~agstat([A.sweep]));
    if triggered
        prompter_writelogfile(['!!Sweep already running; check trialnumbers are consecutive !!' crlf]);
        %timeout not necessary, if all sorted out
        %					timeoutflag=1;
        if ~mantrig
            togglestatus;
        end;
        
        disp('Stop AG500 by hand if necessary before typing return');
        keyboard;
        %check sweep has not been missed completely
    else
        
        if chstat(A.sweep)
            prompter_writelogfile(['!!agmaster sweep without prompt !!check trialnumbers are consecutive' crlf]);
            disp('Type return to continue');
            keyboard;
            
        end;
        
        
    end;
    
    
    %transmitter is running, but status has changed, so there has probably been
    %a resynch
    if chstat(A.trans) & ~agstat(A.trans)
        prompter_writelogfile(['!!Probable transmitter resynch detetected !!' crlf]);
        disp('Type return to continue');
        keyboard;
    end;
    
end;    %usesybox

if mantrig
    return;
end;

timeout=prompter_getemaall(getemaquiet);
if timeout
    tcptimeout=1;
    return;
end;


%if using tcpip, current trial number will now be set from AG data stream

%also check not already active??
%i.e trial number is only definitive after sorting out any potential
%problems before togglestatus

AG=prompter_gagd;

irun=AG.sweep;
irunold=P.irun;
P.irun=irun;
%copied from old t command

%irun/irunold should never be empty??
if ~isempty(irunold)
    
    if irunold<(irun-1)
%At start of stimulis list this condition just indicates that AG trial
%number was not reset to 1 at start of experiment
        if P.istim>1        
            prompter_writelogfile(['!!Dummy trials inserted!!' crlf]);
            
            mytime=now;
            [dodo,mytime]=strtok(datestr(mytime));
            for itmp=irunold:(irun-1)
                sx=[int2str(itmp) ' 0 ' mytime ' 0 [!!No prompt (no video timer)!!]' crlf];
                prompter_writelogfile(sx);
                
            end;
            prompter_writelogfile(['!!End of dummy trials!!' crlf]);
            disp('Type return to continue');
            keyboard;
        else
            prompter_writelogfile(['!!Unexpected trial number for first stimulus!!' crlf]);
            disp('Type return to continue');
            keyboard;
        end;
        
    end;
end;

prompter_smaind(P);