function mt_surf(timspec)
% MT_SURF Do surf display
% function mt_surf(timspec)
% mt_surf: Version 26.08.2013
%
%   Syntax
%       timspec (2-element vector) is time (in s) relative to current trial
%           If timspec is scalar, just display corresponding image and return
%
%   Remarks
%       Prompts for factor by which to speed up or slow down.
%       User must enter a factor of 0 to exit from the movie function.
%       factor > 1 to slow down; 0 < factor < 1 to speed up (i.e 0.5 means
%       double speed)
%       If the factor is a power of 2 and >=2 then the program tries to use
%       praat to stretch the audio signal.
%       MT_PRAATSTRETCH may require editing before first use to indicate the correct
%       location of the praat program.
%       (A small praat script called praatstretch.txt is generated in the
%       working directory. This can be edited by the user, if desired. e.g
%       to change default f0 analysis settings for praats PSOLA algorithm)
%
%   Updates
%       06.2013 start implementation based on mt_video
%
%   See also
%       MT_MOVIE for movie in xy display
%       MT_GSURFCD

%make it possible to access the signal data directly

global MT_DATA

[abint,abnoint,abscalar,abnoscalar]=abartdef;
oldfigh=gcf;

hxyf=mt_gfigh('mt_surf');
if isempty(hxyf)
    disp ('mt_surf: surf display not initialized');
    return;
end;
%get movie cursor in main window
hmc=mt_gfigd('time_cursor_handles');
hmc=hmc(:,3);

delayfac=1;                       %could be loaded from mat file
delaylim=0.01;                    %1/delaylim is limit on speed up


%xyindex is the signal number to use with MT_DATA
%hc is the handle to the image object

%note: 04.2012, mt_gvideocd now called without input argument, i.e. no
%restrictions on samplerates etc.
[axnames,xyindex,sf,timestamp,hc]=mt_gsurfcd;

figS=get(hxyf,'userdata');
lastframe=figS.lastframe;
lasttrial=figS.trial_number;
thistrial=mt_gtrid('number');

if isempty(xyindex)
    disp('mt_surf: No active axes');
    figure(oldfigh);
    return;
end;
nax=length(xyindex);

justone=0;
if length(timspec)==1
    justone=1;
    timspec=[timspec timspec];
end;

%playback will be for a time interval that is available for all video
%signals
timestampc=[max(timestamp(:,1)) min(timestamp(:,2))];

if ((timspec(1)>=timestampc(2))|(timspec(2)<=timestampc(1)))
    disp ('mt_surf: Time spec completely outside video timestamp');
    figure(oldfigh);
    return;
end;

if ~justone disp(['Time requested : ' num2str(timspec)]); end;


timspec(1)=max([timspec(1) timestampc(1)]);
timspec(2)=min([timspec(2) timestampc(2)]);

if ~justone disp(['Time used : ' num2str(timspec)]); end;

if ~justone
    
    audiochan=mt_gcsid('audio_channel');
    audiosf=mt_gsigv(audiochan,'samplerate');
    
end;



tmptime=timspec;		%for audio

if ~justone
    if diff(timspec)<=0
        disp ('mt_video: 0 frames');
        figure(oldfigh);
        return
    end;
end;

lspecb=cell(nax,1);
cpsecb=cell(nax,1);

lutc=cell(nax,1);   %lookup tables
uselut=zeros(nax,1);
truecolflag=zeros(nax,1);
ncolplane=ones(nax,1);

figure(hxyf);                 %make sure figure visible

for iax=1:nax
    myname=deblank(axnames(iax,:));
    axnum=xyindex(iax);
    hax=get(hc(iax),'parent');
    
    signalname=mt_gsurfad(myname,'signal_name');
    
    myclim=mt_gsurfad(myname,'clim');
    
    %gamma and colormap are currently figure properties
    %may depend on whether true color is implemented for surface objects
    mygamma=figS.gamma;
%    mygamma=mt_gsurfad(myname,'gamma');
    %spec should just be the name of the colormap function
    mymapin=figS.colormap;
%    mymapin=mt_gsurfad(myname,'colormap');
    try
        mymapin=feval(mymapin,256);     %fixed size of 256 was originally for unint8 image data in mt_video
    catch
        disp(['Problem with colormap for ' myname]);
        disp('using gray');
        mymapin=gray(256);
    end;
    
    datasize=mt_gsigv(signalname,'data_size');
    ndat(iax)=datasize(end);
    %should not be relevant???; maybe automatically convert truecolor to gray
    if length(datasize)==4
        truecolflag(iax)=1;
        ncolplane(iax)=datasize(3);
    end;
    
    %unlike video (image) display, treat surf as measurement data that
    %should not be manipulated by a lookup table
    %so just use axes clim
    try
    set(hax,'clim',myclim);
    catch
        disp('mt_surf: problem setting clim');
        disp('check it is a 2-element vector arranged [min max]');
    end;
    
    set(hc(iax),'cdatamapping','scaled');
    mymap=imadjust(mymapin,[],[],mygamma);
    
    set(get(hax,'parent'),'colormap',mymap);
    
    
    lspec=mt_gsurfad(myname,'linespec');
    cspec=mt_gsurfad(myname,'colspec');
    
    if any(lspec>datasize(1))
        disp('mt_surf: resetting line spec');
        lspec=1:datasize(1);
    end;
    if any(cspec>datasize(2))
        disp('mt_surf: resetting col spec');
        cspec=1:datasize(2);
    end;
    
    lspecb{iax}=lspec;
    cspecb{iax}=cspec;
    
    %should be linked to dimension spec
    mydim=mt_gsigv(signalname,'dimension');
    doexternal=mt_gsurfad(myname,'externalused');
    doz=mt_gsurfad(myname,'zused');
    if doexternal
        mydim=mydim.external;
        
        xdata=mydim.axis{1};
        ydata=mydim.axis{2};
        
    else
        xdata=mydim.axis{2};
        ydata=mydim.axis{1};
        %expand to standard surface specification
        %make sure xdata is a row vector
        xdata=xdata(:)';
        xdata=repmat(xdata,[datasize(1) 1]);
        %make sure ydata is a column vector
        ydata=ydata(:);
        ydata=repmat(ydata,[1 datasize(2)]);
        
        
    end;
    
    
    xdata=xdata(lspec,cspec);
    ydata=ydata(lspec,cspec);
    
    if doz
        zdata=mydim.axis{3};
        zdata=zdata(lspec,cspec);
    else
        zdata=zeros(size(xdata));
    end;
    
    if strcmp(mt_gsurfad(myname,'scalemode'),'auto')
    try
        set(hax,'ylim',[min(ydata(:)) max(ydata(:))],'xlim',[min(xdata(:)) max(xdata(:))]);
        if doz
            set(hax,'zlim',[min(zdata(:)) max(zdata(:))]);
        end;
        
    catch
        disp('mt_surf: Unable to set axes limits');
    end;
    end;
    
    
    ifn=round((timspec(1)-timestamp(iax,1))*sf(iax))+1;
    lastframe(iax)=ifn;
    
    try
        if truecolflag(iax)
            myimg=rgb2gray(MT_DATA{axnum}(lspec,cspec,:,ifn));
            %convert to gray????
        else
            myimg=MT_DATA{axnum}(lspec,cspec,ifn);
        end;
        myimg=double(myimg);        %for surf must be double
        set(hc(iax),'xdata',xdata,'ydata',ydata,'zdata',zdata,'cdata',myimg);
        
        
    catch
        disp('mt_surf: Unable to set up first frame');
    end;
    
end;

drawnow;


if justone
    figS.lastframe=lastframe;   %is this still needed?
    figS.trial_number=thistrial;
    set(hxyf,'userdata',figS);
    figure(oldfigh);
    
    return;
end;

lastdelay=-1;

disp ('Movie delay factor: <1 to speed up, >1 to slow down, 0 to exit');
while delayfac>delaylim
    delayfac=abart('Delay factor',delayfac,0,1./delaylim,abnoint,abscalar);
    if delayfac>delaylim
        set (hmc,'visible','on');
        %do movie cursor in main window
        set (hmc,'xdata',[timspec(1) timspec(1)]);
        drawnow;
        
        framecount=zeros(1,nax);
        
        if delayfac~=lastdelay
            adat=mt_gdata(audiochan,tmptime);
            delayuse=delayfac;
            [adat,delayuse]=mt_praatstretch(adat,delayfac,audiosf);
            
        end;        %delayfac~=lastdelay
        
        lastdelay=delayfac;
        
        mt_audio(adat,[],audiosf/delayuse);
        
        finished=0;
        tic;
        
        while ~finished
            itoc=toc/delayfac;
            current_time=timspec(1)+itoc;
            if current_time>=timspec(2)
                finished=1;
            else
                cuttime=current_time;
                
                for iax=1:nax
                    ifn=round((current_time-timestamp(iax,1))*sf(iax))+1;
                    
                    %should be superfluous if timspec is set correctly
                    if ifn>ndat(iax) ifn=ndat(iax);end;
                    
                    if ifn~=lastframe(iax)
                        
                        lastframe(iax)=ifn;
                        framecount(iax)=framecount(iax)+1;
                        axnum=xyindex(iax);
                        lspec=lspecb{iax};
                        cspec=cspecb{iax};
                        
                        %currently assume lut not used for surf data
                        if uselut(iax)
                            mylut=lutc{iax};
                            ncplane=3;  %must always be 3; ncolplane now ignored
                            if truecolflag(iax)
                                myimg=MT_DATA{axnum}(lspec,cspec,:,ifn);
                            else
                                %inefficient if using grayscale for display
                                %but allows free choice of colormaps for multiple video displays
                                myimg=MT_DATA{axnum}(lspec,cspec,ifn);
                                myimg=cat(3,myimg,myimg,myimg);
                            end;
                            for iplane=1:ncplane
                                myimg(:,:,iplane)=intlut(myimg(:,:,iplane),mylut(:,iplane));
                            end;
                            set(hc(iax),'cdata',myimg);
                            
                        else
                            
                            if truecolflag(iax)
                                myimg=rgb2gray(MT_DATA{axnum}(lspec,cspec,:,ifn));
                                %convert to gray????
                            else
                                myimg=MT_DATA{axnum}(lspec,cspec,ifn);
                            end;
                            myimg=double(myimg);
                            
                            
                            
                            set(hc(iax),'cdata',double(myimg));
                        end;
                        
                        
                    end;    %ifn~=lastframe
                    
                    
                    
                end; %1:nax
                
                %do movie cursor in main window
                set (hmc,'xdata',[cuttime cuttime]);
                drawnow;
            end;	%current time in range
        end;%while ~finished
        sfuse=sf/delayfac;
        sf_estim=(1./(diff(timspec)*delayfac))*framecount;
        disp('data samplerate (using delay factor), and display rate');
        disp([sfuse(:) sf_estim(:)]);
        
    end;      %delayfac>delaylim
end;
%reset contour???
%        set (hs,'xdata',xbuf,'ydata',ybuf,'zdata',zbuf);
set (hmc,'visible','off');

%update title

figS.lastframe=lastframe;
figS.trial_number=thistrial;
set(hxyf,'userdata',figS);

%restore. See note on mt_audio
%mt_scurp(oldcurp);
figure(oldfigh);
%keyboard;

