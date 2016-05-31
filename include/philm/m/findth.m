function v=findth(x,thspec,dir,indexrange,interactive_flag);
% FINDTH Find threshold
% function v=findth(x,thspec,dir,indexrange,interactive_flag);
% findth: Version 17.6.2006
%
% Syntax
%   thspec:
%          if scalar look for absolute threshold
%          if length 3, proportional; arranged min, max, proportion
%          if missing or neither length 1 or 3, defaults to 0
%   dir: defaults to 1. Use to get negative threshold crossing
%   indexrange: 2-element vector: Limits (inclusive) on allowable values for threshold position (index in buffer)
%               just to save calling program some fiddling around with
%               offsets into buffers. If missing or empty, defaults to complete input buffer
%   interactive_flag: Optional. Defaults to false. If present and true user
%                   can choose threshold to use when multiple thresholds are found
%   Output:
%				Index of threshold crossing in buffer
%				Note: Can have fractional part as interpolation is used
%
% Remarks
%   Returns with empty result (and prints warning) if zero or multiple
%   thresholds found, unless interactive_flag is true (for multiple
%   thresholds)

%
thdat=0;
thdir=1;
[abint,abnoint,abscalar,abnoscalar]=abartdef;

if nargin>1
   if length(thspec)==1 thdat=thspec; end;
   if length(thspec)==3
      thdat=thspec(1)+((thspec(2)-thspec(1))*thspec(3));
   end;
end;
if nargin>2
   thdir=dir;
   thdat=thdat*thdir;
end;

xx=x*thdir;               %handle positive/neg.

lx=length(xx);
xsh=xx(2:lx);
loguk=1;higuk=lx;
if nargin > 3
   if length(indexrange) ==2
      if indexrange(2)>=indexrange(1)
         loguk=indexrange(1);
         higuk=indexrange(2);
      end;
   end;
end;

interflag=0;
if nargin>4 interflag=interactive_flag; end;




%disp ('thspec');
%disp (thspec);
%disp ('dir')
%disp (dir)
%disp ('indexrange');
%disp (indexrange);
%disp ('length(x)');
%disp (length(x));





vz=find((xsh>=thdat)&(xx(1:(lx-1))<thdat));

anavv=find(vz>=loguk & vz<=higuk);
%disp('findth')
%keyboard;

anapostmp=[];
nthresh=length(anavv);
if nthresh~=1;
   disp (['Warning! Number of thresholds : ' int2str(nthresh)]);
   disp ('Threshold spec');
   disp (thspec);
   disp (['Direction ' int2str(thdir)]);

   if (nthresh>1) & (interflag)
       mythresh=abart('Choose threshold to use',1,1,nthresh,abscalar,abint);
   ap=vz(anavv(mythresh));
   
%simple linear interpolation
   ap=interp1([xx(ap) xx(ap+1)],[ap ap+1],thdat);
   
   anapostmp=ap;
end;
       
   
else
   
   ap=vz(anavv(1));
   
%simple linear interpolation
   ap=interp1([xx(ap) xx(ap+1)],[ap ap+1],thdat);
   
   anapostmp=ap;
   
end;

v=anapostmp;

