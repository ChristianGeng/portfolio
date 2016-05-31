function prompter_mark(mycmd)
% function prompter_mark(mycmd)

P=prompter_gmaind;
if isempty(P.laststim)
    disp('Mark not possible before first stimulus');
    return;
end;

marklist=P.marklist;

if upper(mycmd)==mycmd
    disp('Marked stimuli');
    S=prompter_gstimd;
    ss=S.s1line;
    disp(ss(marklist));
    return;
else
    istim=P.laststim;
    P.logtext_trial=[P.logtext_trial P.mark4log];
    marklist=[marklist;istim];
    P.marklist=marklist;
    disp(['Stimulus ' int2str(istim) ' marked. Current length of marklist : ' int2str(length(marklist))]);    
    prompter_smaind(P);
end;

