function mt_videoqt(qtfile,timspec,delayfac,idown,jpegqual)
% MT_VIDEOQT Run video display and store as quick time, merging video and sonagram displays
% function mt_videoqt(qtfile,timspec,delayfac,idown,jpegqual)
%
% See Also MAKEQTMOVIE
%
%   Note
%       Not very useful as only allows JPEG compression

% mt_videox Do video display
% function mt_videox(timspec)
% mt_videox: Version 21.5.2000
%
% Syntax
%   timspec (2-element vector) is time (in s) relative to current trial
%
%
% See also
%		MT_VIDEO 
%	MT_MOVIE for movie in xy display
% mt_xydis for xy display. mt_shoco and mt_gxycd for other contour oriented routines

%make it possible to access the signal data directly

global MT_DATA

%adjust figure to make room for sonagram

hv=mt_gfigh('mt_video')
hs=mt_gfigh('mt_sona')
hvpos=get(hv,'position');
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




%[abint,abnoint,abscalar,abnoscalar]=abartdef;
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

%delayfac=1;                       %could be loaded from mat file
%delaylim=0.01;                    %1/delaylim is limit on speed up

%May eventually need something similar for video display
%but xy display is more complicated as data has to be prepared for contours

%xyindex is the signal number to use with MT_DATA
%hc is the handle to the image object

[axnames,xyindex,sf,timestamp,hc]=mt_gvideocd(1);

if isempty(xyindex)
   disp('mt_videox: No active axes');
   return;
end;
nax=length(xyindex);        

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

mt_scurp(timspec);



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

if diff(framen)<=0
   disp ('mt_videox: 0 frames');
   return
end;

makeQTmovie('start',qtfile);
makeQTmovie('quality',jpegqual);
makeQTmovie('framerate',sf/delayfac);
makeQTmovie('addsound',mt_gdata(audiochan,timspec),audiosf/delayfac)

lspecb=cell(nax,1);
cpsecb=cell(nax,1);

for iax=1:nax
   myname=deblank(axnames(iax,:));
   axnum=xyindex(iax);
   hax=get(hc(iax),'parent');
   myclim=mt_gvideoad(myname,'clim');
   
   %should have a choice here
   %as display is faster for non-scaled images
   %it is usually better to try and implement the clim setting
   %by manipulating the colormap, rather the axes clim itself
   try
      set(get(hax,'parent'),'colormap',gray(myclim(2)));
      %                     set(hax,'clim',mt_gvideoad(myname,'clim'));
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


%disp ('Movie delay factor: <1 to speed up, >1 to slow down, 0 to exit');
%while delayfac>delaylim
%   delayfac=abart('Delay factor',delayfac,0,1./delaylim,abnoint,abscalar);
%   if delayfac>delaylim

%do sound???
%      ticinterval=sampinc*delayfac;

set (hmc,'visible','on');


ifn=framen(1);

cuttime=timestamp(1)+((ifn-1)*sampinc);

for iax=1:nax
   axnum=xyindex(iax);
   lspec=lspecb{iax};
   cspec=cspecb{iax};
   try
      
      set(hc(iax),'xdata',cspec,'ydata',lspec,'cdata',MT_DATA{axnum}(lspec,cspec,ifn));
      
      
   catch
      disp('mt_video: Unable to set up first frame');
   end;
   
   
   
end;						%nax

%do movie cursor in main window
set (hmc,'xdata',[cuttime cuttime]);

%and in duplicate sonagram in videowindow

set (mycursorh,'xdata',[cuttime cuttime]);
drawnow;



%		framelist=ones(1,ndat)*NaN;      
%      framepoint=1;

%      lasttoc=0;
%      lastframe=1;
%temporary!!!!!
%do sound anyway??
mt_audio('cursor',audiochan,audiosf./delayfac);
%      tic;

for ifn=framen(1):idown:framen(2)
   %while lastframe<framen(2)
   %         itoc=toc;
   %         if itoc~=lasttoc
   %            ifn=framen(1)+round(itoc./ticinterval);
   
   %            if ifn>framen(2) ifn=framen(2);end;
   
   %            if ifn~=lastframe
   cuttime=timestamp(1)+((ifn-1)*sampinc);
   
   for iax=1:nax
      axnum=xyindex(iax);
      lspec=lspecb{iax};
      cspec=cspecb{iax};
      set(hc(iax),'cdata',MT_DATA{axnum}(lspec,cspec,ifn));
      %%%%write figure to quick time......?????   
      makeQTmovie('addfigure',MT_DATA{axnum}(lspec,cspec,ifn))
   end;
   %                  set(hc(iax),'cdata',scratch(:,:,(ifn-framen(1)+1)));
   
   %do movie cursor in main window
   set (hmc,'xdata',[cuttime cuttime]);
   
   %and in duplicated sonagram
   
   set (mycursorh,'xdata',[cuttime cuttime]);
   
   
   
   drawnow;
   %               lastframe=ifn;
   %            		framelist(framepoint)=ifn; framepoint=framepoint+1;   
   %            end;	%ifn ne lastframe
   
   %               lasttoc=itoc;
   %         end; %itoc~=lasttoc
end;%ifn<

%      disp(['Frames requested: ' int2str(framen(2)-framen(1)+1)]);
%      vv=find(~isnan(framelist));
%      disp(['Frames displayed: ' int2str(length(vv))]);

%      disp(framelist);      
%   end;      %delayfac>delaylim
end;
%reset contour???
%        set (hs,'xdata',xbuf,'ydata',ybuf,'zdata',zbuf);


%write sound data, with sf
%write video frame rate
%close qt file
%duplicate last frame
makeQTmovie('addfigure',MT_DATA{axnum}(lspec,cspec,framen(2)))

makeQTmovie('finish');

set (hmc,'visible','off');

%update title


%restore. See note on mt_audio
mt_scurp(oldcurp);
figure(oldfigh);

delete(hsv);
set(hv,'position',hvposold);
set(hva,'position',hvaposold);
