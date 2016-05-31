function prompter_sonixfreeze(myfreeze,mytrigger);
% PROMPTER_SONIXFREEZE Set Sonix freeze state (optionally changing trigger out)
% function prompter_sonixfreeze(myfreeze,mytrigger);
%
%   Syntax
%       myfreeze: 1 to freeze, 0 to unfreeze
%       mytrigger: Optional. If myfreeze==1 the current trigger out setting
%       can be changed.
%       mytrigger=1: set trigger out to value in triggeroutvalue (0=off,
%       1=line, 2=frame, 3=clock)
%       mytrigger=0: set trigger out to 0 (off) as longer as triggermode is
%           not set to 'continuous'

U=sonix_getsettings;

badget=0;
curfreeze=sonix_ctrl('getfreeze');

if isempty(curfreeze)
    badget=1;
    mymess='get freeze error';
else
    
    if curfreeze~=myfreeze
        curfreeze=sonix_ctrl('togglefreeze');
        
        if isempty(curfreeze)
            badget=1;
            mymess='toggle freeze error';
        end;
    end;
end;

if badget
    prompter_writelogfile(mymess);
else
    pause(U.freezedelay);
end;

%handle trigger changes regardless of whether there has been an error
if myfreeze==1
    if nargin>1
        if mytrigger==1
            sonix_ctrl('setpar','SYNC.trigger_out',U.triggervalue);
        end;
        if mytrigger==0
            if ~strcmp('continuous',lower(U.triggermode))
                sonix_ctrl('setpar','SYNC.trigger_out',0);
            end;
        end;
    end;
end;

                