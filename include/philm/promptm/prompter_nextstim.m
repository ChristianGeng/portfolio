function prompter_nextstim(mytime,mytoc);
% prompter_nextstim Prepare next stimulus
% function prompter_nextstim(mytime,mytoc);
%   mytime: normally time of day at start of trial (as returned by now)
%   mytoc: elapsed time at end of trial)

P=prompter_gmaind;
S=prompter_gstimd;
ps=S.ps;
cs=S.cs;

sx=int2str([P.irun P.istim]);   %start setting up string that will be written to log file

[dodo,mytime]=strtok(datestr(mytime));  %get time of day
sx=[sx ' ' mytime];
sx=[sx ' ' num2str(mytoc)];

P.laststim=P.istim;
stackmsg='';
if P.stimfromstack stackmsg=[' ' P.stack4log ' ']; end;
stimstack=P.stimstack;
stimstack=stimstack(:);
nstack=length(stimstack);
if nstack>0
%Note: last element on stack is treated as placed there to give
%link back to main prompt list, so not marked in log file as coming from
%stack
    P.istim=stimstack(1);
    stimstack(1)=[];
        P.stimfromstack=1; 
    if isempty(stimstack)  P.stimfromstack=0; end;
    P.stimstack=stimstack;
else
    P.istim=P.istim+1;
    P.stimfromstack=0;
end;

%10.03 free comment now has to be entered with explicit command
mycomm=[' [' cs{P.laststim} P.freecode stackmsg P.repeatstr ];
P.repeatstr='';
sx=[sx mycomm];
P.logtext_trial=sx;

P.irun=P.irun+1;

prompter_smaind(P);

if P.istim<=P.nstim
    %display new stimulus immediately to subject
    prompter_dotrafficlights('stop');
    prompter_showg(ps{P.istim});
    prompter_showstim2investigator(P.istim)
    
    prompter_updatefigs;
    
end;



if P.istim>P.nstim
    disp('End of stimuli');
    prompter_quit;              %sets P.istim to P.nstim
    
    
end;
