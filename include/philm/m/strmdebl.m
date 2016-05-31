function ss=strmdebl(sm)
% STRMDEBL Trim string matrix removing internal blanks;
% function ss=strmdebl(sm)
% strmdebl: Version 2.12.97
%

%
        [nrow,ncol]=size(sm);
        ss=setstr(ones(nrow,ncol)*blanks(1));
        maxcol=0;

        for ii=1:nrow
            t=sm(ii,:);
            t=deblank(t);
            t=strrep(t,' ','');
            lt=length(t);
            maxcol=max([maxcol lt]);
            if lt
               ss(ii,1:lt)=t;
            end;

        end;
        ss=ss(:,1:maxcol);
