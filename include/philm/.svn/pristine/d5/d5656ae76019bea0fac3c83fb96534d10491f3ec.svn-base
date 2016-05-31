function prompter_showmsg(mystring)
% function prompter_showmsg(mystring)
% if message is empty no change is made to the text display
% otherwise message is shown, even if prompt text is currently not visible

if isempty(mystring) return; end;

P=prompter_gmaind;
ht=P.texthandle;

%make sure message is visible, but restore current prompt visibility at
%end???
oldvis=get(ht(1),'visible');
set(ht,'visible','on');

prompter_showg(['\fontname{Helvetica}' mystring]);
prompter_dotrafficlights('stop');
%set(ht,'visible',oldvis);
