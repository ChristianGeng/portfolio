function [statxb,statsdb,nancntb,hf]=show_trialox(filepath,triallist,kanallist,hf,graphstep,tanflag,maxminflag,compsens)
% SHOW_TRIALOX temporal and spatial (plus orientation) display of list of trials
% function [statxb,statsdb,nancntb,hf]=show_trialox(filepath,triallist,kanallist,hf,graphstep,tanflag,maxminflag)
% show_trialox: Version 26.05.2013
%
%   Description
%       Shows coordinates over time for each trial in the list 
%       Shows Cartesian and orientation spatial displays for each trial
%           using all combinations of x, y, z in 2D displays, plus 4th 3D display (includes display of
%           average orientation in the cartesian displays)
%       Accumulates statistics for each trial and display them as a history
%           over trials of the current session.
%           These statistics are stored to disc (in filepath) at the end of
%           the loop through the trials.
%
%   Syntax
%       filepath: Path to data. Specify with final path character (assuming
%           filenames are 4 digit trial numbers)
%       hf: Set to missing or empty for first call to initialize figures.
%           For subsequent calls use output arg hf as input arg. This
%           preserves the content of statxb from previous calls to the
%           function
%           (not tested: if hf is a scalar, then figures are initialized,
%           and hf is used as the maximum trial number for setting up statistics buffers
%           (default = 2000))
%       triallist: List of trials to display. Special case (not tested): If
%           first trial in list is <0 and no stats have yet been displayed then the program tries to load statistics
%           from disc (the absolute value of the trial number must point to a
%           trial that exists and is to be processed)
%       kanallist: List of channels to display. No defaults.
%           Note: statistics are calculated over all channels in the input
%           file. So using the mechanism given above for re-loading
%           existing statistics the program can be used to show a different
%           selection of channels without needing to read all the position
%           files again.
%		graphstep: Optional, default to 1. Step through trial list for
%			graphic update. As graphic update gets slower and slower in a long
%			list of trials, this can speed things up if one is mainly
%			interested in the final statistics rather than the graphics
%       tanflag: Optional, default to 1. 
%           0: display parameter 7
%           1: display tangential velocity
%           2: display distance from comparison sensor
%       maxminflag: Optional, default to 0 (false). If true, replace +/- sd
%           with max and min to show range in time function and trial history
%           display.
%       compsens: For all sensors, euclidean distance from this sensor is
%           calculated. Defaults to first channel in kanallist
%       statxb, statsdb:    Contain list of means and sds per trial
%                           1st dimension: Trial
%                           2nd dimension: Position (x,y,z), Orientation (x,y,z component), rms, tangential velocity
%                               Position and velocity in mm and mm/s
%                           3rd dimension: Sensor
%       nancntb: Arranged trials (rows), sensors (columns). Shows total missing data per trial
%
%   Notes
%       Also designed to be used for quasi-realtime display during
%       experimental sessions. See do_showtrial_rtmon
%
%	Updates
%		3.09. Tag of axes objects given same value as title (should make
%		setting manual scaling easier). Scaling of all axes is no longer automatic.
%		See showtrial_rangeset for example of how to set the ranges
%		manually.
%		6.09 Stats buffer size increased
%       9.10. Position and orientation trajectory figures merged; choice
%           of existing parameter 7 or tangential velocity
%       10.2012 start preparing for AG501:
%           maximum channels increased; allow for max/min as option for
%           range. Implement input and output of stats file. Implement
%           distance from comparison sensor. Tangential velocity and
%           compdist statistics are computed regardless of whether they are
%           displayed or not
%       04.2013 line objects given channel name as tag, so visibility can
%           be toggled with showtrial_visibset
%
%   See Also
%       DO_SHOWTRIAL_RTMON SHOWSTATS SHOWTRIAL_RANGESET SHOWTRIAL_VISIBSET

functionname='show_trialox: Version 26.05.2013';

igstep=1;
if nargin>4 igstep=graphstep; end;
if isempty(igstep) igstep=1; end;

dotan=1;
if nargin>5 dotan=tanflag; end;

domaxmin=0;
if nargin>6 domaxmin=maxminflag; end;
maxmintxt='Range is sd';
if domaxmin maxmintxt='Range is max-min'; end;

compsensor=kanallist(1);
if nargin>7 compsensor=compsens; end;

ncoord=6;       %assume fixed (3 position + 3 orientation)
maxchan=24;

ndig=4;     %digits for trial number
%mytrial=str2num(filename((end-ndig+1):end));


statsname=[filepath 'show_trialox_stats'];

%length of orientation vector in cartesian display
%default value of 10 should be appropriate for tongue sensors
orifac=10;       %can be changed via userdata of orientation figure

%subplots for time-function (and trial average) displays
sprow=3;
spcol=3;

maxsubp=sprow*spcol;

%set up basic views for the spatial displays
%(if more flexibility is required, see the subfunction makeviews in mt_sxyv
%yz, xz, yx, 3d = coronal, sagittal, axial, 3D for raw helmet coordinate
%system
%(for data based on final coordinate system a different arrangement would
%be better)
%trajview=[90 0;0 0;90 -90;-37.5 30];
trajview=[90 0;0 0;90 -90];

ntraj=size(trajview,1);
trajsprow=2;        %position, orientation
trajspcol=ntraj;

posrange=100;	%initial position axes settings: +/- posrange
%(orientation set to +/-1)

rmsrange=30;
%needs working out for other possibilities for 'parameter 7'
%so currently ylim for this axes is not set below. use showtrial_rangeset
%if necessary
tangvelrange=300;
if ~dotan tangvelrange=5;   end;    %initially assume kalman fb difference

nfig=3;
if length(hf)~=nfig
    maxtrialb=2000;		%increased 6.09
    %	maxtrialb=1000;
    if length(hf)==1 maxtrialb=hf; end;     %allow other settings of maxtrialb
    
    for ii=1:nfig hf(ii)=figure; end;
    set(hf,'userdata',[]);
    set(hf(1),'tag','showtrial_cbfig');     %time functions for current trial
    set(hf(3),'tag','showtrial_statsfig','name',['Stats over trials. ' maxmintxt]);
    set(hf(2),'tag','cartesian');
    userdata.pos=[];
    userdata.ori=[];
    set(hf(2),'userdata',userdata);
    %	set(hf(4),'tag','orientation');
end;

triallista=abs(triallist);
plotlist=triallista(1:igstep:end);
plotlist=plotlist(:);
%make sure graphics are updated at end of list
if plotlist(end)~=triallista(end) plotlist=[plotlist;triallista(end)]; end;


maxtrial=2;
for ititi=1:length(triallist)
    mytrial=triallist(ititi);
    tmptrial=mytrial;
    mytrial=abs(mytrial);
    disp(mytrial)
    mytrials=int2str0(mytrial,ndig);
    
    filename=[filepath mytrials];
    %normally loaded from input file
    sf=200;
    
    
    rmsp=ncoord+1;
    %Currently, tangential velocity replaces whatever data was located in the
    %column after rms ('newflag') if dotan is true
    %(see also below for manipulation of descriptor)
    tangp=rmsp+2;
    compp=rmsp+3;
%change to ncoord+4 to reserve space for tangvel and compensor
    nco=ncoord+4;
coordlist=[1:(ncoord+2)];
coordlist(end)=coordlist(end)+dotan;
ncod=length(coordlist);

    %stats for one trial
    statx=ones(nco,maxchan)*NaN;
    statsd=statx;
    statmax=statx;
    statmin=statx;
    nancnt=ones(1,maxchan)*NaN;
    
    %loadpos_sph2cartm (and loadpos) should return empty data if file not
    %found, but test explicitly here
    if exist([filename '.mat'],'file')
        [datain,descriptor,unit,dimension,sensorlist]=loadpos_sph2cartm(filename);
        
        if ~isempty(datain)
                descriptor=str2mat(descriptor,'Tangential Vel.',['Distance from S' int2str(compsensor)]); 
                unit=str2mat(unit,[deblank(unit(1,:)) '/s'],unit(1,:));    
            ndat=size(datain,1);
            nparin=size(datain,2);
            nkanalin=size(datain,3);
            %set up true time axis
            data=ones(ndat,nparin+2,nkanalin)*NaN;
            data(:,1:nparin,:)=datain;
            
            sf=mymatin(filename,'samplerate',200);
            tvec=((1:ndat)-1)*(1/sf);
            sensorlistall=sensorlist;
            sensorlist=sensorlist(kanallist,:);
            
            nkanal=length(kanallist);
            nancnt(1:nkanalin)=sum(isnan(squeeze(data(:,1,:))));
            
            %calculate tangential velocity and compdist; add to coordinate data
                comppos=data(:,1:3,compsensor);
            for ikanal=1:nkanalin
                posdat=data(:,1:3,ikanal);
                euctmp=eucdistn(posdat(1:end-1,:),posdat(2:end,:))*sf;
                euctmp=[euctmp;euctmp(end)];  %make same length as other time functions
                data(:,tangp,ikanal)=euctmp;
                euccomp=eucdistn(posdat,comppos);
                data(:,compp,ikanal)=euccomp;
            end;
            
            
            
            %do stats for current trial, and accumulate in buffer for all trials
            userdata=get(hf(3),'userdata');
            
            
            if isempty(userdata)
                
                
                statxb=ones(maxtrialb,nco,maxchan)*NaN;
                statsdb=statxb;
                statmaxb=statxb;
                statminb=statxb;
                nancntb=ones(maxtrialb,maxchan)*NaN;
                if tmptrial<0
                    %try and load existing stats file
                    if exist([statsname '.mat'],'file')
                        disp(['Loading stats from ' statsname]);
                        statxb=mymatin(statsname,'statxb');
                        statsdb=mymatin(statsname,'statsdb');
                        statmaxb=mymatin(statsname,'statmaxb');
                        statminb=mymatin(statsname,'statminb');
                        nancntb=mymatin(statsname,'nancntb');
                        maxtrial=mymatin(statsname,'maxtrial');
                    end;
                    
                end;
            else
                statxb=userdata.statxb;
                statsdb=userdata.statsdb;
                statmaxb=userdata.statmaxb;
                statminb=userdata.statminb;
                maxtrial=userdata.maxtrial;
                nancntb=userdata.nancntb;
            end;
            maxtrialb=size(statxb,1);
            if mytrial>maxtrialb
                disp('Statistics buffer too small');
            end;
            
            maxtrial=max([maxtrial mytrial]);
            nancntb(mytrial,:)=nancnt;
            for ikanal=1:nkanalin
                if nancnt(ikanal)<ndat
                    
                    tmp=(nanmean(data(:,:,ikanal)))';
                    
                    %            keyboard;
                    statx(:,ikanal)=tmp;
                    statsd(:,ikanal)=(nanstd(data(:,:,ikanal)))';
                    statmax(:,ikanal)=(nanmax(data(:,:,ikanal)))';
                    statmin(:,ikanal)=(nanmin(data(:,:,ikanal)))';
                    
                end;
            end;
            
            statxb(mytrial,:,:)=statx;
            statsdb(mytrial,:,:)=statsd;
            statmaxb(mytrial,:,:)=statmax;
            statminb(mytrial,:,:)=statmin;
            
            if ~isempty(userdata)
                userdata.statxb=statxb;
                userdata.statsdb=statsdb;
                userdata.statmaxb=statmaxb;
                userdata.statminb=statminb;
                userdata.nancntb=nancntb;
                
                userdata.maxtrial=maxtrial;
                userdata.descriptor=descriptor;
                userdata.unit=unit;
                set(hf(3),'userdata',userdata);
                drawnow;
            end;
            if ismember(mytrial,plotlist)
                %====================================================
                %plot trial statistics similarly to timewave of current trial
                
                figure(hf(3));
                mycol=hsv(nkanal+1);
                for icoi=1:ncod
                    ico=coordlist(icoi);
                    pptmp=squeeze(statxb(1:maxtrial,ico,kanallist));
                    if domaxmin
                        pptmpupper=squeeze(statmaxb(1:maxtrial,ico,kanallist));
                        pptmplower=squeeze(statminb(1:maxtrial,ico,kanallist));
                        
                    else
                        %shoud also allow for an sd factor
                        pptmpsd=squeeze(statsdb(1:maxtrial,ico,kanallist));
                        pptmpupper=pptmp+pptmpsd;
                        pptmplower=pptmp-pptmpsd;
                    end;
                    
                    if isempty(userdata)
                        hax(icoi)=subplot(sprow,spcol,icoi);
                        if icoi==1
                            hl=ones(nkanal,ncod)*NaN;
                            hlu=hl;
                            hld=hl;
                        end;
                        hl(:,icoi)=plot(pptmp,'linewidth',2,'marker','.');
                        hold on
                        hlu(:,icoi)=plot(pptmpupper,'linestyle',':','linewidth',2,'marker','.');
                        hld(:,icoi)=plot(pptmplower,'linestyle',':','linewidth',2,'marker','.');
                        hold off
                        for ii=1:nkanal set([hl(ii,icoi) hlu(ii,icoi) hld(ii,icoi)],'color',mycol(ii,:),'tag',deblank(sensorlist(ii,:))); end;
                        mytit=deblank(descriptor(ico,:));
                        title(mytit,'interpreter','none');
                        set(gca,'tag',mytit);
                        if icoi==ncod xlabel('Trial number'); end;
                        ylabel(unit(ico,:));
                        %preset the ranges
                        if strcmp(mytit(1:3),'pos') set(hax(icoi),'ylim',[-posrange +posrange]);end;
                        if strcmp(mytit(1:3),'ori') set(hax(icoi),'ylim',[-1 +1]);end;
                        if strcmp(mytit(1:3),'rms') set(hax(icoi),'ylim',[0 rmsrange]);end;
%leave this free to vary
%can be set from keyboard with showtrial_rangeset
                        %                        if strcmp(mytit(1:3),descriptor(tangp,1:3)) set(hax(ico),'ylim',[0 tangvelrange]);end;
                        
                        
                    else
                        hax=userdata.axes;
                        hl=userdata.lines;
                        hlu=userdata.linesu;
                        hld=userdata.linesd;
                        doplotstats(hl(:,icoi),hlu(:,icoi),hld(:,icoi),pptmp,pptmpupper,pptmplower);
                    end;
                    
                end;
                %also plot nancnt
                nantmp=nancntb(:,kanallist);
                if isempty(userdata)
                    hax(ncod+1)=subplot(sprow,spcol,ncod+1);
                    hlnan=plot(nantmp,'linewidth',2,'marker','.');
                    for ii=1:nkanal set(hlnan(ii),'color',mycol(ii,:),'tag',deblank(sensorlist(ii,:))); end;
                    title('NaN count');
                    xlabel('Trial number');
                else
                    hlnan=userdata.hlnan;
                    
                    for ii=1:nkanal set(hlnan(ii),'xdata',(1:size(nantmp,1))','ydata',nantmp(:,ii));end;
                    
                    
                    set(hax,'xlim',[0 maxtrial]);
                    
                    
                end;
                
                drawnow;
                
                userdata.statxb=statxb;
                userdata.statsdb=statsdb;
                userdata.statmaxb=statmaxb;
                userdata.statminb=statminb;
                userdata.lines=hl;
                userdata.linesu=hlu;
                userdata.linesd=hld;
                userdata.axes=hax;
                userdata.nancntb=nancntb;
                userdata.maxtrial=maxtrial;
                userdata.hlnan=hlnan;
                userdata.sensorlist=sensorlistall;
                userdata.descriptor=descriptor;     %needed again here
                userdata.unit=unit;
                set(hf(3),'userdata',userdata);
                drawnow
                
                %=========== end of plot of trial statistics
                
                
                %========== Plot time wave of current trial
                
                
                figure(hf(1));
                set(hf(1),'Name',['Trial ' int2str(mytrial)]);
                userdata=get(hf(1),'userdata');
                mycol=hsv(nkanal+1);
                
                for icoi=1:ncod
                    ico=coordlist(icoi);
                    pptmp=squeeze(data(:,ico,kanallist));
                    if isempty(userdata)
                        if icoi==1 hl=ones(nkanal,ncod)*NaN; end;
                        hax(icoi)=subplot(sprow,spcol,icoi);
                        hl(:,icoi)=plot(tvec,pptmp,'linewidth',2);
                        for ii=1:nkanal set(hl(ii,icoi),'color',mycol(ii,:),'tag',deblank(sensorlist(ii,:))); end;
                        %               keyboard;
                        if icoi==1
                            %                    keyboard;
                            [LEGH,OBJH,OUTH,OUTM]=legend(hl(:,icoi),strcat(int2str(kanallist'),' : ',sensorlist));
                            
                            hxxx=findobj(OBJH,'type','text');
                            set(hxxx,'interpreter','none');
                        end;
                        mytit=deblank(descriptor(ico,:));
                        title(mytit,'interpreter','none');
                        set(gca,'tag',mytit);
                        if icoi==ncod xlabel('Time (s)'); end;
                        ylabel(unit(ico,:));
                        if strcmp(mytit(1:3),'pos') set(hax(icoi),'ylim',[-posrange +posrange]);end;
                        if strcmp(mytit(1:3),'ori') set(hax(icoi),'ylim',[-1 +1]);end;
                        if strcmp(mytit(1:3),'rms') set(hax(icoi),'ylim',[0 rmsrange]);end;
                        if strcmp(mytit(1:3),descriptor(tangp,1:3)) set(hax(icoi),'ylim',[0 tangvelrange]);end;
                        
                    else
                        hl=userdata.lines;
                        hax=userdata.axes;
                        doplot(hl(:,icoi),pptmp,tvec);
                    end;
                    
                end;
                drawnow;
                
                %so user can interrupt real-time monitoring
                if isempty(userdata)
                    set(hf(1),'windowbuttondownfcn',@showtrial_cb);
                    userdata.userflag=0;
                end;
                
                
                userdata.lines=hl;
                userdata.axes=hax;
                set(hf(1),'userdata',userdata);
                drawnow;
                %======== end of plot of timewave of current trial
                
                %======= plot spatial trajectories (for cartesian and orientation data) of
                %current trial
                posd=data(:,1:3,kanallist);
                orid=data(:,4:6,kanallist);
                
                statxch=statx(:,kanallist);
                
                %get orifac from userdata somewhere
                
                tmpdata=get(hf(2),'userdata');
                if ~isempty(tmpdata.ori)
                    orifac=tmpdata.ori.orifac;
                end;
                
                
                ovec=makeovec(statxch,orifac);
                myzeros=zeros(1,nkanal);
                orgorix=[myzeros;statxch(4,:)];
                orgoriy=[myzeros;statxch(5,:)];
                orgoriz=[myzeros;statxch(6,:)];
                
                %to plot zero-length lines at mean position
                meanposx=[statxch(1,:);statxch(1,:)];
                meanposy=[statxch(2,:);statxch(2,:)];
                meanposz=[statxch(3,:);statxch(3,:)];
                
                
                
                %Cartesian
                
                figure(hf(2));
                set(hf(2),'Name',['Trial ' int2str(mytrial)]);
                userdataposori=get(hf(2),'userdata');
                userdata=userdataposori.pos;
                if isempty(userdata)
                    hlcart=ones(nkanal,ntraj)*NaN;
                    hlcartx=ones(nkanal,ntraj)*NaN;
                    hlto=ones(ntraj,1)*NaN;
                    % The plot commands for the all views are absolutely identical, just the view
                    % is set differently after generating the plot
                    
                    %Cartesian data
                    % In the cartesian displays also plot a line showing the mean orientation of the sensor in that trial at the
                    % mean spatial position
                    
                    for itraj=1:ntraj
                        haxtc(itraj)=subplot(trajsprow,trajspcol,itraj);
                        hlcart(:,itraj)=plot3(squeeze(posd(:,1,:)),squeeze(posd(:,2,:)),squeeze(posd(:,3,:)),'linewidth',2);
                        hlcartx(:,itraj)=line(meanposx,meanposy,meanposz,'linewidth',2,'marker','o','markersize',12);
                        %orientation vector starting at mean cartesian position
%note: this is a single line object for all channels (see makeovec; using
%NaNs as a trick to give a break in the lines, so not currently possible to turn
%visibility on and off for specific channels with showtrial_visibset
                        hlto(itraj)=line('xdata',ovec(:,1),'ydata',ovec(:,2),'zdata',ovec(:,3),'linewidth',2,'color','k');
                        xlabel('X');ylabel('Y');zlabel('Z');
                        title('Position');
                        set(gca,'tag','Position');
                        set(gca,'view',trajview(itraj,:));
                        axis equal
                        grid on;
                    end;
                    %keyboard;
                    set(haxtc,'xlim',[-posrange posrange],'ylim',[-posrange posrange],'zlim',[-posrange posrange]);
                    for ii=1:nkanal
                        set(hlcart(ii,:),'color',mycol(ii,:),'tag',deblank(sensorlist(ii,:)));
                        set(hlcartx(ii,:),'color',mycol(ii,:),'tag',deblank(sensorlist(ii,:)));
                    end;
                    
                else
                    hlcart=userdata.lines;
                    hlcartx=userdata.linesx;
                    haxtc=userdata.axes;
                    dotraj(hlcart,posd);
                    hlto=userdata.olines;
                    %                keyboard;
                    set(hlto,'xdata',ovec(:,1),'ydata',ovec(:,2),'zdata',ovec(:,3));
                    for ii=1:nkanal
                        set(hlcartx(ii,:),'xdata',meanposx(:,ii),'ydata',meanposy(:,ii),'zdata',meanposz(:,ii));
                    end;
                end;
                
                %				drawnow;
                
                userdata.lines=hlcart;
                userdata.linesx=hlcartx;
                userdata.axes=haxtc;
                userdata.olines=hlto;
                userdataposori.pos=userdata;
                %				set(hf(2),'userdata',userdataposori);
                %				drawnow;
                
                %Orientation
                
                %				figure(hf(4));
                %				set(hf(4),'Name',['Trial ' int2str(mytrial)]);
                %				userdata=get(hf(4),'userdata');
                userdata=userdataposori.ori;
                if isempty(userdata)
                    
                    %In the orientation display also plot a line from the origin to the mean
                    %orientation value for the trial
                    hlorgori=ones(nkanal,ntraj)*NaN;
                    hlori=ones(nkanal,ntraj)*NaN;
                    
                    
                    
                    % The plot commands for the all views are absolutely identical, just the view
                    % is set differently after generating the plot
                    
                    
                    for itraj=1:ntraj
                        haxto(itraj)=subplot(trajsprow,trajspcol,itraj+ntraj);
                        hlori(:,itraj)=plot3(squeeze(orid(:,1,:)),squeeze(orid(:,2,:)),squeeze(orid(:,3,:)),'linewidth',2);
                        %                for iki=1:nkanal
                        %                    hlorgori(iki,itraj)=line('xdata',orgorix(:,iki),'ydata',orgoriy(:,iki),'zdata',orgoriz(:,iki),'linewidth',2,'marker','.','linestyle','--');
                        %                end;
                        hlorgori(:,itraj)=line(orgorix,orgoriy,orgoriz,'linewidth',2,'marker','.','linestyle','--');
                        
                        
                        
                        xlabel('X');ylabel('Y');zlabel('Z');
                        title('Orientation');
                        set(gca,'view',trajview(itraj,:));
                        set(gca,'tag','Orientation');
                        
                        axis equal
                        grid on;
                    end;
                    
                    for ii=1:nkanal set(hlori(ii,:),'color',mycol(ii,:),'tag',deblank(sensorlist(ii,:))); end;
                    for ii=1:nkanal set(hlorgori(ii,:),'color',mycol(ii,:),'tag',deblank(sensorlist(ii,:))); end;
                    
                    set(haxto,'xlim',[-1 1],'ylim',[-1 1],'zlim',[-1 1]);
                    
                else
                    hlori=userdata.lines;
                    haxto=userdata.axes;
                    dotraj(hlori,orid);
                    hlorgori=userdata.olines;
                    for ii=1:nkanal
                        set(hlorgori(ii,:),'xdata',orgorix(:,ii),'ydata',orgoriy(:,ii),'zdata',orgoriz(:,ii));
                    end;
                    
                end;
                
                %				drawnow;
                
                userdata.lines=hlori;
                userdata.axes=haxto;
                userdata.olines=hlorgori;
                userdata.orifac=orifac;
                userdataposori.ori=userdata;
                set(hf(2),'userdata',userdataposori);
                drawnow;
            end;			%trial in plotlist
            
            
        end;
    else
        disp('No trial?');
    end;
    
end;        %loop thru trials

%Save statistics.
%Will make it quicker to regenerate the stats figure if matlab crashes
%completely (otherwise all trials have to be read again)

sensorlist=sensorlistall;
comment=framecomment('',functionname);
%occasional problems when called by lida_rtmon2file to display a trial with
%a corrupt trial number (e.g negative), leading show_trialox to think the
%mat file is not present
try
save(statsname,'statxb','statsdb','statmaxb','statminb','nancntb','compsensor','maxtrial','descriptor','unit','sensorlist','comment');
catch
    disp('Unable to store stats');
    disp('Maybe not initialized?');
end;

function dotraj(hl,posd);
%this is actually also used for orientation data
nl=size(hl,1);
nt=size(hl,2);
for ii=1:nl
    for jj=1:nt
        set(hl(ii,jj),'xdata',posd(:,1,ii),'ydata',posd(:,2,ii),'zdata',posd(:,3,ii));
        
    end;
    
end;




function doplot(hl,pptmp,tvec);
nl=length(hl);

for ii=1:nl set(hl(ii),'xdata',tvec,'ydata',pptmp(:,ii));end;

function doplotstats(hl,hlu,hld,pptmp,pptmpupper,pptmplower);
nl=length(hl);
tvec=(1:size(pptmp,1))';
for ii=1:nl
    set(hl(ii),'xdata',tvec,'ydata',pptmp(:,ii));
    set(hlu(ii),'xdata',tvec,'ydata',pptmpupper(:,ii));
    set(hld(ii),'xdata',tvec,'ydata',pptmplower(:,ii));
    
end;

function ovec=makeovec(statx,orifac);
maxchan=size(statx,2);
ovec=ones(3,maxchan,3)*NaN;
for ii=1:maxchan
    ovec(1,ii,:)=statx(1:3,ii);
    ovec(2,ii,:)=statx(1:3,ii)+(statx(4:6,ii)*orifac);
end;

ovec=reshape(ovec,[3*maxchan,3]);
function showtrial_cb(cbobj,cbdata)
% Indicates button press in figure 1

y=get(cbobj,'userdata');
y.userflag=1;
set(cbobj,'userdata',y);
