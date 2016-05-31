function cutnum=find_wildcard(wild ,ibefore);
% FIND_WILDCARD Find next segment with desired label by regwild
% function cutnum=find_wild(wild ,ibefore);
% find_wild: Version 15.04.2012
%
%   Syntax
%       Returns cut number of next cut with label matching 'wild' (Optional; defaults to current label)
%		also uses current label if empty
%       cutnum is empty if nothing found
%       ibefore: Optional. If present, look for previous rather than next cut
%
%   See Also REGEXPTRANSLATE, FIND_EXPR

cutnum=[];

if ~ismember(exist('regexptranslate'), [2 5])
    disp('find_wildcard: matlab version may be too old. Try find_expr instead');
    return;
end;

if nargin
   mylabel=regexptranslate('wildcard', wild) ;
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

