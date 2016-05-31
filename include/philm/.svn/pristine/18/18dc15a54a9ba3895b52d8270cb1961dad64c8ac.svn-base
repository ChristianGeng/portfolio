function mt_smarx(myfield,mydata)
% mt_smarx Set marker data
% function mt_smarx(myfield,mydata)
% mt_gmarx: Version 7.10.98
%
% Syntax
%   Set field in marker userdata structure
%
% See Also
%   all mt_*mark routines



myS=[];
figorgh=mt_gfigh('mt_organization');
caxh=findobj(figorgh,'tag','current_cut_axis');
mh=findobj(caxh,'tag','marker_org');   
if isempty(mh) return; end;


myS=get(mh,'userdata');



fieldlist=fieldnames(myS);
vi=strmatch(myfield,fieldlist);
if isempty(vi)
   disp(['mt_smarx: Bad field name; ' myfield]);
   return;
end;


myS=setfield(myS,fieldlist{vi(1)},mydata);

set(mh,'userdata',myS);

