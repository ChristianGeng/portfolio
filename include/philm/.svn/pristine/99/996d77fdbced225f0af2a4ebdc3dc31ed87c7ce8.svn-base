function myS=mt_gsonafd(fieldname)
% MT_GSONAFD get sona figure data
% function myS=mt_gsonafd(fieldname)
% mt_gsonafd: Version 25.9.98
%
%	Syntax
%		fieldname: name of field in userdata structure. If missing, returns complete structure
%			fieldname need not be complete, but must be unambiguous
%
%	See Also
%		MT_SXYAD, MT_INIXY etc.

figname='sona';
funcname=['mt_g' figname 'fd'];
myS=[];
figh=mt_gfigh(['mt_' figname]);
if isempty(figh);
   disp([funcname ': No ' figname ' figure']);
   return;
end;

myS=get(figh,'userdata');
if nargin==0
   return;
end;

mydata=myS;

fieldlist=fieldnames(mydata);

vi=strmatch(fieldname,fieldlist);

if isempty(vi)
   disp([funcname ': Bad field name? ' fieldname]);
   return;
end;
if length(vi)~=1
   disp([funcname ': Ambiguous field name? ' fieldname]);
   return;
end;

myS=getfield(mydata,fieldlist{vi});

