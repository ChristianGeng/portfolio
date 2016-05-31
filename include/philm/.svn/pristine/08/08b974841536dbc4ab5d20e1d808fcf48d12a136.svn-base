function prompter_repeat(mycmd);
% function prompter_repeat(mycmd);

P=prompter_gmaind;

if isempty(P.laststim)
    disp('Repeat not possible before first stimulus');
    return;
end;

S=prompter_gstimd;

ps=S.ps;
cs=S.cs;

disp('Repeating!!');
P.repeatstr=P.repeat4log;
P.logtext_trial=[P.logtext_trial P.rubbish4log];
if P.stimfromstack
    stimstack=P.stimstack;
    stimstack=stimstack(:);
    P.stimstack=[P.istim;stimstack];
end;
P.istim=P.laststim;
if mycmd=='R'
    irun=P.irun;
    
    irun=irun-1;
    disp('Re-using previous trial number');
    P.logtext_sup=[P.logtext_sup '<Re-using previous trial number>' crlf];
    P.irun=irun;
end;
prompter_showmsg(P.repeatmsg);

disp('hit any key to continue');
pause
prompter_showg(ps{P.istim});
prompter_dotrafficlights('stop');
prompter_showstim2investigator(P.istim);            
prompter_smaind(P);
