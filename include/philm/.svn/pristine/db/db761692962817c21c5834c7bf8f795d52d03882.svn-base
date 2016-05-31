function prompter_aguserstartfunc
% function prompter_aguserstartfunc

tcp_timeoutflag=prompter_checkagready4next;     %gets current trial number from AG500

if tcp_timeoutflag
    prompter_smaind('abortnext',1);
    disp('Next command not completed');
    return;
end;

timeoutflag=prompter_startag;

if timeoutflag
    prompter_smaind('abortnext',1);
    disp('Next command not completed');
    return;
end;
