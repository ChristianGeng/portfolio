function prompter_showstack
% function prompter_showstack

P=prompter_gmaind;

stimstack=P.stimstack;

    disp('Current contents of stack');
    S=prompter_gstimd;
    ss=S.s1line;
    disp(ss(stimstack));
