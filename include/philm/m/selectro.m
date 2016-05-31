function [sbuf,vi]=selectro(x,sp,sv,sc,junc);
% SELECTRO Select rows from matrix
% function [sbuf,vi]=selectro(x,sp,sv,sc,junc);
% selectro: Version 30.7.97
%
% Syntax
%   Input arguments:
%        x: Input data matrix
%        sp, sv: Vectors of selection parameters and selection values
%        sc: String matrix of selection conditions (e.g '==', '>' etc.)
%        junc: Optional. Conjunction of selections, currently only '&' (and) or '|' (or).
%              Same conjunction applied to all subselections. Defaults to 'and'.
%   Output arguments:
%        sbuf: matrix of selected data
%        vi: Optional. Row index in input matrix of selected data
%
% Notes
%   Not yet any explicit checks for illegal selection conditions or conjunction

        if nargin < 5 junc='&';end;
        ncond=length(sp);
        %check sp, sv and sc all the same size; check conjunction legal
        bigstr='vv=find(';
        for ii=1:ncond
            ss=['(x(:,' int2str(sp(ii)) ')' strtok(sc(ii,:)) num2str(sv(ii)) ')'];
            bigstr=[bigstr ss junc];
        end;
        %replace last conjunction with final closing bracket
        bigstr(length(bigstr))=')';
        disp (['selectro: ' bigstr]);

        %error trap ....

        eval ([bigstr ';']);
        sbuf=[];
        if ~isempty(vv) sbuf=x(vv,:);end;
        if nargout>1 vi=vv; end;
