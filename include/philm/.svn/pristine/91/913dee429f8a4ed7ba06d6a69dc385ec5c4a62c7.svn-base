function mt_hextr(clist,yrange);
% mt_hextr Homogenize extremes used for signal scaling to same range
% function mt_hextr(clist,ylimlist);
% mt_hextr: Version 07.10.2000
%
%	Syntax
%		clist: String matrix of axes in mt_f(t)
%		yrange: Optional. Set all signals to this range; if absent use maximum range currently set
%	See also
%		MT_GEXTR: Get extremes. MT_SEXTR: Get extremes. MT_ZOOM2: Zoom up and down

ylimlist=mt_gextr(clist);

if isempty(ylimlist) return; end;

if any(isnan(ylimlist(:,1)))
   disp('mt_hextr: Bad axes name?');
   return;
end;

yb=(mean(ylimlist'))';

if nargin>1
   myrange=yrange/2;
else
   myrange=max(ylimlist(:,2)-ylimlist(:,1))/2;
end;

ylimlist=[yb-myrange yb+myrange];

mt_sextr(clist,ylimlist);
