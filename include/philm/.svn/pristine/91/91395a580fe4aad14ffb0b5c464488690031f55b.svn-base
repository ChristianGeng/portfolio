function result=mt_scurp(curpos,chandlein);
% mt_scurp Set cursor position (time display)
% function result=mt_scurp(curpos,chandlein);
% mt_scurp: Version 12.4.98
%
% Purpose
%   Set position (in s.) of left and right cursor, relative to start of current trial
%
% Syntax
%   curpos: Two element row vector
%   chandlein: Optional. Cursor handles. If available in calling program function will execute faster
%   result: 0 if attempted movement to unallowed cursor position (cursors are not moved)
%
% See also
%   mt_gcurp Get cursor position
%   mt_gcurh Get cursor handles
%
% Remarks
%   Blocking of unallowed cursor movement is not yet satisfactory

        %optional handle, otherwise use findobj (in mt_gcurh)

        %define tolerance for how close together cursors can be
        %and how close right cursor can be to right margin:
        %essentially graphical
        
        %replace with max_samp_inc????
        
        tolfac=500;  %i.e 1/500 of total screen time

        result=0;
        if nargin > 1
           ch=chandlein;
        else
            ch=mt_gcurh;
        end;

        %to do checks we need cursor axis limits
        hca=get(ch(1,1),'parent');
        mytime=get(hca,'xlim');
        mydur=mytime(2)-mytime(1);
        tolval=mydur./tolfac;

        nogood=0;
        cl=curpos(1);
        cr=curpos(2);
        if cl < mytime(1) nogood=1;end;
        if cr >= (mytime(2)-tolval) nogood=1;end;
        if cl >= (cr-tolval) nogood=1;end;

        if ~nogood
           set (ch(:,1),'xdata',[cl cl]);
           set (ch(:,2),'xdata',[cr cr]);
           result=1;
        end;
