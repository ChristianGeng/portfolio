function newstatus=mt_newft(iflag);
%mt_newft set or get new data flag for f(t) data
% function newstatus=mt_newft(iflag);
% mt_newft: Version 2.10.98
%
% Syntax
%	If there is any input argument set or clear the newdata flag
%	If there is no input argument, return the current setting
%
% See Also
%	mt_shoft, mt_sdtim, mt_setft

figS=mt_getft;

if nargin
	figh=mt_gfigh('mt_f(t)');
	haxc=findobj(figh,'tag','cursor_axis');
	titleh=get(haxc,'title');
   if iflag
      figS.new_data_flag=1;
		set(titleh,'visible','off');
   else
      figS.new_data_flag=0;
		set(titleh,'visible','on');
   end;
   set(figh,'userdata',figS);
else
   newstatus=figS.new_data_flag;
end;
