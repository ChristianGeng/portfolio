function ss=strm2rv(sm,delim);
% STRM2RV String matrix to row vector with crlf or other delimiter
% function ss=strm2rv(sm,delim);
% strm2rv: Version 1.9.97
%
% Syntax
%   delim is optional. Defaults to crlf
%		note: the last item will also be followed by the delimiter, which
%		is usually ok for <crlf> but may be undesirable with things like blank
%
% See Also
%   rv2strm: row vector with delimiter to string matrix

%
        if nargin==1 delim=crlf;end;
        nrow=size(sm,1);
        ss='';
        for ii=1:nrow
            t=sm(ii,:);
            t=deblank(t);
            ss=[ss t delim];
        end;
