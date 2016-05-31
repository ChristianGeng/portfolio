function cutnum=find_expr(expr ,ibefore);
% FIND_EXPR Find next segment with desired label by regexpr
% function cutnum=find_expr(expr ,ibefore);
% find_expr: Version 13.04.2012
%
%   Syntax
%       Returns cut number of next cut with label matching 'expr ' (Optional; defaults to current label)
%		also uses current label if empty
%       cutnum is empty if nothing found
%       ibefore: Optional. If present, look for previous rather than next cut
%
%   See Also
%       FIND_LABEL, FIND_WILDCARD

cutnum=[];
if nargin
   mylabel=expr ;
   if isempty(mylabel) mylabel=mt_gccud('label');end;
else
   mylabel=mt_gccud('label');
end;
labs=cellstr(mt_gcufd('label'));
vv=regexp(labs,mylabel,'once');
vv=cellfun('isempty',vv);
if all(vv) return; end;
vv=find(~vv);

if nargin<2
   vvv=find(vv>mt_gccud('number'));
   if ~isempty(vvv) cutnum=vv(vvv(1)); end;
else
   vvv=find(vv<mt_gccud('number'));
   if ~isempty(vvv) cutnum=vv(vvv(end)); end;
end;

