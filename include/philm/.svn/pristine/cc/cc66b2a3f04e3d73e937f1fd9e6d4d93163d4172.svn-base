function mt_sdtim (newtime);
% MT_SDTIM Set new start and end times of current time-wave display window
% function mt_sdtim (newtime);
% mt_sdtim: Version 12.4.98
%
%	Syntax
%		newtime is a 2-element vector
%
%	Remarks
%		Resets the cursor position, currently to default positions at 1/4 and 3/4 of screen length
%		Should be upgrade with second argument to control where cursor is reset to
%		Does not actually redisplay time-wave data
%
%	See also
%		MT_GDTIM to get current setting
%		MT_SHOFT to do actual time-wave display
%

if nargin < 1
   disp ('mt_sdtim: No argument');
   return;
end;
if length(newtime) ~= 2
   disp ('mt_sdtim: Bad argument length');
   return;
end;
%check times are valid
nogood=0;
if newtime(1) < 0 nogood=1; end;
%include time tolerance here??
if newtime(2) <= newtime(1) nogood=1; end;
%also check start not beyond cut end??
if nogood
   disp ('mt_sdtim: Bad time argument');
   return;
end;


figh=mt_gfigh('mt_f(t)');


hca=findobj(figh,'tag','cursor_axis');
set(hca,'xlim',newtime);


figorgh=mt_gfigh('mt_organization');

%indicate screen position in current cut axis
hpos=findobj(figorgh,'tag','cursor_axis_position');
set (hpos,'xdata',newtime);



%cursor must be reset as well
%program could be upgraded to allow optional second arg.
%giving desired relative cursor position
posfac=[0.25 0.75];
cutdat=mt_gccud;
pos=[newtime(1) min([newtime(2) cutdat(2)])];
posl=diff(pos);
pos=(posfac*posl)+pos(1);
mt_scurp(pos);

mt_newft(1);
