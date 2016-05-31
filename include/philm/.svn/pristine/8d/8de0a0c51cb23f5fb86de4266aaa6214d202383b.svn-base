function myS=mt_gsurfad(axisname,fieldname)
% MT_GSURFAD get surf axis data
% function myS=mt_gsurfad(axisname,fieldname)
% mt_gsurfad: Version 21.08.2013
%
%	Syntax
%		axisname: name of axes. If missing (no input args) returns
%			a list of the axes names)
%		fieldname: name of field in userdata structure. If missing, returns complete structure.
%			fieldname need not be complete, but must be unambiguous
%
%	See Also
%		MT_GXYAD, MT_GSONAAD, MT_SXYAD, MT_INIXY, MT_GVIDEOAD etc.

myS=[];
figh=mt_gfigh('mt_surf');
if isempty(figh);
   disp('mt_gsurfad: No surf figure');
   return;
end;
if nargin==0
   myS=get(figh,'userdata');
   myS=myS.axis_names;
   return;
end;

saxh=findobj(figh,'tag',axisname,'type','axes');

if isempty(saxh)
   disp(['mt_gsurfad: Axis not found > ' axisname]);
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
   disp(['mt_gsurfad: Bad field name? ' fieldname]);
   return;
end;
if length(vi)~=1
   disp(['mt_gsurfad: Ambiguous field name? ' fieldname]);
   return;
end;

myS=getfield(mydata,fieldlist{vi});

