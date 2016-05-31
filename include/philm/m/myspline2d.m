function [peri,buttons]=myspline2d(interprate,ijoin)
% MYSPLINE2D Interactive input of 2D curve with spline interpolation
% function [peri,buttons]=myspline2d(interprate,ijoin)
% MYSPLINE2D: Version 13.3.09
%
%	Description
%		Based on matlab demo program
%		Version for vocal tract contours. Simply return xy data of perimeter
%		interprate: Interpolation rate; set <= 1 to simply return with the 
%			points clicked on. Default to 10
%		ijoin: set to false if start and end point should not be joined up
%		buttons: optional: return button or character pressed for each point
%
%	See Also
%		SPLINE2D Demonstrate GINPUT and SPLINE in two dimensions.


%   CBM, 8-9-91, 8-12-92.
%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 5.5 $  $Date: 1997/11/21 23:27:11 $
% phil 2.2000, don't reset any graphics


% This demonstration illustrates the use of the GINPUT function,
% which obtains graphic positional input via a mouse or cursor,
% and the SPLINE function, which interpolates data with a cubic spline.
% The demonstration does NOT use the Spline Toolbox, which is a
% complete set of functions for B-splines and other piecewise polynomials
% of any degree.
%
%Press any key to continue after pauses.


if nargin <1 interprate=10;end;

if nargin<2 ijoin=1; end;

disp('Hit any key, then click on points');
pause
% Here is code which uses the left mouse button to pick a sequence of
% points and the return key to stop input.
% Initially, the list of points is empty and its length is 0.

% Please use the left mouse button or the cursor to select several points.
% Use the return key (or right mouse button) to stop input.

x = [];
y = [];
bbuf=[];
n = 0;
% Loop, picking up the points.
stillworking = 1;
while stillworking
   [xi,yi,but] = ginput(1);
   if length(but)==0,
    if ((n<2) & (interprate>1))
%     but=1;
     disp('Pick at least two points please.')
    else
     stillworking=0;
    end

  else

line(xi,yi,'color','k','linestyle','none','marker','o','tag','temp','erasemo
de','xor')

   n = n + 1;
%   text(xi,yi,[' ' int2str(n)],'tag','temp');
   x = [x; xi];
   y = [y; yi];
	bbuf=[bbuf;but];
end
end

disp('End of data entry')

if ijoin
x=[x;x(1)];
   y=[y;y(1)];
   bbuf=[bbuf;bbuf(1)];
   n=n+1;

end;

% Interpolate the points with two splines, evaluated with a finer spacing.

xs=x;ys=y;

if interprate>1

t = 1:n;
ts = 1:1/interprate:n;
xs = spline(t,x,ts);
ys = spline(t,y,ts);
xs=xs';
ys=ys';	%returned from spline as row vector
end;
% Plot the interpolated curve with a cyan colored line.

hl=line(xs,ys,'color','k');

peri=[];
if nargout>1 buttons=[];end;
myinp=philinp('OK? [y] ');

if ~strcmp(lower(myinp),'n')
   peri=[xs ys];
	if nargout>1 buttons=bbuf; end;
end;

delete(hl);
delete(findobj(gcf,'tag','temp'));
