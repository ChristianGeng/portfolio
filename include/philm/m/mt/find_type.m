function cutnum=find_type(iguk,ibefore);
% FIND_TYPE Find segment with desired cut type
% function cutnum=find_type(iguk,ibefore);
% find_type: Version 25.10.98
%
%   Syntax
%       Returns cut number of next cut of type 'iguk' (Optional; defaults to current type)
%		also uses current type if empty
%       cutnum is empty if nothing found
%       ibefore: Optional. If present, look for previous rather than next cut

cutnum=[];
if nargin
   mytype=iguk
   if isempty(mytype) mytype=mt_gccud('type');end;
else
   mytype=mt_gccud('type');
end;


   vv=mt_finds('all','index','type','==',mytype);

if nargin<2
   vvv=find(vv>mt_gccud('number'));
   if ~isempty(vvv) cutnum=vv(vvv(1)); end;
else
   vvv=find(vv<mt_gccud('number'));
   if ~isempty(vvv) cutnum=vv(vvv(end)); end;
end;


