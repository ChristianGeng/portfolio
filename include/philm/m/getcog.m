function [cog,dispersion]=getcog(x,y,izero);
% GETCOG Center of gravity and dispersion
% function [cog,dispersion]=getcog(x,y,izero);
% getcog: Version 16.4.03
%
%   Syntax
%       When applied to spectral analysis
%       y will contain the spectral amplitudes
%       and x will contain the frequency location of each element of y
%       izero is optional. If true, set negative values of y to zero
%           (this was designed for special cases, e.g x is time, and y is
%           e.g movement acceleration).
%
%   Algorithm
%       This is simply the formula for calculating the mean and standard
%       deviation of a data distribution when the data is available as a
%       frequency histogram

myzero=0;
if nargin>2 myzero=izero;end;

if myzero
   y(y<0)=0;
else
   
mm=min(y);
if mm<0
   y=y-mm;
   disp('getcog: shifting baseline');
end;
end;


sy=sum(y);
cog=sum(x.*y)/sy;

dx=(x-cog).^2;
dx=sum(dx.*y);
dispersion=sqrt(dx/sy);
