function mt_video2avi(outfile,timspec,delayfac,idown,wienerorder)
% MT_VIDEO2AVI Run video display and store as AVI, linking video and sonagram displays
% function mt_video2avi(outfile,timspec,delayfac,idown,wienerorder)
% MT_VIDEO2AVI: Version 4.3.2001
%
% Syntax
%   	timspec: (2-element vector) is time (in s) relative to current trial
%		delayfac:	playback speed relative to real time
%		idown:	Downsampling rate of movement data
%		wienerorder: optional; order of Wiener filter; default to 3.
%			(can also be specified as 2-element vector if non-square filter desired)
%			If appropriate, smoothing can allow more compression
%			e.g with sorensen codec in quicktime
%
% See Also MT_VIDEOQT MT_MOVIE2TIF
%
%	Description


%make it possible to access the signal data directly

global MT_DATA


nwiener=3;
if nargin>4 nwiener=wienerorder; end;

if length(nwiener)==1 nwiener=[nwiener nwiener]; end;

%adjust figure to make room for sonagram

hv=mt_gfigh('mt_video');
hs=mt_gfigh('mt_sona');

dosona=0;
if ~isempty(hs) dosona=1;end;

if dosona
   
   hvpos=get(hv,'position');
   hspos=get(hs,'position');
   
   %simply make sure sona fig is same width as video fig
   %other arrangements could easily be implemented
   
   hspos(3)=hvpos(3);
   
   set(hs,'position',hspos);
   
   set(hs,'colormap',gray(256));
   
   
   
   
   
   
   oldway=0;
   if oldway
      
      hvposold=hvpos;
      hvpos(4)=hvpos(4)+hvpos(4)/3;
      set(hv,'position',hvpos);
      hva=findobj(hv,'type','axes');
      hvapos=get(hva,'position')
      hvaposold=hvapos;
      hvapos(2)=0;
      set(hva,'position',hvapos)
      set(hva,'visible','off')
      hsa=findobj(hs,'type','axes')
      
      hsa=hsa(1);
      copyobj(hsa,hv)
      hsv=findobj(hv,'tag','SONA','type','axes')
      hsvpos=get(hsv,'position')
      hsvpos(2)=0.75;
      hsvpos(4)=0.2;
      set(hsv,'position',hsvpos)
      
      oldax=gca;
      axes(hsv);
      myylim=get(gca,'ylim');
      mycursorh=line([0 0],myylim,'linewidth',2,'color','w');
      
      axes(oldax);
   end;		%old way
   
end;		%dosona

hva=findobj(hv,'type','axes');
set(hva,'visible','off')

%used below to insert title and timecounter
hvx=get(hva,'xlabel');
%simpler title

mytit='';
%mytit=mt_gtrid('label');
set(hvx,'string',mytit,'fontsize',14,'fontweight','bold','visible','on','vertical','bottom','horizontal','center');
set(hvx,'visible','on');


oldfigh=gcf;

hxyf=mt_gfigh('mt_video');
if isempty(hxyf)
   disp ('mt_videox: video display not initialized');
   return;
end;
figure(hxyf);                 %make sure figure visible

set(hxyf,'pointer','crosshair');

%get movie cursor in main window
hmc=mt_gfigd('time_cursor_handles');
hmc=hmc(:,3);


%xyindex is the signal number to use with MT_DATA
%hc is the handle to the image object

[axnames,xyindex,sf,timestamp,hc]=mt_gvideocd(1);

if isempty(xyindex)
   disp('mt_videox: No active axes');
   return;
end;
nax=length(xyindex);        


moviesf=sf/(delayfac*idown);

disp(['Video frame rate is  ' num2str(moviesf)]);


%disp(['Choose ' num2str(sf/(delayfac*idown)) ' Hz as video frame rate']);



%timestamp must be same for all axes

if ((timspec(1)>=timestamp(2))|(timspec(2)<=timestamp(1)))
   disp ('mt_videox: Time spec completely outside video timestamp');
   return;
end;


%only needed til mt_audio is upgraded
oldcurp=mt_gcurp;

disp(['Time requested : ' num2str(timspec)])


timspec(1)=max([timspec(1) timestamp(1)]);
timspec(2)=min([timspec(2) timestamp(2)]);

disp(['Time used : ' num2str(timspec)])




audiochan=mt_gcsid('audio_channel');
audiosf=mt_gsigv(audiochan,'samplerate');

%????[ndat,ntraj]=size(MT_XYDATA{xyindex(1),1});



sampinc=1./sf;

%determine start and end frame

ndat=size(MT_DATA{xyindex(1)},3);		%not a good way!!!!???


framen=timspec-timestamp(1);
framen=round(framen*sf);
framen(1)=framen(1)+1;

framen(1)=max([framen(1) 1]);
framen(2)=min([framen(2) ndat]);

ifdig=length(int2str(framen(2)));		%for output file name


if diff(framen)<=0
   disp ('mt_videox: 0 frames');
   return
end;

tmptime=timestamp(1)+([(framen(1)-1) framen(2)]*sampinc);

mt_scurp(timspec);


%get audio data and store as wav
adat=mt_gdata(audiochan,tmptime);
wavwrite(adat/max(abs(adat)),audiosf./delayfac,16,outfile);

%havi=avifile(outfile,'compression','Indeo5','quality',100,'FPS',moviesf,'colormap',mymap);
havi=avifile(outfile,'compression','Indeo5','quality',100,'FPS',moviesf);
%havi=avifile(outfile,'compression','cinepak','quality',100,'FPS',moviesf);

%time indicator in frame?????

ifnum=1;





lspecb=cell(nax,1);
cpsecb=cell(nax,1);

for iax=1:nax
   myname=deblank(axnames(iax,:));
   axnum=xyindex(iax);
   hax=get(hc(iax),'parent');
   myclim=mt_gvideoad(myname,'clim');
   
   mygamma=mt_gvideoad(myname,'gamma');
   
   %should have a choice here
   %as display is faster for non-scaled images
   %it is usually better to try and implement the clim setting
   %by manipulating the colormap, rather the axes clim itself
   %note: may be problems for multiple video displays that require different settings
   %		In those cases it may be necessary to force colormapping to be scaled
   
   try
      
      %get class of data
      
      if strcmp(mt_gsigv(myname,'class_mem'),'uint8')
         
         myclim=myclim/255;
         myclim(1)=max([myclim(1) 0]);
         myclim(2)=min([myclim(2) 1]);
         
         mymap=imadjust(gray(256),myclim,[],mygamma);
         
         
         set(get(hax,'parent'),'colormap',mymap);
         set(hc(iax),'cdatamapping','direct');
         %                     set(hax,'clim',mt_gvideoad(myname,'clim'));
      else 
         set(hax,'clim',myclim)
         set(hc(iax),'cdatamapping','scaled');
         if gamma~=1
            disp('gamma correction not yet implemented for data types larger than 8bit');
         end;
         
         
         %      'cdatamapping','scaled');
         
      end;
      
   catch
      disp('mt_video: Unable to set clim');
   end;
   
   lspec=mt_gvideoad(myname,'linespec');
   cspec=mt_gvideoad(myname,'colspec');
   
   lspecb{iax}=lspec;
   cspecb{iax}=cspec;
   
   %should be linked to dimension spec
   try
      
      set(hax,'xlim',[cspec(1) cspec(end)],'ylim',[lspec(1) lspec(end)]);
   catch
      disp('mt_video: Unable to set xlim and ylim');
   end;
end;

%if only 1 axes?????
%               scratch=MT_DATA{xyindex(1)}(lspecb{1},cspecb{1},framen(1):framen(end));




set (hmc,'visible','on','linewidth',2);


ifn=framen(1);

cuttime=timestamp(1)+((ifn-1)*sampinc);

for iax=1:nax
   axnum=xyindex(iax);
   lspec=lspecb{iax};
   cspec=cspecb{iax};
   try
      myframe=MT_DATA{axnum}(lspec,cspec,ifn);
      
      %image processing for xray
      %      myframe=histeq(myframe);
      %      myframe=wiener2(myframe,[5 5],0.0024);
      set(hc(iax),'xdata',cspec,'ydata',lspec,'cdata',myframe);
      
      
   catch
      disp('mt_video: Unable to set up first frame');
   end;
   
   
   
end;						%nax

%do movie cursor in main window
set (hmc,'xdata',[cuttime cuttime]);

%and in duplicate sonagram in videowindow

%if dosona set (mycursorh,'xdata',[cuttime cuttime]); end;

drawnow;



%do sound anyway??
mt_audio('cursor',audiochan,audiosf./delayfac);
%      tic;

for ifn=framen(1):idown:framen(2)
   cuttime=timestamp(1)+((ifn-1)*sampinc);
cliptime=(ifnum-1)*sampinc;

   for iax=1:nax
      axnum=xyindex(iax);
      lspec=lspecb{iax};
      cspec=cspecb{iax};
      myframe=MT_DATA{axnum}(lspec,cspec,ifn);
      
      
      
      
      if any(nwiener>2)
         myframe=wiener2(myframe,nwiener);
      end;
      
      
      set(hc(iax),'cdata',myframe);
      
%      timestring=int2str0(round(cuttime*1000),4);
      timestring=int2str0(round(cliptime*1000),4);
      set(hvx,'string',[mytit '     ' timestring]);

   %do movie cursor in main and sona windows
   set (hmc,'xdata',[cuttime cuttime]);
   
   
   
   
   drawnow;
      
      
      xim=getframe(hv);
      if size(xim.cdata,3)~=3
         disp('Image not rgb?')
      end;
      xout=xim;
if dosona
      xims=getframe(hs);
      xout=[xout;xims];
  end;
  
havi=addframe(havi,xout);   




      
%      imwrite([xim.cdata(:,:,1);xims.cdata(:,:,1)],[outfile int2str0(ifnum,ifdig) '.tif'],'TIF')
      %      imwrite([xim;xims],[outfile int2str0(ifnum,ifdig) '.tif'],'TIF')
      ifnum=ifnum+1;   
      
      
   end;
   %                  set(hc(iax),'cdata',scratch(:,:,(ifn-framen(1)+1)));
   
end;%ifn<

havi=close(havi);


%reset contour???
%        set (hs,'xdata',xbuf,'ydata',ybuf,'zdata',zbuf);



set (hmc,'visible','off');

%update title


%restore. See note on mt_audio
mt_scurp(oldcurp);
figure(oldfigh);

%if dosona
%   delete(hsv);
%   set(hv,'position',hvposold);
%   set(hva,'position',hvaposold);
%end;
