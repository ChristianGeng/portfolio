function mytime=mt_gdtim;
% mt_gdtim Return start and end times (in s) of current time-wave display window
% function mytime=mt_gdtim;
% mt_gdtim: Version 13.4.98
%
% Syntax
%   mytime is a 2-element vector
%
% See also
%   mt_sdtim to set display time
%

	figh=mt_gfigh('mt_f(t)');


        hca=findobj(figh,'tag','cursor_axis');
        mytime=get(hca,'xlim');
