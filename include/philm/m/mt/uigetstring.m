function mystring=uigetstring(arg)
% function mystring=uigetstring(arg)
% UIGETSTRING Use uicontrol editable text box to get string
% uigetstring: Version 23.9.99
%
%	Syntax
%		arg is an optional prompt string

myprompt='';
if nargin myprompt=arg;end;
if ~ischar(myprompt)
	set(gcbo,'userdata',1);   
   return;
else
   if isempty(myprompt) myprompt='>';end;
   xb=0.25;yb=0.5;
   ht=uicontrol('style','text','string',myprompt,'fontsize',12,'units','normalized','position',[xb yb 0.25 0.25]);
   te=get(ht,'extent');
   set(ht,'position',[xb yb te(3) te(4)]);
   he=uicontrol('style','edit','fontsize',12,'units','normalized','position',[xb+te(3) yb 0.5 te(4)],'units','normalized','callback','uigetstring(1)','horizontalalignment','left','userdata',0);
   figure(gcf);
   drawnow;
   waitfor(he,'userdata',1);
   
   mystring=get(he,'string');
   delete([ht;he]);
   
   
   
end;
