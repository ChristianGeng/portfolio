function mt_zoom2(clist,power);
% mt_zoom2 Zoom vertical scale
% function mt_zoom2(clist,power);
% mt_zoom2: Version 20.4.98
%
% Syntax
%   clist: String matrix of axes in mt_f(t)
%   power: Optional, defaults to 1. Power of 2 to zoom by (positive expands signal, negative contracts)
%
% See also
%   mt_sextr to set scaling explicitly; mt_gextr

        if (nargin<2) power=1;end;
        power=round(power);
        power=2.^(-power);

ylim=mt_gextr(clist);
ylim=ylim.*power;
mt_sextr(clist,ylim);

