function cutnum=find_trial(iguk);
% FIND_TRIAL Find first segment in desired trial
% function cutnum=find_trial(iguk);
% find_trial: Version 11.10.2000
%
%   Syntax
%       Returns cut number of first cut in trial 'iguk' 
%       (Optional; defaults to next trial after current one)
%       cutnum is empty if nothing found
%       Note: ignores any cuts with NaNs for start or end boundary
%
%   See Also MT_FINDS


cutbuf=mt_gcufd;
vv=find(isnan(cutbuf(:,1)) | isnan(cutbuf(:,2)));

if ~isempty(vv) cutbuf(vv,:)=NaN; end;


cutnum=[];
if nargin
   trialnum=iguk;
   cutnum=mt_finds('first','index','trial','==',trialnum,cutbuf);
   return;
else
   trialnum=mt_gtrid('number');
   inext=mt_finds('first','data','trial','>',trialnum,cutbuf);
   if ~isempty(inext)
      trialnum=inext(4);
      cutnum=mt_finds('first','index','trial','==',trialnum,cutbuf);
   end;
end;
