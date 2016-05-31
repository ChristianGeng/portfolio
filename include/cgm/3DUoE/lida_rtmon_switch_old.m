function lida_rtmon_switch(recpath,displaychans)
% lets you choose your tcp method
% LIDA_RTMON RT AG500 display; copy trials from lida to control server
% function lida_rtmon(recpath,displaychans)
% lida_rtmon: Version 15.08.08
%
%   Description
%       recpath: optional. If present, copy data from lida to control
%       server after completion of each trial
%       displaychans: optional. Default to 1:12
%       Graphic properties can be adjusted interactively using context menu
%       set up by setcontextmenu (right click on object; object tag is
%       displayed; left click on this to open the property inspector for this
%       object) but in practice adjustments will probabably be better done from the
%       keyboard prompt (e.g set up some scripts with useful settings)
%
%   See Also SETCONTEXTMENU

%things to do
% dummy axes for legend
% axes for time display of chosen signal
% no-graphics mode, i.e just copy amp files and compute amp statistics

  

% method='jvm';
method='bin';
  
nsensor=12;
ndim=6;
ndig=4;
ampfac=1000;

%Buffer for position data while trial is being recorded
BSIZE=200;      %store up to 10s at 20/s
BD=ones(nsensor,7,BSIZE)*NaN;
BT=ones(BSIZE,1)*NaN;
BPOINT=1;

amppath='';
if nargin

    mypath=recpath;
    if ~isempty(recpath)
        mkdir(['/srv/ftp/data/' mypath '/amps']);
        system(['chmod -R g+w /srv/ftp/data/' mypath]);
        amppath=['/srv/ftp/data/' mypath '/amps/'];
    end;

end;

chanlist=1:12;
if nargin>1 chanlist=displaychans; end;


%needed for tcip socket
if strcmp(method,'jvm')
  import java.io.*;
  import java.net.*
elseif strcmp(method,'bin')
else, end;


% this should be placed in startup.m
%javaaddpath('/home/csop/matlab/Phil/3dnew/lida/java/recmon/dist/recmon.jar');



% %should read this from somewhere
%      s = Socket('141.84.138.216',30303);
%      %% set timeout for reading operations, otherwise application might
%      %% block. A timeout exception will be thrown which will have to be
%      %% caught.
%      s.setSoTimeout(100);
%      si = s.getInputStream;
%      so = s.getOutputStream;


if strcmp(method,'jvm')
  try
    [s,si,so]=lida_connect(100);
  catch
    error('Failed to connect. Is "cs5recorder" running?');
  end
elseif strcmp(method,'bin')
  try
    CS = rtstream_connect
    s=CS.con; % not sure whether I want that 
  catch
    error('Failed to connect. Is "cs5recorder" running?');
  end
else, 
end

%test
%s=1;

%better as input argument?
timerperiod=1/20;
%length of orientation vectors in mm
orilength=10;

deg2rad=pi/180;

%trajview=[90 0;0 0;90 -90;-37.5 30];
%view settings for the 3 trajectory axes
trajview=[90 0;0 0;90 -90];


hf=figure;


htimer=timer('startdelay',0,'executionmode','fixedrate','period',timerperiod,'timerfcn',{@lida_rtmon_timercb,hf});


%first call seems to return all zeros, so do twice


if strcmp(method,'jvm')
  try
    [active,sample,sweep,dataS,dataC,pos] = getEmaAll (s);
    [active,sample,sweep,dataS,dataC,pos] = getEmaAll (s);
  catch
    error(['An error occured when trying to read from the socket.']);
  end
elseif strcmp(method,'bin')
  try
    [active,sample,sweep,dataS,dataC,pos] = getEmaData(s);
  catch
    error(['An error occured when trying to read from the socket.']);
  end
else, 
end;

pegel=eucdistn(dataS,zeros(size(dataS)));
pos(:,7)=pegel*ampfac;

%test
%active=0;


%set up graphics


userdata.method=method;
userdata.socket=s;
userdata.timerhandle=htimer;
userdata.timerperiod=timerperiod;
userdata.active=active;
userdata.sample=sample;
userdata.sweep=sweep;
userdata.dataS=dataS;
userdata.dataC=dataC;
userdata.pos=pos;
userdata.chanlist=chanlist;
userdata.orilength=10;          %length of orientation vector in mm
userdata.amppath=amppath;

userdata.BSIZE=BSIZE;
userdata.BPOINT=BPOINT;
userdata.BD=BD;
userdata.BT=BT;


mycols=hsv(nsensor+1);
mymarker={'+','o','*','x','square','diamond','v','^','>','<','pentagram','hexagram'};

nax=3;
sprow=2;
spcol=2;
nchan=length(chanlist);

%tmpdig=length(int2str(max(chanlist));
chanstr=int2str(chanlist');


hl=ones(nchan,nax);     %current position and orientation
hltraj=ones(nchan,nax); %position trace during trial recording
hlall=ones(1,nax);
oridata=ones(nsensor,3);
[oridata(:,1),oridata(:,2),oridata(:,3)]=sph2cart(pos(:,4)*deg2rad,pos(:,5)*deg2rad,orilength);


%all axes are actually 3D plots that are identical except for the view setting
%this makes updating very simple. However, zooming might be easier with 3
%different 2D plots
for ii=1:nax
    hax(ii)=subplot(sprow,spcol,ii);
    xlabel('X (mm)');
    ylabel('Y (mm)');
    zlabel('Z (mm)');
    set(gca,'tag',['view' int2str(ii)]);
    set(gca,'view',trajview(ii,:));
    axis square;
    for jj=1:nchan
        ichan=chanlist(jj);
        tmpco=ones(2,3)*NaN;
        tmpco(1,:)=pos(ichan,1:3);
        tmpco(2,:)=pos(ichan,1:3)+oridata(ichan,:);
        hl(jj,ii)=line('xdata',tmpco(:,1),'ydata',tmpco(:,2),'zdata',tmpco(:,3),'color',mycols(ichan,:),'marker',mymarker{ichan},'linewidth',2,'tag',['S' int2str(ichan) '_posori'],'clipping','off');
        bb=squeeze(BD(ichan,1:3,:));
        bb=bb';
        hltraj(jj,ii)=line('xdata',bb(:,1),'ydata',bb(:,2),'zdata',bb(:,3),'color',mycols(ichan,:),'linewidth',1,'tag',['S' int2str(ichan) '_trajectory'],'clipping','off');
    end;
    hlall(ii)=line('xdata',pos(chanlist,1),'ydata',pos(chanlist,2),'zdata',pos(chanlist,3),'color','k','marker','o','linewidth',2,'linestyle','none','tag','all_positions','clipping','off');
    if ii==1
        hleg=legend(hl(:,1),chanstr);
        set(hleg,'tag','legend','Location','BestOutside');
    end;
end;

hax(nax+1)=subplot(sprow,spcol,nax+1);
ht=text(0,0,[chanstr blanks(nchan)' num2str(pos(chanlist,:),'%7.1f')],'fontsize',9);
xtmp=get(ht,'extent');
set(gca,'xlim',[xtmp(1) xtmp(1)+xtmp(3)],'ylim',[xtmp(2) xtmp(2)+xtmp(4)]);
set(ht,'clipping','off','tag','list_display');
htit=title(['x, y, z, phi, theta, rms(resid), rms(amp)*' int2str(ampfac)]);
set(gca,'visible','off');
set(htit,'visible','on','tag','list_title');

userdata.hl=hl;
userdata.hlall=hlall;
userdata.ht=ht;
userdata.hltraj=hltraj;

set(hf,'doublebuffer','on','tag','lida_rtmon');

set(hax(1:nax),'xlim',[-100 100],'ylim',[-100 100],'zlim',[-100 100]);
set(hf,'userdata',userdata);
setcontextmenu(findobj(hf),hf);
disp('Type return to start timer');
keyboard;
start(htimer);
disp('Type return to stop');
keyboard;

stop(htimer);
delete(htimer);

if strcmp(method,'jvm')
  s.close;
elseif strcmp(method,'bin')
    pnet(s,'close')
else, 
end

function lida_rtmon_timercb(cbobj,cbdata,hf)

deg2rad=pi/180;
ndig=4;
ndim=6;
ampfac=1000;

userdata=get(hf,'userdata');

chanlist=userdata.chanlist;
nchan=length(chanlist);
hlall=userdata.hlall;
hl=userdata.hl;
ht=userdata.ht;

  if strcmp(userdata.method,'jvm'),
    while 1
      try
        [active,sample,sweep,dataS,dataC,pos] = getEmaAll (userdata.socket)
      catch
        disp(['I think I lost the connection...' crlf 'Type return when ready to reconnect!']);
        userdata.socket.close; %close the socket in any case, maybe timeout
                               %was for different reasons than a broken
                               %socket
        keyboard;
        while 1
          try
            userdata.socket=lida_connect(100);
            connected=true;
          catch
            disp('Failed to connect. Is "cs5recorder" running?');
            disp('Type return to try again.');
            keyboard;
            continue;
          end
          disp('Type return to stop');
          break;
        end
        continue;
      end
      break;
    end
  elseif strcmp(userdata.method,'bin')
   while 1
      try
%        [active,sample,sweep,dataS,dataC,pos] = getEmaAll (userdata.socket)
        [active,sample,sweep,dataS,dataC,pos] = getEmaData(userdata.socket);
      catch
        disp(['I think I lost the connection...' crlf 'Type return when ready to reconnect!']);
        pnet(userdata.s,'close')
        % userdata.socket.close; %close the socket in any case, maybe timeout
                               %was for different reasons than a broken
                               %socket
        keyboard;
        while 1
          try
            CS = rtstream_connect
            userdata.socket=CS.con; % not sure whether I want that  
            %userdata.socket=lida_connect(100);
            connected=true;
          catch
            disp('Failed to connect. Is "cs5recorder" running?');
            disp('Type return to try again.');
            keyboard;
            continue;
          end
          disp('Type return to stop');
          break;
        end
        continue;
      end
      break;
    end
  end

    
  
  %    CS = rtstream_connect
%    s=CS.con; % not sure whether I want that  
    
    
    
    
pegel=eucdistn(dataS,zeros(size(dataS)));
pos(:,7)=round(pegel*ampfac);

BD=userdata.BD;
BT=userdata.BT;
BSIZE=userdata.BSIZE;
BPOINT=userdata.BPOINT;


oldactive=userdata.active;
%new trial has started. Get relative time in trial; activate trace?
if active & ~oldactive
    tic;
    BD(:,:,:)=NaN;
    BT(:)=NaN;
    BPOINT=1;

end;

if active
    set(hf,'name',['Trial ' int2str(sweep) ' running: ' num2str(toc) 's']);
    BD(:,:,BPOINT)=pos;
    BT(BPOINT)=toc;
    BPOINT=BPOINT+1;
    if BPOINT>BSIZE BPOINT=1; end;
    BD(:,:,BPOINT)=NaN;
    hltraj=userdata.hltraj;
    for jj=1:nchan
        ichan=chanlist(jj);
        tmpco=squeeze(BD(ichan,1:3,:));
        tmpco=tmpco';
        set(hltraj(jj,:),'xdata',tmpco(:,1),'ydata',tmpco(:,2),'zdata',tmpco(:,3))

    end;
end;

trialfinished=0;
if ~active & oldactive
    %timnum=[get(userdata.timerhandle,'AveragePeriod') userdata.timerperiod];
%ring buffer may have wrapped round
    btmp=BT(BPOINT:BSIZE);
    if BPOINT>1
        btmp=[btmp;BT(1:(BPOINT-1))];
    end;
    
    timnum=[nanmean(diff(btmp)) userdata.timerperiod];
    timnum=int2str(round(1./timnum));
    set(hf,'name',['Trial ' int2str(sweep-1) ' lasted ' num2str(toc) 's. Timer rate (Hz: actual,set): ' timnum]);
    trialfinished=1;
end;


%disp(pos);
oridata=ones(size(pos,1),3);
[oridata(:,1),oridata(:,2),oridata(:,3)]=sph2cart(pos(:,4)*deg2rad,pos(:,5)*deg2rad,userdata.orilength);

set(hlall,'xdata',pos(chanlist,1),'ydata',pos(chanlist,2),'zdata',pos(chanlist,3))
for jj=1:nchan
    ichan=chanlist(jj);
    tmpco=ones(2,3)*NaN;
    tmpco(1,:)=pos(ichan,1:3);
    tmpco(2,:)=pos(ichan,1:3)+oridata(ichan,:);
    set(hl(jj,:),'xdata',tmpco(:,1),'ydata',tmpco(:,2),'zdata',tmpco(:,3))

end;
chanstr=int2str(chanlist');

set(ht,'string',[chanstr blanks(nchan)' num2str(pos(chanlist,:),'%7.1f')]);
userdata.active=active;
userdata.sample=sample;
userdata.sweep=sweep;
userdata.dataS=dataS;
userdata.dataC=dataC;
userdata.pos=pos;

userdata.BPOINT=BPOINT;
userdata.BD=BD;
userdata.BT=BT;



set(hf,'userdata',userdata);

if trialfinished
    amppath=userdata.amppath;
    if ~isempty(amppath)
        trials=int2str0(sweep-1,ndig);
        ampname=[userdata.amppath trials '.amp'];

        [mystat,myresult]=system(['echo "/srv/data/' trials '.* ' amppath '" | rcplidaop']);
        disp(mystat);
        disp(myresult);
        data=loadampb(ampname);
        disp(['max, min, max(abs(diff)) signal level * ' num2str(ampfac)]);
        for jj=1:nchan
            ichan=chanlist(jj);
            tmpdata=data(:,1:ndim,ichan)*ampfac;
            pegel=eucdistn(tmpdata,zeros(size(tmpdata)));
            disp([int2str(ichan) ' ' int2str([max(pegel) min(pegel) max(abs(diff(pegel)))])]);

        end;
    end;

end;
%function [active,sample,sweep,dataS,dataC,pos] = getEmaAll (s);
%pos=rand(12,7);
%dataS=rand(12,6);
%dataC=dataS;
%active=round(rand(1));
%sample=1;
%sweep=1;
function showbuffer
userdata=get(findobj('type','figure','tag','lida_rtmon'),'userdata');
bd=userdata.BD;
bt=userdata.BT;
BPOINT=userdata.BPOINT;
BSIZE=userdata.BSIZE;

chanlist=userdata.chanlist;
nchan=length(chanlist);
chanstr=int2str(chanlist');

bd=bd(chanlist,:,:);
npar=size(bd,2);
disp('Ring buffer statistics (min, mean, max)');
for ipar=1:npar
    disp(['Parameter ' int2str(ipar)]);
    tmpd=(squeeze(bd(:,ipar,:)))';
    mymin=nanmin(tmpd);
    mymax=nanmax(tmpd);
    mymean=nanmean(tmpd);
    
    disp([chanstr blanks(nchan)' num2str([mymin' mymean' mymax'])]);
end;

disp('min, mean, max and sd of time interval');
    btmp=bt(BPOINT:BSIZE);
    if BPOINT>1
        btmp=[btmp;bt(1:(BPOINT-1))];
    end;

dt=diff(btmp);
disp([nanmin(dt) nanmean(dt) nanmax(dt) nanstd(dt)]);
