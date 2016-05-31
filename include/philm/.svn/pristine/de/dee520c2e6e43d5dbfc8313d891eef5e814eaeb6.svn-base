function ds=rv2strm(mystring,delim);
% RV2STRM string row vector with delimiters to string matrix
% function ds=rv2strm(mystring,delim);
% rv2strm: Version 23.5.97
%
% Syntax
%   Default delimiter is blank
%
% See Also
%   strm2rv: String matrix to row vector

        if nargin<2 delim=' ';end;
        [ds,rests]=strtok(mystring,delim);
        while ~isempty(rests)
        [ts,rests]=strtok(rests,delim);
        ds=str2mat(ds,ts);
        end;
