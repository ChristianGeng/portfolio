function [sdata,slabel]=sortcut(cutdata,cutlabel);
% SORTCUT Sort cutdata (by trial and start time)
% function [sdata,slabel]=sortcut(cutdata,cutlabel);
% sortcut: Version 06.06.2004
%
%	Description
%		Sorts cuts by trial and start time
%		Currently trial assumed to be column 4 and start time column 1 of cutdata
%		(may be possible to override this in future)
%       Sorted by ascending trial number, then ascending start time, then
%       descending end time, then ascending cut type
%       This puts longer cuts with same starting time before shorter ones
%       and cuts with NaN as ending time first
%		May be upgraded to allow quicker sorting, where only one trial needs sorting

spar=[4 1 2 3];
xx=cutdata;
mm=max(xx(:,2));
vv=find(isnan(xx(:,2)));
xx(vv,2)=mm*2;
xx(:,2)=-xx(:,2);       %desceding order with NaNs first

[xx,v]=sortrows(xx,spar);
slabel=cutlabel(v,:);
sdata=cutdata(v,:);
