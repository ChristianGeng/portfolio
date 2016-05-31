function lida_rtmon_switch(recpath,displaychans,timerspec)
% LIDA_RTMON RT AG500 display; copy trials from lida to control server
% function lida_rtmon(recpath,displaychans,timerspec)
% lida_rtmon: Version 19.03.09
%
%   Syntax
%       recpath: optional. If present, copy data from lida to control
%			server after completion of each trial. The program then
%			computes statistics on the rms signal amplitude of each sensor
%			similar to the pegelstats output argument of filteramps.
%			The recpath argument should only be used when the program is
%			running on the control server. The display function can be used
%			on any machine on the network.
%       displaychans: optional. Default to 1:12
%		timerspec: optional. Default to 1/20. Update interval for graphics
%
%	Description
%       Graphic properties can be adjusted interactively using context menu
%			set up by setcontextmenu (right click on object; object tag is
%			displayed; left click on this to open the property inspector for this
%			object) but in practice adjustments will probabably be better done from the
%			keyboard prompt (e.g set up some scripts with useful settings).
%		Statistics of the current contents of the ring buffer of sensor
%			positions can be accessed from the keyboard with 'showbuffer'
%		Some settings can be accessed through the userdata of the figure
%			(e.g length of orientation vector (in mm))
%		The following line should be placed in startup.m (replacing
%			topleveldir as appropriate)
%			javaaddpath([topleveldir 'phil/3dnew/lida/java/recmon/dist/recmon.jar']);
%		cs5recorder must be running before this program is started
%
%	Updates
%		3.09 include timerspec input argument
%
%   See Also SETCONTEXTMENU for interactive graphic settings, FILTERAMPS
%		and PLOTPEGELSTATS for background to amplitude statistics

%things to do
% dummy axes for legend
% axes for time display of chosen signal
% no-graphics mode, i.e just copy amp files and compute amp statistics
%!scp -P 6022 lidaop@cs6lida:/srv/data/0027.amp .

colordef none


global DOLIDACOPY
DOLIDACOPY=1;
if ~DOLIDACOPY
    disp('WARNING: Someone disabled transfer of ampfile, see line 41.')
end

nsensor=12;
ndim=6;
ndig=4;
ampfac=1000;
lidatimeout=200;	%possibly higher value sometimes useful to prevent apparent lost connection?




load lida_cfg
disp(lida)



%Buffer for position data while trial is being recorded
%Did I try using global variables?

BSIZE=200;      %store up to 10s at 20/s
BD=ones(nsensor,7,BSIZE)*NaN;
BT=ones(BSIZE,1)*NaN;
BPOINT=1;
mypath='';
amppath='';
if nargin
    mypath=recpath;
    if ~isempty(recpath)
%         mkdir(['/srv/ftp/data/' mypath '/amps']);
%         system(['chmod -R g+w /srv/ftp/data/' mypath]);
%         amppath=['/srv/ftp/data/' mypath '/amps/'];
%          origusuffix='.orig'
         origsuffix=''
         mkdir(fullfile (mypath,['amps',origsuffix]));      
         amppath=fullfile (mypath,['amps',origsuffix],pathchar)
    end;

end;

chanlist=[];
if nargin>1 chanlist=displaychans; end;
if isempty(chanlist) chanlist=1:12; end;


%needed for tcip socket
import java.io.*;
import java.net.*;
% this should be placed in startup.m




try
    [s,si,so]=lida_connect(lidatimeout);
catch
    error('Failed to connect. Is "cs5recorder" running?');
end

%test
%s=1;

timerperiod=1/20;
if nargin>2 timerperiod=timerspec; end;



%length of orientation vectors in mm
orilength=10;

deg2rad=pi/180;

%trajview=[90 0;0 0;90 -90;-37.5 30];
%view settings for the 3 trajectory axes
trajview=[90 0;0 0;90 -90];
viewlabels=str2mat('COR','SAG','AX');


hf=figure;

htimer=timer('startdelay',0,'executionmode','fixedrate','period',timerperiod,'timerfcn',{@lida_rtmon_timercb,hf});


%first call seems to return all zeros, so do twice
try
    [active,sample,sweep,dataS,dataC,pos] = getEmaAll (s);
    [active,sample,sweep,dataS,dataC,pos] = getEmaAll (s);
catch
    error(['An error occured when trying to read from the socket.' crlf lasterr]);
end
pegel=eucdistn(dataS,zeros(size(dataS)));
pos(:,7)=pegel*ampfac;

%test
%active=0;


% file recpath
 if exist([mypath 'rtmon_cfg'],'file')
            save([mypath 'rtmon_cfg'],'recpath','-append');
        else,   save([mypath 'rtmon_cfg'],'recpath');
end;
        
userdata.recpath=recpath;
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
userdata.mypath=mypath;
userdata.lidatimeout=lidatimeout;
userdata.dig=lida.dig;
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

% cicle ini: 
mm=[0:0.01:2*pi]';
sprad=150;
spfac=1.5; % involved in setting axes limits: they are set to +- spfac * radius of magic spheres  
tmpcrc(:,:,1)=[zeros(size(mm,1),1) sin(mm)*sprad cos(mm)*sprad];
tmpcrc(:,:,2)=[sin(mm)*sprad zeros(size(mm,1),1) cos(mm)*sprad];
tmpcrc(:,:,3)=[ sin(mm)*sprad  cos(mm)*sprad zeros(size(mm,1),1)];



%all axes are actually 3D plots that are identical except for the view setting
%this makes updating very simple. However, zooming might be easier with 3
%different 2D plots
for ii=1:nax
    hax(ii)=subplot(sprow,spcol,ii);
    xlabel([viewlabels(ii,:), ' X (mm)']);
    ylabel([viewlabels(ii,:), ' Y (mm)']);
    zlabel([viewlabels(ii,:), ' Z (mm)']);
    set(gca,'tag',['view' int2str(ii)]);
    set(gca,'view',trajview(ii,:));
    axis square;
     hold on;
    mcrc2(ii)=plot3(tmpcrc(:,1,ii),tmpcrc(:,2,ii),tmpcrc(:,3,ii));
     hold on;
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
ht=text(0,0,[chanstr blanks(nchan)' int2str(round(pos(chanlist,:)))],'fontsize',8,'fontname','Courier','fontweight','bold');
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

% set(hax(1:nax),'xlim',[-100 100],'ylim',[-100 100],'zlim',[-100 100]);
set(hax(1:nax),'xlim', spfac.*[-sprad sprad],'ylim',  spfac.*[-sprad sprad],'zlim',  spfac.*[-sprad sprad]);
set(hf,'userdata',userdata);
setcontextmenu(findobj(hf),hf);
disp('Use context menus to adjust graphics properties');
disp('Position of axes can be adjusted with the pan tool in the figure menu bar');
disp('Type return to start timer');
keyboard;
start(htimer);
disp('Type return to stop');
keyboard;

stop(htimer);
delete(htimer);

s.close;




function lida_rtmon_timercb(cbobj,cbdata,hf)

deg2rad=pi/180;
ndig=4;
ndim=6;
ampfac=1000;

userdata=get(hf,'userdata');

dig=userdata.dig;

chanlist=userdata.chanlist;
nchan=length(chanlist);
hlall=userdata.hlall;
hl=userdata.hl;
ht=userdata.ht;

skipnew=1;

if ~skipnew
    readok=0;
    while ~readok
        try
            [active,sample,sweep,dataS,dataC,pos] = getEmaAll (userdata.socket);
            readok=1;
        catch
            disp('Reconnecting ...');
            %		disp(['I think I lost the connection...' crlf 'Type return when ready to reconnect!']);

            retrycount=0;
            connected=0;
            retrylimit=10;
            while ~connected
                try
                    userdata.socket.close; %close the socket in any case, maybe timeout
                    %was for different reasons than a broken
                    %socket
                    userdata.socket=lida_connect(userdata.lidatimeout);
                    [active,sample,sweep,dataS,dataC,pos] = getEmaAll (userdata.socket);

                    connected=1;
                catch
                    retrycount=retrycount+1;
                    if retrycount==retrylimit
                        disp('Unable to reconnect?');
                        disp('Is cs5recorder running?');

                        keyboard;
                        userdata.socket.close; %close the socket in any case, maybe timeout
                        userdata.socket=lida_connect(userdata.lidatimeout);
                        [active,sample,sweep,dataS,dataC,pos] = getEmaAll (userdata.socket);
                        connected=1;
                    end;
                end;
            end;
        end;
    end;
end

skipold=0;

if ~skipold
    conrepeat=0;
    maxconrepeat=10;
    %==================
    while 1
        try
            [active,sample,sweep,dataS,dataC,pos] = getEmaAll (userdata.socket);
        catch
            %disp(['I think I lost the connection...' crlf 'Type return when ready to reconnect!']);
            userdata.socket.close; %close the socket in any case, maybe timeout
            %was for different reasons than a broken
            %socket
            if (conrepeat >= maxconrepeat)
                disp('Failed to connect. Is "cs5recorder" running?');
                disp('Type return to try again.');
                keyboard;
                conrepeat=0;
                disp('Type return to stop');
                continue;
            end
            conrepeat=conrepeat+1;
            disp(['Connection lost. Auto reconnect try ' num2str(conrepeat) ' of ' num2str(maxconrepeat) '.']);
            try
                pause(0.2);
                userdata.socket=lida_connect(userdata.lidatimeout);
                connected=true;
            catch
            end
            continue
        end
        break;
    end
end
%==================



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

set(ht,'string',[chanstr blanks(nchan)' int2str(round(pos(chanlist,:)))]);
userdata.active=active;
userdata.sample=sample;
userdata.sweep=sweep;
userdata.dataS=dataS;
userdata.dataC=dataC;
userdata.pos=pos;

userdata.BPOINT=BPOINT;
userdata.BD=BD;
userdata.BT=BT;
userdata.dig=dig;



set(hf,'userdata',userdata);

global DOLIDACOPY
if (trialfinished && DOLIDACOPY)
    amppath=userdata.amppath;
    mypath=userdata.mypath;
    if ~isempty(amppath)
        trials=int2str0(sweep-1,ndig);
        ampname=[userdata.amppath trials '.amp'];
        %scp -P 6022 lidaop@cs6lida:/srv/data/0027.amp .
        evals=['scp -P ', dig,'022 lidaop@cs',dig,'lida:/srv/data/',trials,'.* ',amppath];
        %[mystat,myresult]=system(['echo "/srv/data/' trials '.* ' amppath '" | rcplidaop']);
        [mystat,myresult]=system(evals);
        maxtrialraw=str2num(trials);
        if exist([mypath 'rtmon_cfg'],'file')
            save([mypath 'rtmon_cfg'],'maxtrialraw','-append');
        else,   save([mypath 'rtmon_cfg'],'maxtrialraw');
        end;
        
        disp(mystat);
        disp(myresult);
        data=LoadAmpb(ampname);
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
