function prompter_gotostim
% function prompter_gotostim

P=prompter_gmaind;
[abint,abnoint,abscalar,abnoscalar]=abartdef;

S=prompter_gstimd;
ps=S.ps;
cs=S.cs;

stackinuse=0;
if P.stimfromstack stackinuse=1; end;

if P.stimfromstack
    stimstack=P.stimstack;
    stimstack=stimstack(:);
    P.stimstack=[P.istim;stimstack];
end;

P.stimfromstack=0;
if stackinuse
    disp('Note: stack is in use. Will return to using stack after stimulus chosen here');
end;

oldstim=P.istim;
istim=abart('New stimulus number',P.istim,1,P.nstim,abint,abscalar);
P.istim=istim;


prompter_showmsg(P.changestimmsg);
P.logtext_sup=[P.logtext_sup '<!!Stimulus number changed to ' int2str(istim) ' !!>' crlf];
if ~stackinuse
if istim<oldstim
P.repeatstr='!!May be first of several repeats!!';
end;
end;

disp('hit any key to continue');
pause
prompter_showg(ps{istim});
prompter_dotrafficlights('stop');
prompter_smaind(P);

prompter_showstim2investigator(istim);
