function prompter_flushlogtext
% function prompter_flushlogtext

P=prompter_gmaind;
%finish off last comment
if ~isempty(P.logtext_trial)
    prompter_writelogfile([P.logtext_trial ']' crlf]);
    P.logtext_trial='';
end;
if ~isempty(P.logtext_sup)
    prompter_writelogfile(P.logtext_sup);
    P.logtext_sup='';
end;

prompter_smaind(P);

