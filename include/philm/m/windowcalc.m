function dataout=windowcalc(datain,myfunc,winlenp,winshiftp);
% WINDOWCALC Calculate function results for overlapping windows of data
% function dataout=windowcalc(datain,myfunc,winlenp,winshiftp);
% WINDOWCALC: Version 08.06.2004

x=datain;

%allow for window length, so first value is still at t0 (may not be very
%accurate)
winp2=round(winlenp/2);
tmp=x(winp2:-1:1);
x=[tmp;x];

%winipi=[1 zwinp];
nd=length(x);
frameend=(winlenp:winshiftp:nd)';
winipi=[frameend-winlenp+1 frameend];
nframe=length(frameend);
dataout=ones(nframe,1)*NaN;
for ii=1:nframe 
    xtmp=x(winipi(ii,1):winipi(ii,2));
    try
    dataout(ii)=feval(myfunc,xtmp);
catch
    disp('WINDOWCALC: Problem with function evaluation');
    disp(lasterr);
    return;
end;

end;

