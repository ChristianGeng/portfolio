function prompter_settrialnumber
% function prompter_settrialnumber
%
%   Description
%       manual adjustment of trial number
%       Should not normally be needed; most likely only when using manual
%       triggering for AG500 and a discrepancey between prompt program and control
%       server has occurred

[abint,abnoint,abscalar,abnoscalar]=abartdef;

AG=prompter_gagd;
if isfield(AG,'agtriggermode')
    if strcmp(AG.agtriggermode,'tcpip')
        disp('Trial number is controlled by tcpip connection from control server');
        disp('No change possible here');
        return;
    end;
end;

P=prompter_gmaind;
irunold=P.irun;
disp('Enter new trial number; default is no change');
irun=abart('New trial number',irunold,1,9999,abint,abscalar);
P.irun=irun;
P.logtext_sup=[P.logtext_sup '<Trial number changed to ' num2str(irun) '>' crlf];

%insert dummy trials if gap from current setting
%comparable case when using tcpip for AG control is in
%prompter_checkagready4next
if irunold<(irun-1)
    
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
end;


prompter_smaind(P);
