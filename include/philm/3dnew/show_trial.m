function [statxb,statsdb,nancntb,hf]=show_trial(filepath,triallist,kanallist,hf)
% SHOW_TRIAL temporal and spatial display of list of trials
% function [statxb,statsdb,nancntb,hf]=show_trial(filepath,triallist,kanallist,hf)
% show_trial: Version 10.6.05
%
%   Syntax
%       Set hf to missing or empty for first call to initialize figures
%           for subsequent calls use output arg hf as input arg
%       2nd dimension of statxb (means) and statsdb (sd) : are position (x,y,z), orientation
%       (x,y,z component), rms, tangential velocity (currently labelled
%       newflag in plots). Position and velocity in mm and mm/s
%       3rd dimension in sensor, 1st dimension is trial
%       nancntb is arranged trials (rows), sensors (columns). Shows total
%       missing data per trial

ncoord=6;       %assume fixed (3 position + 3 orientation)
maxchan=12;

ndig=4;     %digits for trial number
%mytrial=str2num(filename((end-ndig+1):end));

%not used
%orifac=5;       %should be input argument

sprow=3;
spcol=3;

maxsubp=sprow*spcol;

%choose possible 2D views (not really implemented yet), should be input arg
trajview=str2mat('xz','yx');
ntraj=size(trajview,1);

nfig=3;
if length(hf)~=nfig
    maxtrialb=1000;
    if length(hf)==1 maxtrialb=hf; end;
    
    for ii=1:nfig hf(ii)=figure; end;
    set(hf,'userdata',[]);
end;

maxtrial=2;
for mytrial=triallist
    disp(mytrial)
    mytrials=int2str0(mytrial,ndig);
    
    filename=[filepath mytrials];
    %normally loaded from input file
    sf=200;
    
    
    rmsp=ncoord+1;
    tangp=rmsp+1;
    nco=ncoord+2;
    
    
    %stats for one trial
    statx=ones(nco,maxchan)*NaN;
    statsd=statx;
    nancnt=ones(1,maxchan);
    
    
    
    [data,descriptor,unit,dimension,sensorlist]=loadpos_sph2cartm(filename);
    
    if ~isempty(data)
        ndat=size(data,1);
        %set up true time axis
        
        
        sf=mymatin(filename,'samplerate',200);
        tvec=((1:ndat)-1)*(1/sf);
        sensorlist=sensorlist(kanallist,:);
        
        
        nkanal=length(kanallist);
        
        nancnt(kanallist)=sum(isnan(squeeze(data(:,1,kanallist))));
        
        %calculate tangential velocity, add to coordinate data
        eucbuf=zeros(ndat,nkanal);
        for ikanal=kanallist
            posdat=data(:,1:3,ikanal);
            euctmp=eucdistn(posdat(1:end-1,:),posdat(2:end,:))*sf;
            euctmp=[euctmp;euctmp(end)];  %make same length as other time functions
            %temprorary; should check position is available
            data(:,tangp,ikanal)=euctmp;    
        end;
        
        
        
        %do stats for current trial, and accumulate in buffer for all trials
        userdata=get(hf(3),'userdata');
        
        
        if isempty(userdata)
            statxb=ones(maxtrialb,nco,maxchan)*NaN;
            statsdb=statxb;
            nancntb=ones(maxtrialb,maxchan)*NaN;
        else
            statxb=userdata.statxb;
            statsdb=userdata.statsdb;
            maxtrialb=size(statxb,1);
            maxtrial=userdata.maxtrial;
            nancntb=userdata.nancntb;
            if mytrial>maxtrialb
                disp('Statistics buffer too small');
            end;
        end;
        
        maxtrial=max([maxtrial mytrial]);
        nancntb(mytrial,:)=nancnt;
        for ikanal=kanallist
            if nancnt(ikanal)<ndat
                
                tmp=(nanmean(data(:,1:nco,ikanal)))';
                
                %            keyboard;
                statx(:,ikanal)=tmp;
                statsd(:,ikanal)=(nanstd(data(:,1:nco,ikanal)))';
                
            end;
        end;
        
        statxb(mytrial,:,:)=statx;
        statsdb(mytrial,:,:)=statsd;
        
        %plot trial statistics similarly to timewave of current trial
        
        figure(hf(3));
        mycol=hsv(nkanal+1);    
        
        for ico=1:nco
            pptmp=squeeze(statxb(1:maxtrial,ico,kanallist));
            pptmpsd=squeeze(statsdb(1:maxtrial,ico,kanallist));
            if isempty(userdata)
                hax(ico)=subplot(sprow,spcol,ico);
                if ico==1 
                    hl=ones(nkanal,nco)*NaN; 
                    hlu=hl;
                    hld=hl;
                end;
                hl(:,ico)=plot(pptmp,'linewidth',2,'marker','.');
                hold on
                hlu(:,ico)=plot(pptmp+pptmpsd,'linestyle',':','linewidth',2,'marker','.');
                hld(:,ico)=plot(pptmp-pptmpsd,'linestyle',':','linewidth',2,'marker','.');
                hold off
                for ii=1:nkanal set([hl(ii,ico) hlu(ii,ico) hld(ii,ico)],'color',mycol(ii,:)); end;
                title(descriptor(ico,:),'interpreter','none');
                if ico==nco xlabel('Trial number'); end;
                ylabel(unit(ico,:));
                
            else
                hax=userdata.axes;
                hl=userdata.lines;
                hlu=userdata.linesu;
                hld=userdata.linesd;
                doplotstats(hl(:,ico),hlu(:,ico),hld(:,ico),pptmp,pptmpsd);
            end;
            
        end;
        %also plot nancnt
        nantmp=nancntb(:,kanallist);
        if isempty(userdata)
            hax(nco+1)=subplot(sprow,spcol,nco+1);
            hlnan=plot(nantmp,'linewidth',2,'marker','.');
            for ii=1:nkanal set(hlnan(ii),'color',mycol(ii,:)); end;
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
        userdata.lines=hl;
        userdata.linesu=hlu;
        userdata.linesd=hld;
        userdata.axes=hax;
        userdata.nancntb=nancntb;
        userdata.maxtrial=maxtrial;
        userdata.hlnan=hlnan;
        set(gcf,'userdata',userdata);
        
        
        
        
        
        
        
        
        
        figure(hf(1));
        userdata=get(gcf,'userdata');
        mycol=hsv(nkanal+1);    
        
        for ico=1:nco
            pptmp=squeeze(data(:,ico,kanallist));
            if isempty(userdata)
                if ico==1 hl=ones(nkanal,nco)*NaN; end;
                hax(ico)=subplot(sprow,spcol,ico);
                hl(:,ico)=plot(tvec,pptmp,'linewidth',2);
                for ii=1:nkanal set(hl(ii,ico),'color',mycol(ii,:)); end;
                %               keyboard;
                if ico==1
                    %                    keyboard;
                    [LEGH,OBJH,OUTH,OUTM]=legend(hl(:,ico),strcat(int2str(kanallist'),' : ',sensorlist));
                    
                    hxxx=findobj(OBJH,'type','text');
                    set(hxxx,'interpreter','none');
                end;
                title(descriptor(ico,:),'interpreter','none');
                if ico==nco xlabel('Time (s)'); end;
                ylabel(unit(ico,:));
            else
                hl=userdata.lines;
                hax=userdata.axes;
                doplot(hl(:,ico),pptmp,tvec);
            end;
            
        end;
        drawnow;
        
%so user can interrupt real-time monitoring
        if isempty(userdata)
            set(gcf,'windowbuttondownfcn','show_trialcb');
            userdata.userflag=0;
        end;
        

        userdata.lines=hl;
        userdata.axes=hax;
        set(gcf,'userdata',userdata);
        
        
        figure(hf(2));
        userdata=get(gcf,'userdata');
        
        %for isubp=1:ntraj
        posd=data(:,1:3,kanallist);
        orid=data(:,4:6,kanallist);
        %        orid=posd+(orid*orifac);
        if isempty(userdata)
            hlt=ones(nkanal,4)*NaN;
            
            haxt(1)=subplot(2,2,1);
            hlt(:,1)=plot3(squeeze(posd(:,1,:)),squeeze(posd(:,2,:)),squeeze(posd(:,3,:)),'linewidth',2);
            xlabel('X');ylabel('Y');zlabel('Z');
            title('Position');
            set(gca,'view',[0 0]);
            axis equal
            grid on;
            
            haxt(2)=subplot(2,2,2);
            hlt(:,2)=plot3(squeeze(posd(:,1,:)),squeeze(posd(:,2,:)),squeeze(posd(:,3,:)),'linewidth',2);
            xlabel('X');ylabel('Y');zlabel('Z');
            title('Position');
            set(gca,'view',[0 90]);
            axis equal
            grid on;
            
            
            haxt(3)=subplot(2,2,3);
            hlt(:,3)=plot3(squeeze(orid(:,1,:)),squeeze(orid(:,2,:)),squeeze(orid(:,3,:)),'linewidth',2);
            xlabel('X');ylabel('Y');zlabel('Z');
            title('Orientation');
            set(gca,'view',[0 0]);
            axis equal
            grid on;
            
            haxt(4)=subplot(2,2,4);
            hlt(:,4)=plot3(squeeze(orid(:,1,:)),squeeze(orid(:,2,:)),squeeze(orid(:,3,:)),'linewidth',2);
            xlabel('X');ylabel('Y');zlabel('Z');
            title('Orientation');
            set(gca,'view',[0 90]);
            axis equal
            grid on;
            
            
            
            
            %            hlt(:,2)=plot3(squeeze(orid(:,1,:)),squeeze(orid(:,2,:)),squeeze(orid(:,3,:)),':');
            
            
            for ii=1:nkanal set(hlt(ii,:),'color',mycol(ii,:)); end;
            
        else
            hlt=userdata.lines;
            haxt=userdata.axes;
            dotraj(hlt,posd,orid);    
            
        end;
        
        drawnow;
        
        userdata.lines=hlt;
        userdata.axes=haxt;
        set(gcf,'userdata',userdata);
        
        
    end;
    
end;        %loop thru trials

function dotraj(hl,posd,orid);
nl=size(hl,1);

for ii=1:nl 
    set(hl(ii,1),'xdata',posd(:,1,ii),'ydata',posd(:,2,ii),'zdata',posd(:,3,ii));
    set(hl(ii,3),'xdata',orid(:,1,ii),'ydata',orid(:,2,ii),'zdata',orid(:,3,ii));
    set(hl(ii,2),'xdata',posd(:,1,ii),'ydata',posd(:,2,ii),'zdata',posd(:,3,ii));
    set(hl(ii,4),'xdata',orid(:,1,ii),'ydata',orid(:,2,ii),'zdata',orid(:,3,ii));
    
end;





function doplot(hl,pptmp,tvec);
nl=length(hl);

for ii=1:nl set(hl(ii),'xdata',tvec,'ydata',pptmp(:,ii));end;

function doplotstats(hl,hlu,hld,pptmp,pptmpsd);
nl=length(hl);
tvec=(1:size(pptmp,1))';
for ii=1:nl 
    set(hl(ii),'xdata',tvec,'ydata',pptmp(:,ii));
    set(hlu(ii),'xdata',tvec,'ydata',pptmp(:,ii)+pptmpsd(:,ii));
    set(hld(ii),'xdata',tvec,'ydata',pptmp(:,ii)-pptmpsd(:,ii));
    
end;

