function prompter_msg2sub(mycmd);

P=prompter_gmaind;

ht=P.texthandle;
set(ht,'visible','off');
mymess=philinp('Enter message to subject ');
mymess=rv2strm(mymess,crlf);
prompter_showmsg(mymess);
set(ht,'visible','on','edgecolor','m');

if mycmd=='m'; 
    disp('Use M command to continue');
    P.ok2rec=0;   %disable next command
    prompter_smaind(P);           
    return; 
end;
%M command, re-enable next command
S=prompter_gstimd;
ps=S.ps;
istim=P.istim;
disp('hit any key to continue');
pause
prompter_showg(ps{istim});
prompter_dotrafficlights('stop');

prompter_showstim2investigator(istim);
P.ok2rec=1;
prompter_smaind(P);           
