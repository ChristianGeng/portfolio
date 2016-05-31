function hl=barerror(hp,errordata);
% BARERROR Add errorbars to bars
% function hl=barerror(hp,errordata);
% barerror: Version 9.11.07
%
%   Syntax
%       hp: handles to patch objects returned by BAR
%       errordata: Some measure of dispersion for the data input to BAR
%           (thus must have same shape as mean etc. data used with BAR
%
%   Notes:
%       May not be compatible with graphics later than version 6
%
%   See Also
%       BAR basic matlab function for plotting bar charts
%       BARHATCH Hatching patterns for bars (e.g for monochrome output)

np=length(hp);


%mylinestyle=':';		%dotted
%mylinestyle='-';		%solid


errxfac=0.25;


for ip=1:np
mylinewidth=get(hp(ip),'linewidth');
   xd=get(hp(ip),'xdata');
   yd=get(hp(ip),'ydata');
   
   nb=size(xd,2);
   hatchx=[];hatchy=[];
   
   for ib=1:nb
      y0=yd(1,ib);
      y1=yd(2,ib);
      x0=xd(1,ib);
      x1=xd(3,ib);
      xdiff=x1-x0;
      xcent=x0+xdiff/2;
      errx=xdiff*errxfac;
      
      errv=errordata(ib,ip);
        if y1<0 errv=-errv; end;
      hatchx=[hatchx;xcent;xcent;xcent-errx;xcent+errx;NaN];
      hatchy=[hatchy;y1;y1+errv;y1+errv;y1+errv;;NaN];
      
      
      
   end;
   
   %draw the line
   
%   keyboard;
   hl(ip)=line('xdata',hatchx,'ydata',hatchy,'color','k','linewidth',mylinewidth);
   
end;
