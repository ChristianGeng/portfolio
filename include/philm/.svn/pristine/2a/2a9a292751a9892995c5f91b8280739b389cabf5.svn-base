function myS=mt_gvideoad(axisname,fieldname)
% MT_GVIDEOAD get video axis data
% function myS=mt_gvideoad(axisname,fieldname)
% mt_gvideoad: Version 22.5.2000
%
%	Syntax
%		axisname: name of axes. If missing (no input args) returns
%			a list of the axes names)
%		fieldname: name of field in userdata structure. If missing, returns complete structure.
%			fieldname need not be complete, but must be unambiguous
%
%	See Also
%		MT_GXYAD, MT_GSONAAD, MT_SXYAD, MT_INIXY etc.

myS=[];
figh=mt_gfigh('mt_video');
if isempty(figh);
   disp('mt_gvideoad: No video figure');
   return;
end;
if nargin==0
   myS=get(figh,'userdata');
   myS=myS.axis_names;
   return;
end;

saxh=findobj(figh,'tag',axisname,'type','axes');

if isempty(saxh)
   disp(['mt_gvideoad: Axis not found > ' axisname]);
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
   disp(['mt_gvideoad: Bad field name? ' fieldname]);
   return;
end;
if length(vi)~=1
   disp(['mt_gvideoad: Ambiguous field name? ' fieldname]);
   return;
end;

myS=getfield(mydata,fieldlist{vi});

