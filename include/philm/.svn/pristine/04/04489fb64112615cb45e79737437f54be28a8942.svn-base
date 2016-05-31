function mymap=myhsv2rgb(isize)
% MYHSV2RGB Colormap based on hsv variation
% function mymap=myhsv2rgb(isize)
% myhsv2rgb: Version 5.5.99
%
%	Syntax
%		isize: Desired size of colormap (default=64)
%
%	See also
%		HSV2RGB

mysize=64;if nargin mysize=isize; end;

h=(0:(mysize-1))'/mysize;
s=h;
v=h;
%reverse order of hue variation
h=1-h;

mymap=hsv2rgb([h s v]);
