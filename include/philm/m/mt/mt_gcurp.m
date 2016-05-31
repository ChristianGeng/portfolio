function curpos=mt_gcurp(chandlein);
% mt_gcurp Get cursor position
% function curpos=mt_gcurp(chandlein);
% mt_gcurp: Version 20.4.98
%
% Purpose
%   Obtain position (in s.) of left and right cursor, relative to start of current trial
%
% Syntax
%   curpos: Two element row vector
%   chandlein: Optional. Cursor handles. If available in calling program function will execute faster
%
% See also
%   mt_scurp Set cursor position
%   mt_gcurh Get cursor handles


        %optional handle, otherwise use findobj (in mt_gcurh)

        if nargin > 0
           ch=chandlein;
        else
            ch=mt_gcurh;
        end;


        curpos=[getfirst(get (ch(1,1),'xdata')) getfirst(get (ch(1,2),'xdata'))];

