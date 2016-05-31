function mt_video(timspec)
% MT_VIDEO Do video display
% function mt_video(timspec)
% mt_video: Version 28.08.2013
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
%       03.2012 start implementing truecolor support
%       04.2012 for multiple videos, remove requirement for same samplerate
%       and t0
%       08.2012 Use dimension variable to set 'xdata' and 'ydata'
%       properties of image
%       05.2013 start catching changes in image size between trials (e.g.
%       linspec and colspec out of range)
%       06.2013 handling of gamma and clim changed to allow more
%       flexibility with multiple video displays. Each video in effect has
%       its own colormap
%       08.2013 included scalemode property (default is 'manual', i.e. xlim
%       and ylim can be set by user (e.g. with mt_svideoad); if set to
%       'auto' then xlim and ylim are set by program to match linespec and
%       colspec settings
%
%   See also
%       MT_MOVIE for movie in xy display
%       MT_GVIDEOCD

%make it possible to access the signal data directly

global MT_DATA

[abint,abnoint,abscalar,abnoscalar]=abartdef;
oldfigh=gcf;

hxyf=mt_gfigh('mt_video');
if isempty(hxyf)
    disp ('mt_video: video display not initialized');
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
[axnames,xyindex,sf,timestamp,hc]=mt_gvideocd;

figS=get(hxyf,'userdata');
lastframe=figS.lastframe;
lasttrial=figS.trial_number;
thistrial=mt_gtrid('number');

if isempty(xyindex)
    disp('mt_video: No active axes');
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
    disp ('mt_video: Time spec completely outside video timestamp');
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
    myclim=mt_gvideoad(myname,'clim');
    
    mygamma=mt_gvideoad(myname,'gamma');
    %spec should just be the name of the colormap function
    %size has to be 256 of uint8 data (actually irrelevant for large data when
    %using cdatamapping scaled)
    mymapin=mt_gvideoad(myname,'colormap');
    try
    mymapin=feval(mymapin,256);
    catch
        disp(['Problem with colormap for ' myname]);
        disp('using gray');
        mymapin=gray(256);
    end;
    
    datasize=mt_gsigv(myname,'data_size');
    ndat(iax)=datasize(end);
    if length(datasize)==4
        truecolflag(iax)=1;
        ncolplane(iax)=datasize(3);
    end;
    mylut=mt_gvideoad(myname,'lut');
    lutc{iax}=mylut;
    if ~isempty(mylut) uselut(iax)=1; end;
    %check appropriate size?
    %e.g if truecolor and lut has only one column then expand
    
    %Procedure for implementing cdata and gamma depends on type of image
    %data.
%   major changes 06.2013
%for uint8 data (both grayscale (i.e. single plane) and truecolor) all scaling is done
%via look up tables. Grayscale data is in effect expanded to true color so
%that arbitrary color maps and scaling can be used for each display in multiple video
%displays (this is impossible if gamma and clim is handled via manipulation of the figure
%colormap)
%For non-uint8 data gamma is handled by manipulating the figure colormap,
%and clim by using cdatamapping scaled
%Note: If non-empty lookup tables are found in the axes data then these are used directly and
    %clim and gamma are ignored
    
    try
        
        %get class of data
        
        if strcmp(mt_gsigv(myname,'class_mem'),'uint8')
            
            myclim=myclim/255;
            %catch obvious errors in setting
            myclim(myclim<0)=0;
            myclim(myclim>1)=1;
            
                mymap=imadjust(gray(256),myclim,[],mygamma);
            if ~truecolflag(iax)
                %for arbitrary color maps, imadjust doesn't work quite as
                %expected (when the aim is to set up a lookup table
                tmpmap=round(mymap(:,1)*255)+1;
                mymap=mymapin(tmpmap,:);
            end;
            
            %6.2013 lut for all uint8 data
            %            if truecolflag(iax)
            %if lut already present use it
            if ~uselut(iax)
                mylut=uint8(mymap*255);
                lutc{iax}=mylut;
                uselut(iax)=1;
            end;
            %            else
            %                set(get(hax,'parent'),'colormap',mymap);
            %                set(hc(iax),'cdatamapping','direct');
            %                %                     set(hax,'clim',mt_gvideoad(myname,'clim'));
            %            end;
            
        else
            set(hax,'clim',myclim)
            set(hc(iax),'cdatamapping','scaled');
            mymap=imadjust(mymapin,[],[],mygamma);
            
            set(get(hax,'parent'),'colormap',mymap);
            %probably should also be done with lookup table
            %currently I think the program still crashes if it tries to use truecolor
            %that is not uint8.
            
            
            
        end;
        
    catch
        disp('mt_video: Unable to handle clim and/or gamma');
        disp(lasterr);
    end;
    
    lspec=mt_gvideoad(myname,'linespec');
    cspec=mt_gvideoad(myname,'colspec');
    
    if any(lspec>datasize(1))
        disp('mt_video: resetting line spec');
        lspec=1:datasize(1);
    end;
    if any(cspec>datasize(2))
        disp('mt_video: resetting col spec');
        cspec=1:datasize(2);
    end;
    
    lspecb{iax}=lspec;
    cspecb{iax}=cspec;
    
    %should be linked to dimension spec
    mydim=mt_gsigv(myname,'dimension');
    yvec=mydim.axis{1};
    xvec=mydim.axis{2};
    yvec=yvec(lspec);
    xvec=xvec(cspec);
    if strcmp(mt_gvideoad(myname,'scalemode'),'auto')
    try
        set(hax,'ylim',[yvec(1) yvec(end)],'xlim',[xvec(1) xvec(end)]);
        
    catch
        disp('mt_video: Unable to set xlim and ylim');
    end;
    end;
    
    
    ifn=round((timspec(1)-timestamp(iax,1))*sf(iax))+1;
    lastframe(iax)=ifn;
    
    try
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
            set(hc(iax),'xdata',xvec,'ydata',yvec,'cdata',myimg);
            
        else
            %currrently truecolor always uses lut; may be able to speed up slightly by allowing it to be skipped
            %otherwise, this branch is only for non-uint8 data
            if truecolflag
                set(hc(iax),'xdata',xvec,'ydata',yvec,'cdata',MT_DATA{axnum}(lspec,cspec,:,ifn));
            else
                set(hc(iax),'xdata',xvec,'ydata',yvec,'cdata',MT_DATA{axnum}(lspec,cspec,ifn));
            end;
        end;
    catch
        disp('mt_video: Unable to set up first frame');
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
                            %currrently truecolor always uses lut; may be able to speed up slightly by allowing it to be skipped
                            %otherwise, this branch is only for non-uint8 data
                            if truecolflag
                                set(hc(iax),'cdata',MT_DATA{axnum}(lspec,cspec,:,ifn));
                            else
                                set(hc(iax),'cdata',MT_DATA{axnum}(lspec,cspec,ifn));
                            end;
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

