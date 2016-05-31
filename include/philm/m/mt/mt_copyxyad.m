function mt_copyxyad(axisin,axisout)
% MT_COPYXYAD copy xy axis data
% function mt_copyxyad(axisin,axisout)
% mt_copyxyad: Version 18.3.02
%
%	Syntax
%		axisin: Axis that is already completely set up
%		axisout: Axis to which the settings of axisin are to be copied
%
%	See Also
%		MT_SXYV, MT_GXYAD, MT_SXYAD, MT_INIXY etc.
%
%	Remarks
%		Designed for quickly setting up multiple xy axes that only
%		differ in the view
%		(Convenient for 3D data, i.e sagittal, coronal and transversal plots
%		can be set up with exactly the same specifications, then simply adjust
%		the view as desired with MT_SXYV)

myS=[];
figh=mt_gfigh('mt_xy');
if isempty(figh);
   disp('mt_copyxyad: No xy figure');
   return;
end;

if nargin~=2
   help mt_copyxyad;
   return;
end;

saxh=findobj(figh,'tag',axisin,'type','axes');
if isempty(saxh)
   disp(['mt_copyxyad: Input axes not found > ' axisin]);
   return;
end;

saxhout=findobj(figh,'tag',axisout,'type','axes');
if isempty(saxhout)
   disp(['mt_copyxyad: Output axes not found > ' axisout]);
   return;
end;


myS=get(saxh,'userdata');

%this is the only entry that definitely must not be copied
axnum=mt_gxyad(axisout,'axis_number');


set(saxhout,'userdata',myS);
mt_sxyad(axisout,'axis_number',axnum);		%restore

%need to copy axis labels by hand
xx='xyz';
for ixi=1:3

hh=get(saxh,[xx(ixi) 'label']);
ss=get(hh,'string');
hh=get(saxhout,[xx(ixi) 'label']);
set(hh,'string',ss);
end;




hall=get(saxhout,'children');
%maybe a better solution???
set(hall,'visible','off');
%call display routine???
