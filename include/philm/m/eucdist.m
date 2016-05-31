function d=eucdist(data,v);
% EUCDIST Calculate euclidean distance for 2d data
% function d=eucdist(data,v);
% eucdist: Version 6.6.97
%
% Syntax
%   v is 4-element vector specifying columns in data: x1, x2, y1, y2

	d=(data(:,v(1))-data(:,v(2)))+i*(data(:,v(3))-data(:,v(4)));
        d=abs(d);
