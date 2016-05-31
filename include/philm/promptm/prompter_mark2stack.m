function prompter_mark2stack
% function prompter_mark2stack

P=prompter_gmaind;

marklist=P.marklist;

stimstack=P.stimstack;

if ~isempty(marklist)
    marklist=marklist(:);
    if isempty(stimstack)
%add stimulus to return from stack to main prompt sequence
        istim=P.istim+1;
        if istim>P.nstim istim=P.nstim; end;
        stimstack=[marklist;istim];
    else
        stimstack=stimstack(:);
        stimstack=[marklist;stimstack];
    end;
    P.marklist=[];
    P.stimstack=stimstack;
    disp('Marked list moved to stack and reset');
    disp(['Current stack length ' int2str(length(stimstack))]);
    prompter_smaind(P);
end;
