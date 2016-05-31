function mystring=myuigetstring(arg)
% function mystring=myuigetstring(arg)
% MYUIGETSTRING Use uicontrol editable text box to get string
% myuigetstring: Version 18.9.01
%
%	Syntax
%		arg is an optional prompt string
%
%	Description
%		Same as uigetstring, but places pointer in centre of editable box (and restores position afterwards)

myprompt='';
if nargin myprompt=arg;end;
if ~ischar(myprompt)
	set(gcbo,'userdata',1);   
   return;
else
   if isempty(myprompt) myprompt='>';end;
   oldmousep=get(0,'pointerlocation');
   figpos=get(gcf,'position');
   xb=0.25;yb=0.5;
   ht=uicontrol('style','text','string',myprompt,'fontsize',12,'units','normalized','position',[xb yb 0.25 0.25]);
   te=get(ht,'extent');
   set(ht,'position',[xb yb te(3) te(4)]);
   he=uicontrol('style','edit','fontsize',12,'units','normalized','position',[xb+te(3) yb 0.5 te(4)],'units','normalized','callback','uigetstring(1)','horizontalalignment','left','userdata',0);
   
   %calculate centre of edit box
   midx=xb+te(3)+0.5/2;
   midy=yb+te(4)/2;
   
   mousep=figpos(1:2)+[midx*figpos(3) midy*figpos(4)];
   set(0,'pointerlocation',mousep);
   
   figure(gcf);
   drawnow;
   waitfor(he,'userdata',1);
   
   mystring=get(he,'string');
   delete([ht;he]);
   
   set(0,'pointerlocation',oldmousep);
   
   
end;
