function prompter_paralleloutctl(mycmd,arg2)
% function prompter_paralleloutctl(mycmd,parportin)
%
%   Syntax
%       When command is 'ini' arg2 should be parport object obtained with
%           prompter_getparport
%       When command is 'trial' (vtg55 only), arg2 should be the trial number
%       Other commands, 'start', 'stop', 'reset' (vtg55 only)
%
%   Notes
%       Settings cannot be changed without re-initializing
%           i.e. even if they are changed in the main prompter data structure
%           paralleloutmode synchline vtgtrialflag vtgtrialfix
%           these settings remain fixed until the next call with command
%           'ini'
%      A user function can be defined that is executed after the 'start'
%      and 'end' commands. Define in the main input struct
%       S.userparallelstartfunc or S.userparallelstopfunc
%       Note: This user function is executed even if no parallel port mode
%       is active. Also, it can be changed at any time.

persistent parport paralleloutmode synchline vtgtrialflag vtgtrialfix


if strcmp(mycmd,'start')
    if strcmp(paralleloutmode,'simple')
        putvalue(parport.Line(synchline),1);
    end;
    if strcmp(paralleloutmode,'porttalk')
        lptwrite(parport,synchline);
    end;
    if strcmp(paralleloutmode,'vtg55')
        vtgctrl('start');
    end;
        P=prompter_gmaind;
        prompter_evaluserfunc(P.userparallelstartfunc,'userparallelstart');

        return;    
    
end;

if strcmp(mycmd,'stop')
    if strcmp(paralleloutmode,'simple')
        putvalue(parport.Line(synchline),0);
    end;
    if strcmp(paralleloutmode,'porttalk')
        lptwrite(parport,0);
    end;
    if strcmp(paralleloutmode,'vtg55')
        vtgctrl('stop');
    end;
    
        return;    
        P=prompter_gmaind;
        prompter_evaluserfunc(P.userparallelstopfunc,'userparallelstop');
end;



if strcmp(mycmd,'ini')
    
    P=prompter_gmaind;
    if ~P.daqok
        paralleloutmode=''; %prevent any further attempt to access port
    else    
        paralleloutmode=P.paralleloutmode;
        parport=arg2;
        if strcmp(paralleloutmode,'simple')
            synchline=P.synchline;
            
            lines_OUT_1 = addline(parport,[0:7],0,'out');
            
            putvalue(parport.Line(synchline),0);
            
        end;
    if strcmp(paralleloutmode,'porttalk')
            synchline=P.synchline;
        lptwrite(parport,0);
        
        return;    
    end;
        
        if strcmp(paralleloutmode,'vtg55')
            vtgtrialflag=P.vtgtrialflag;
            vtgtrialfix=P.vtgtrialfix;
            
            vtgctrl('ini',parport);
        end;
        
    end;        %daqok
end;               %ini


if strcmp(mycmd,'trial')
    if strcmp(paralleloutmode,'vtg55')
        if vtgtrialflag
            
            vtgtrialnum=arg2;
            if vtgtrialfix vtgtrialnum=1; end;
            
            vtgctrl('trial',vtgtrialnum); 
        end;
    end;
end;



if strcmp(mycmd,'reset')
    if strcmp(paralleloutmode,'vtg55')
            
            vtgctrl('reset'); 
        end;
end;



