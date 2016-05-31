function cutnum=find_label(iguk,ibefore);
% FIND_LABEL Find next segment with desired label
% function cutnum=find_label(iguk,ibefore);
% find_label: Version 25.10.98
%
%   Syntax
%       Returns cut number of next cut with label 'iguk' (Optional; defaults to current label)
%		also uses current label if empty
%       cutnum is empty if nothing found
%       ibefore: Optional. If present, look for previous rather than next cut

cutnum=[];
if nargin
   mylabel=iguk;
   if isempty(mylabel) mylabel=mt_gccud('label');end;
else
   mylabel=mt_gccud('label');
end;

vv=strmatch(mylabel,mt_gcufd('label'));

if isempty(vv) return; end;

if nargin<2
   vvv=find(vv>mt_gccud('number'));
   if ~isempty(vvv) cutnum=vv(vvv(1)); end;
else
   vvv=find(vv<mt_gccud('number'));
   if ~isempty(vvv) cutnum=vv(vvv(end)); end;
end;

