function myS=mt_gmarx(fieldname)
% mt_gmarx get marker data
% function myS=mt_gmarx(fieldname)
% mt_gmarx: Version 7.10.98
%
% Syntax
%   Returns fields in marker userdata structure; no input arg returns complete structure
%
% See Also
%   all mt_*mark routines

myS=[];
figorgh=mt_gfigh('mt_organization');
caxh=findobj(figorgh,'tag','current_cut_axis');
mh=findobj(caxh,'tag','marker_org');   
if isempty(mh) return; end;

mydata=get(mh,'userdata');


if nargin==0
   myS=mydata;
   return;
end;

fieldlist=fieldnames(mydata);

vi=strmatch(fieldname,fieldlist);

if isempty(vi)
   disp(['mt_gmarx: Bad field name? ' fieldname]);
   return;
end;

myS=getfield(mydata,fieldlist{vi(1)});



