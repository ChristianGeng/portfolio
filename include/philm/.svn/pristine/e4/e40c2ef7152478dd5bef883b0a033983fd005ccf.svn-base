function vz=findz(x,dir);
% FINDZ Find zero crossings (simple version)
% function vz=findz(x,dir);
% findz: Version ??

xx=x*dir;               %handle positive/neg.
l=length(xx);
xsh=xx(2:l);
xx(l)=[];
vz=find((xsh>=0)&(xx<0));
%interpolate etc.

