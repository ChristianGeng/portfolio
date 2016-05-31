function myS=mt_gxyad(axisname,fieldname)
% MT_GXYAD get xy axis data
% function myS=mt_gxyad(axisname,fieldname)
% mt_gxyad: Version 3.4.99
%
%	Syntax
%		axisname: name of axes. If missing (no input args) returns
%			a list of the axes names)
%		fieldname: name of field in userdata structure. If missing, returns complete structure.
%			fieldname need not be complete, but must be unambiguous
%
%	See Also
%		MT_SXYAD, MT_INIXY etc.

myS=[];
figh=mt_gfigh('mt_xy');
if isempty(figh);
   disp('mt_gxyad: No xy figure');
   return;
end;
if nargin==0
   myS=get(figh,'userdata');
   myS=myS.axis_names;
   return;
end;

saxh=findobj(figh,'tag',axisname,'type','axes');

if isempty(saxh)
   disp(['mt_gxyad: Axis not found > ' axisname]);
   return;
end;

mydata=get(saxh,'userdata');


if nargin==1
   myS=mydata;
   return;
end;

fieldlist=fieldnames(mydata);

vi=strmatch(fieldname,fieldlist);

if isempty(vi)
   disp(['mt_gxyad: Bad field name? ' fieldname]);
   return;
end;
if length(vi)~=1
   disp(['mt_gxyad: Ambiguous field name? ' fieldname]);
   return;
end;

myS=getfield(mydata,fieldlist{vi});

