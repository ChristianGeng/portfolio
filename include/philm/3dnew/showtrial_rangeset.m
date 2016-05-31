function showtrial_rangeset(centerco,myrange);
% showtrial_rangeset Set ranges of position data in show_trialox graphics
% function showtrial_rangeset(centerco,myrange);
% showtrial_rangeset: Version 19.09.2010
%
%	Syntax
%		centerco: If numeric: 3-element vector giving center coordinate for
%			x, y and z axes. (if wrong length, or empty, set automatically to
%			[0 0 0])
%		if character: can be 'rms' or 'tan', or an axes title. Then myrange specifies upper
%			limit for these axes
%		myrange: Always scalar. For numeric centerco range of x, y and z
%			position axes is set to [centerco-myrange centerco+myrange], i.e
%			all axes are forced to have same scaling
%
%	See Also
%		SHOW_TRIALOX

myrange=myrange(1);		%must be scalar

if ischar(centerco)
	idone=0;
	hh=findobj('tag',centerco);
	if ~isempty(hh)
		set(hh,'ylim',[0 myrange]);
		idone=1;
	end;
	if ~idone
		if strcmp(centerco,'rms')
			hh=findobj('tag','rms');
			set(hh,'ylim',[0 myrange]);
		end;
		if strcmp(centerco,'tan')
			hh=findobj('tag','Tangential Vel.');
			set(hh,'ylim',[0 myrange]);
		end;
	end;

	return;
end;



if length(centerco)~=3 centerco=[0 0 0]; end;

xr=[centerco(1)-myrange centerco(1)+myrange];
yr=[centerco(2)-myrange centerco(2)+myrange];
zr=[centerco(3)-myrange centerco(3)+myrange];

hh=findobj('tag','Position');
set(hh,'xlim',xr,'ylim',yr,'zlim',zr);

hh=findobj('tag','posx');
set(hh,'ylim',xr);

hh=findobj('tag','posy');
set(hh,'ylim',yr);

hh=findobj('tag','posz');
set(hh,'ylim',zr);
