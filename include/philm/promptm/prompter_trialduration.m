function prompter_trialduration;
% function prompter_trialduration;

[abint,abnoint,abscalar,abnoscalar]=abartdef;

P=prompter_gmaind;
disp('Enter new trial duration');
trial_duration=abart('New duration',P.trial_duration,1,999,abnoint,abscalar);
P.trial_duration=trial_duration;
P.logtext_sup=[P.logtext_sup '<Trial Duration changed to ' num2str(trial_duration) '>' crlf];

prompter_smaind(P);
