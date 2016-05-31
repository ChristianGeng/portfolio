function daf_demo(delaytime)
% DAF_DEMO Delayed auditory feedback demo
% function daf_demo(delaytime)
% daf_demo: Version 9.10.07
%
%   Notes
%       short delay time (< ca. 150ms) only worked with high samplerate
%       cf. note in mt_audio that windows audio has problems with short output sequences
%       seems to be a fairly long fixed delay regardless of delaytime setting
%       so by no means all potentially interesting delaytimes are currently
%       feasible.
%   callback function DAF_DEMO_CB must be present

samplerate=44100;
%delaytime=0.1;
delaysamp=round(samplerate*delaytime);
%delaysamp=1024;
%disp(delaysamp/samplerate);

hai = analoginput('winsound');
hao = analogoutput('winsound');
hchanin=addchannel(hai,1);
hchanout=addchannel(hao,1);

set(hai,'samplerate',samplerate);
set(hao,'samplerate',samplerate);
set(hai,'samplespertrigger',inf);

set([hai hao],'triggertype','manual');
set(hai,'manualtriggerhwon','trigger');

nbuf=round((20*samplerate)/delaysamp);
disp(nbuf);
set(hai,'bufferingconfig',[delaysamp nbuf]);
%set(hao,'bufferingconfig',[delaysamp 200]);


set(hao,'samplesoutputfcn',{'daf_demo_cb',hai,delaysamp});
set(hao,'samplesoutputfcncount',delaysamp);



%keyboard;

daqdone=ones(200,1)*NaN;
addone=ones(200,2)*NaN;

zdat=int16(zeros(round(delaysamp*3),1));
putdata(hao,zdat);
start([hai hao]);
trigger([hai hao]);


keyboard;

stop(hai);
delete(hai);
%clear(hai);
stop(hao);
delete(hao)



return;



%hl=plot(zeros(delaysamp,1));
%set(hl,'erasemode','xor');
%ylim([-30000 30000])
for ii=1:round(5/delaytime)
%    disp(ii)
%while ~finished
%addone(ii,1)=get(hai,'SamplesAcquired');

mydat=getdata(hai,delaysamp,'native');
%addone(ii,2)=get(hai,'SamplesAcquired');
    %set(hl,'ydata',mydat);
%drawnow;
%    daqdone(ii)=get(hao,'samplesavailable');
        putdata(hao,mydat);
%if ii==1 trigger(hao); end;
        %    if ~aorunning 
%        start(hao);
%        aorunning=1;
%    end;
%    daqdone(ii)=get(hao,'samplesoutput');
%    daqdone(ii)=strcmp(get(hao,'sending'),'On');
end;

keyboard;


stop(hai);
delete(hai);
%clear(hai);
stop(hao);
delete(hao)

