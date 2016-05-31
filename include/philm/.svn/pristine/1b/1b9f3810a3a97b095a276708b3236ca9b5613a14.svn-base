function    prompter_showstim2investigator(istim)
% function    prompter_showstim2investigator(istim)
%check whether input argument really needed
P=prompter_gmaind;
S=prompter_gstimd;
ps=S.ps;
cs=S.cs;
nstack=length(P.stimstack);
stackstr='';
if nstack stackstr=['/' int2str(nstack)]; end;
disp('---- next prompt and code ----');
disp(ps{istim});
disp(['<CODE> ' cs{istim}]);
%disp('------------------------------');
htinfo=P.infohandle;
set(htinfo(2),'string',[int2str(istim) '/' int2str(P.nstim) stackstr ' : ' cs{istim}]);

