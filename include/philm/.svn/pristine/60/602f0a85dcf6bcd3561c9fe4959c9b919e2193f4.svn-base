function myS=mt_gxyfd(fieldname)
% mt_gxyfd get xy figure data
% function myS=mt_gxyfd(fieldname)
% mt_gxyfd: Version 25.9.98
%
% Syntax
%   fieldname: name of field in userdata structure. If missing, returns complete structure
%			fieldname need not be complete, but must be unambiguous
%
% See Also
%   mt_sxyad, mt_inixy etc.

myS=[];
figh=mt_gfigh('mt_xy');
if isempty(figh);
   disp('mt_gxyfd: No xy figure');
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
   disp(['mt_gxyfd: Bad field name? ' fieldname]);
   return;
end;
if length(vi)~=1
   disp(['mt_gxyfd: Ambiguous field name? ' fieldname]);
   return;
end;

myS=getfield(mydata,fieldlist{vi});

