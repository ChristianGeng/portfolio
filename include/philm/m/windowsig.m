function winsig=windowsig(data,winfunc,winlen)
% WINDOWSIG: Window signals (also fade in/out)
% function winsig=windowsig(data,winfunc,winlen)
% windowsig: Version 21.10.08
%
%   Syntax
%       data: input data (vector)
%       winfunc: Name of window function (will be passed to feval)
%       winlen: If empty or missing: Input signal is windowed with the window function
%           If scalar, start and end of the signal are windowed with first
%           and second half respectively of a window of length 2*winlen
%           samples.
%           If two-element vector, separate length specifications for start
%           and end

nwin=[];

ndata=length(data);

if nargin>2 nwin=winlen; end;

winsig=data;
if isempty(nwin)
    mywin=feval(winfunc,ndata);
    winsig=data.*mywin;
    return;
end;

if length(nwin)==1
    if nwin*2 > ndata
        disp('windowsig: window shortened to match data length');
        nwin=floor(ndata/2);
    end;
    
    mywin=feval(winfunc,nwin*2);
    winsig=data;
    winsig(1:nwin)=winsig(1:nwin).*mywin(1:nwin);
    winsig((end-nwin+1):end)=winsig((end-nwin+1):end).*mywin((nwin+1):end);
    return;    
end;
if length(nwin)==2
    tmpn=nwin;
    winsig=data;
    tmpsum=0;    
    nwin=tmpn(1);
    if nwin>0
        if nwin > ndata
            disp('windowsig: window shortened to match data length');
            nwin=ndata;
        end;
        tmpsum=tmpsum+nwin;
        mywin=feval(winfunc,nwin*2);
        winsig(1:nwin)=winsig(1:nwin).*mywin(1:nwin);
    end;
    nwin=tmpn(2)
    if nwin>0
        if nwin > ndata
            disp('windowsig: window shortened to match data length');
            nwin=ndata;
        end;
        tmpsum=tmpsum+nwin;
        
        mywin=feval(winfunc,nwin*2);
        winsig((end-nwin+1):end)=winsig((end-nwin+1):end).*mywin((nwin+1):end);
    end;
    if tmpsum>ndata
        disp('windowsig: some data windowed twice');
    end;
    
    return;
end;

if length(nwin)>2
    disp('windowsig: bad input spec for window length. Output signal not changed');
    return;
    
end;
