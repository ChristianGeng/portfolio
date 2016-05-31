function hl=barhatch(hp,mylinew);
% BARHATCH Add hatching to bars
% function hl=barhatch(hp,mylinew);
% barhatch: Version 9.11.07
%
%   Syntax
%       hp: Contains the handles to the patch objects forming the bars
%       mylinew: (optional; default=2) linewidth for hatching
%       hl: Line handles of the hatching
%
%   See Also
%       BAR

np=length(hp);

%mymode=str2mat('horizontal','slantright','slantleft','cross','cross','none');

modelist=str2mat('full','none','horizontal','slantright','slantleft','cross','cross');
anglelist=[NaN NaN;NaN NaN;0 NaN;45 NaN;-45 NaN;45 -45;45 -45];
linelist=str2mat('none','none','-','-','-','-',':');

nmode=size(modelist,1);

maxang=size(anglelist,2);
mylim=get(gca,'ylim');

linedist=diff(mylim)/50;

%really also depends on box aspect ratio, or figure size
angfac=diff(get(gca,'ylim'))/diff(get(gca,'xlim'));

%patch line width must be at least the linewidth of the hatching
mylinewidth=2;
if nargin>1 mylinewidth=mylinew; end;

%mylinestyle=':';		%dotted
%mylinestyle='-';		%solid



set(hp,'linewidth',mylinewidth);


for ip=1:np
   xd=get(hp(ip),'xdata');
   yd=get(hp(ip),'ydata');
   
   nb=size(xd,2);
   hatchx=[];hatchy=[];
   
   ipm=rem(ip-1,nmode)+1;
   curmode=deblank(modelist(ipm,:));
   %catch bad mode
   
   
   curangleb=anglelist(ipm,:)*(pi/180);
   for ib=1:nb
      y0=yd(1,ib);
      y1=yd(2,ib);
      x0=xd(1,ib);
      x1=xd(3,ib);
      xdiff=x1-x0;
      
      nh=ceil((max([y0 y1])-min([y0 y1]))/linedist);
    myinc=1;
    if y1<y0
        myinc=-1;
        nh=-nh;
    end;
    
      
      
      for iang=1:maxang
         curangle=curangleb(iang);
         if ~isnan(curangle)
            
            for ih=0:myinc:nh
               tmp0=y0+(ih-1)*linedist;
               ydiff=angfac*xdiff*tan(curangle);
               tmp1=tmp0+ydiff;         
               
               %make sure in range 
               
               if tmp0>=min([y0 y1]) & tmp0<=max([y0 y1]) & tmp1>=min([y0 y1]) & tmp1<=max([y0 y1]) 
                  hatchx=[hatchx;x0;x1;NaN];
                  hatchy=[hatchy;tmp0;tmp1;NaN];
               end;
               
            end;
         end;		%angle ~NaN
      end;		%angle loop
      
   end;
   
   %draw the line
   
%   keyboard;
   hl(ip)=line('xdata',hatchx,'ydata',hatchy,'color','k','linestyle',deblank(linelist(ipm,:)),'linewidth',mylinewidth);
   if strcmp(curmode,'full')
      set(hp(ip),'facecolor','k');
   else
      set(hp(ip),'facecolor','none');
   end;
   
end;
