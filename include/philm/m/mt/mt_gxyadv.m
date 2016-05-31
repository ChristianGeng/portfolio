function myS=mt_gxyadv(axisname,fieldname)
% MT_GXYADV get xy axis data for vector display
% function myS=mt_gxyadv(axisname,fieldname)
% mt_gxyadv: Version 6.12.2000
%
%	Syntax
%		axisname: name of axes. If missing (no input args) returns
%			a list of the axes names)
%		fieldname: name of field in v_specs field in userdata structure.
%				If missing, returns complete structure.
%			fieldname need not be complete, but must be unambiguous
%
%	See Also
%		MT_SXYADV, MT_SXYAD, MT_INIXY etc.

myS=[];
figh=mt_gfigh('mt_xy');
if isempty(figh);
   disp('mt_gxyadv: No xy figure');
   return;
end;
if nargin==0
   myS=get(figh,'userdata');
   myS=myS.axis_names;
   return;
end;

saxh=findobj(figh,'tag',axisname,'type','axes');

if isempty(saxh)
   disp(['mt_gxyadv: Axis not found > ' axisname]);
   return;
end;

mydata=get(saxh,'userdata');
mydata=mydata.v_specs;

if nargin==1
   myS=mydata;
   return;
end;

fieldlist=fieldnames(mydata);

vi=strmatch(fieldname,fieldlist);

if isempty(vi)
   disp(['mt_gxyadv: Bad field name? ' fieldname]);
   return;
end;
if length(vi)~=1
   disp(['mt_gxyadv: Ambiguous field name? ' fieldname]);
   return;
end;

myS=getfield(mydata,fieldlist{vi});

