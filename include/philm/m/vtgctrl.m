function vtgctrl(vtgcmd,arg2)
% VTGCTRL Control VTG55 video timer and synch output
% function vtgctrl(vtgcmd,arg2)
% VTGCTRL: Version 31.10.07
%
%   Syntax
%       commands are 'ini', 'start', 'stop', 'reset', 'hour/min/secset', 'trial'
%       ini requires parallel port digital io object as second argument
%       trial requires trial number as second argument
%
%   Updates
%       10.07. Make delay for incrementing the counters configurable.
%           If the delay is too short the counters may not increment
%           properly
%       On initialization, the program looks for a file called vtgcfg.mat
%       on matlab's path. If this contains a variable vtgdelay then this is
%       used. Notes: The file should preferably NOT be in a path location that is 
%           updated by subversions. Old IBM thinkpad used a value of 5 (though 3 also seems to be OK)
%           for the delay, so newer machines
%           will need higher values. Test by incrementing the hours counter
%           to 99. This should take about 500ms
%           function vtgtest can be used for this.

persistent outlines vtgval vtgdelay


if nargin<1 vtgcmd='keyboard'; end;

vtgcfgfile='vtgcfg';

maxtrial=600;   %highest trial number that can be displayed in standard arrangement

%parallel port object must have been set up appropriately for these line
%numbers

vtgstartl=1;
vtgstopl=2;
vtgresetl=3;
vtgfreezel=4;       %note: command not yet implemented
vtgsecsetl=5;
vtgminsetl=6;
vtghoursetl=7;

%
%easy solution for additional synch output if line is free
%but should be configurable for use without vtg
%maybe need to make persistent??
%set to zero if not in use
%futher case: if not on same port, won't need to handle vtgval
vtgsynchl=8;


%before turning on VTG should do a reset to set all VTG lines to high

%does vtgval need to be persistent to keep track of current state of lines?
%vtgval=allhigh;
switch lower(vtgcmd)
    case 'ini'
        if nargin<2
            disp('vtgctrl: unable to initialize. Need digital io object as second input argument');
            return
        end;
        parport=arg2;
        outlines = addline(parport,[0:7],0,'out');   %output lines to control video timer and do synch output line
        %adjust allhigh to take account of this
        %will set synch line to low with ini command
        allhigh=255;
        if vtgsynchl allhigh=bitset(allhigh,vtgsynchl,0); end;
        vtgval=allhigh;
        putvalue(outlines,vtgval)    
        pause(0.1);
    %default value of delay. This is what works on oldest IBM thinkpad
    vtgdelay=5;
    if exist([vtgcfgfile '.mat'],'file')
        tempval=mymatin(vtgcfgfile,'vtgdelay');
        if ~isempty(tempval)
            vtgdelay=tempval;
            disp(['Setting vtgdelay to ' int2str(vtgdelay)]);
        end;
    end;
    
        

    
    
    
    case 'start'
        %could maybe be merged with vtgl
        if vtgsynchl vtgval=bitset(vtgval,vtgsynchl,1); end;
        
        vtgl(outlines,vtgval,vtgstartl,vtgdelay);
        
    case 'stop'
        if vtgsynchl vtgval=bitset(vtgval,vtgsynchl,0); end;
        vtgl(outlines,vtgval,vtgstopl,vtgdelay);
        
    case 'reset'
        vtgl(outlines,vtgval,vtgresetl,vtgdelay);
        
        %should not be needed much, except perhaps if minutes unit is used as trial running flag
        %see below (trial command)
        
    case 'hourset'
        vtgl(outlines,vtgval,vtghoursetl,vtgdelay);
        
    case 'minset'
        vtgl(outlines,vtgval,vtgminsetl,vtgdelay);
        
    case 'secset'
        vtgl(outlines,vtgval,vtgsecsetl,vtgdelay);
        
        
        %trial mode uses the hour counter for the tens and units of the trial number
        % and the tens of the minute counter for the hundreds of the trial
        % number
        %This screwy way is because the hours counter goes up to 99, the
        %minutes only to 59
        %Using the tens digit of the minutes for the trial number, leaves the
        %units digit of the minutes free for normal counting, i.e allows trials
        %up to 10 minutes long
        %Or the minutes digit can be used as a flag for trial running, allowing
        %trials up to 1 minute long.
        %This could probably all be made configurable, but this should be the
        %best compromise
        
        %Note that setting the trial number can be quite slow, as each pulse
        %needs a millisecond or so, so total time could be a couple of hundred
        %ms
        
    case 'trial'
        if nargin<2
            disp('vtgctrl: ?no trial number?');
            return;
        end;
        trialnum=arg2;
        %mainly to stop a long wait with erroneous input
        trialnum=mod(trialnum,maxtrial);
        trialnum=max([trialnum 1]);
        
        hourcount=mod(trialnum,100);
        mincount=floor(trialnum/100)*10;
        
        %ensure counter is at zero
        vtgl(outlines,vtgval,vtgresetl,vtgdelay);
        
        for ii=1:hourcount vtgl(outlines,vtgval,vtghoursetl,vtgdelay); end;
        for ii=1:mincount vtgl(outlines,vtgval,vtgminsetl,vtgdelay); end;
        
    otherwise
        
        disp('vtgctrl: ?unknown command?');
        keyboard;
    end;
    
    
    
    
    %need to wait for time equivalent to about 6 putvalue calls
    
    function vtgl(outlines,vtgval,myline,vtgdelay);
    
    
    vtgval=bitset(vtgval,myline,0);
    for ii=1:vtgdelay putvalue(outlines,vtgval); end;
    vtgval=bitset(vtgval,myline,1);
    %delay may not be necessary here
    for ii=1:vtgdelay putvalue(outlines,vtgval); end;
    
    
    
