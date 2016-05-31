function dataout=zeroxrate(datain,zwinp,winshiftp,noiseval,samplerate);
% ZEROXRATE Compute zero-crossing rate
% function dataout=zeroxrate(datin,zwinp,winshiftp,noiseval,samplerate);
% ZEROXRATE: Version 13.12.2012
%
%   Syntax
%       zwinp: length of window in data points (note: output signal takes
%           the window delay into account)
%       winshiftp: Window shift in data points
%       noiseval: Noise value. Only data going outside the noise band
%           around zero actually count as zero crossings
%       samplerate: Optional. If present, used to scale the result to zerox
%           per second
x=datain;
xs=x(2:end);
x(end)=[];
xz1=((xs>noiseval) & (x<=noiseval));
xz2=((xs<-noiseval) & (x>=-noiseval));
xz=xz1|xz2;
xz=[xz;0];      %for compatibility with other window calc functions

%could calculate zero crossing rate by filtering xz

%this method in effect doubles the number of zero crossings found
%x(x<noiseval & x>-noiseval)=0;
%xz=sign(x(2:end))~=sign(x(1:end-1));

%allow for window length, so first value is still at t0 (may not be very
%accurate)
zwinp2=round(zwinp/2);
tmp=xz(zwinp2:-1:1);
xz=[tmp;xz];

%winipi=[1 zwinp];
nd=length(xz);
frameend=(zwinp:winshiftp:nd)';
winipi=[frameend-zwinp+1 frameend];
nframe=length(frameend);
dataout=ones(nframe,1)*NaN;
for ii=1:nframe 
%    asum=sqrt(mean(x(winipi(ii,1):winipi(ii,2)).^2));
%    bufout(ii,1)=asum;
    
    zsum=sum(xz(winipi(ii,1):winipi(ii,2)));
    dataout(ii)=zsum;
%    winipi=winipi+winshiftp; 
end;
if nargin>4 dataout=dataout*(samplerate/zwinp); end;
