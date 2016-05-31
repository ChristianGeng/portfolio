function [cutout,cutflag]=cutcheck(cutin,startlim,endlim);
% CUTCHECK Checks cut boundaries are within limits
% function [cutout,cutflag]=cutcheck(cutin,startlim,endlim);
% cutcheck: Version ???
%
%   Syntax
%       start must be ge startlim, end must be le endlim
%       startlim and endlim can be vectors
%       also check duration not negative
%       error flag in cutflag
%           1 = start adjusted
%           2 = end adjusted
%           4 = duration negative, set to zero at cut start

temp=cutin;
cutflag=0;
lim=startlim;
%or ll=length(lim);lim(ll+1)=temp(1)
if size(lim,1)>1 lim=lim'; end
temp(1)=max ([lim temp(1)]);
lim=endlim;
if size(lim,1)>1 lim=lim'; end
temp(2)=min ([lim temp(2)]);

if temp(1)~=cutin(1) cutflag=cutflag+1;end
if temp(2)~=cutin(2) cutflag=cutflag+2;end
if (temp(2)-temp(1) < 0)
    cutflag=cutflag+4;
    temp(2)=temp(1);
end
cutout=temp;
if cutflag~=0
    disp (['?Cutcheck? Flag ' int2str(cutflag)]);
    disp ([cutin temp]);
end

