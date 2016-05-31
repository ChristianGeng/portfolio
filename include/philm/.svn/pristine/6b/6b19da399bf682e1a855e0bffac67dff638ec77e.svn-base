function reclevel(sf,timebase)
% RECLEVEL Check recording level from soundcard
% function reclevel(sf,timebase)
% reclevel: Version ???

ichan=1;
npoint=1000;
nchunk=sf*timebase;
nwin=floor(nchunk/npoint);
nchunk=npoint*nwin;

hf=figure;

hao=subplot(2,1,1);
hlo=line((1:npoint)',zeros(npoint,1),'erasemode','xor','color','r');
ylim([-60 0]);
grid on

ham=subplot(2,1,2);
mvec=ones(npoint,1)*-40;
hlm=line((1:npoint)',mvec,'erasemode','xor','color','g');

ylim([-40 0]);
grid on;

ipi=0;
finished=0;
keyboard;
while ~finished
y=wavrecord(nchunk,sf,ichan);
disp(ipi)
y=reshape(y,[nwin npoint]);
ym=20*log10(max(abs(y)));
set(hlo,'ydata',ym');
ymm=max(ym);
ipi=mod(ipi,npoint);
ipi=ipi+1;
mvec(ipi)=ymm;
set(hlm,'ydata',mvec);
end;
