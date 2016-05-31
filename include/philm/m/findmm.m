function [maxp,minp]=findmm(x,indexrange);
% FINDMM Find max and min position
% function [maxp,minp]=findmm(x,indexrange);
% findmm: Version 27.2.98
%
%	Syntax
%		indexrange: 2-element vector: Limits (inclusive) on allowable values for threshold position (index in buffer)
%			just to save calling program some fiddling around with
%			offsets into buffers. Defaults to complete input buffer
%
%	See Also
%		FINDTH

lx=length(x);
loguk=1;higuk=lx;
if nargin > 1
   if length(indexrange) ==2
      if indexrange(2)>=indexrange(1)
         loguk=indexrange(1);
         higuk=indexrange(2);
      end;
   end;
end;
xx=x(loguk:higuk);
[maxw,maxp]=max(xx);
[minw,minp]=min(xx);
v=([maxp minp])+loguk-1;
maxp=v(1);minp=v(2);
