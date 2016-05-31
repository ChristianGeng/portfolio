function mt_movie2avi(outfile,timspec,delayfac,idown,newtitle,addfig,addfigpos)
% MT_MOVIE2AVI Store movie display as series of TIF files (plus WAV for audio);
% function mt_movie2avi(outfile,timspec,delayfac,idown,addfig,addfigpos)
% mt_movie2avi: Version 24.11.2004
%
%	Syntax
%		outfile: filename (without extension) for output
%   	timspec: (2-element vector) is time (in s) relative to current trial
%		delayfac:	
%		idown:	Downsampling rate of movement data
%       newtitle: Optional. If missing, or present but empty, keep old title
%		addfig:	If present and a figure handle, then this figure will be resized to the same size
%					as the xy display and combined with it (on its left) in the output files
%					Mainly designed for timewave figure (also for sonagram: cf mt_video2tif)
%					Either determine figure handle by inspection or use e.g
%						mt_gfigh('mt_f(t)');
%						mt_gfigh('mt_sona');
%       addfigpos:  Optional. 1 (default)= add figure on left, 2= add below
%
%	See also
%		MT_VIDEOQT Video to quicktime, MT_VIDEO2TIF Video (and sona) to TIF
%		mt_xydis for xy display. mt_shoco and mt_gxycd for other contour oriented routines

global MT_XYDATA
global MT_XYVDATA

[abint,abnoint,abscalar,abnoscalar]=abartdef;



oldf=gcf;

hxyf=mt_gfigh('mt_xy');
if isempty(hxyf)
   disp ('mt_movie: xy display not initialized');
   return;
end;

mymap=get(hxyf,'colormap');
myfixcol=get(hxyf,'fixedcolors');
mymap=[mymap;myfixcol];

%get movie cursor in main window
hmc=mt_gfigd('time_cursor_handles');
hmc=hmc(:,3);

newtit='';
if nargin>4 newtit=newtitle; end;



doaddfig=0;
if nargin>5
   addfigh=addfig;
   if ishandle(addfigh)
      %assume its a figure; should check!!!
      doaddfig=1;

      if nargin>6
          doaddfig=addfigpos;
      end;
      
      %make same size
      
      sxy=get(hxyf,'position');
      sadd=get(addfigh,'position');

    %match height
      if doaddfig==1
      sadd(4)=sxy(4);
  end;
%match width
  if doaddfig==2
      sadd(3)=sxy(3);
      
      
  end;
      
      
  haddlin=findobj(addfigh,'type','line');
  set(haddlin,'linewidth',2);   %restore at end?
      
      set(addfigh,'position',sadd);
      
      
   end;
end;




[xyindex,sf,timestamp,hc,hcv]=mt_gxycd(1);

moviesf=sf/(delayfac*idown);

disp(['Video frame rate is  ' num2str(moviesf)]);




vactive=~isnan(hcv);

if isempty(xyindex)
   disp('mt_movie: No active axes');
   return;
end;
nax=length(xyindex);        

if ((timspec(1)>=timestamp(2))|(timspec(2)<=timestamp(1)))
   disp ('mt_movie: Time spec completely outside xy timestamp');
   return;
end;





audiochan=mt_gcsid('audio_channel');
audiosf=mt_gsigv(audiochan,'samplerate');


[ndat,ntraj]=size(MT_XYDATA{xyindex(1),1});



sampinc=1./sf;

%determine start and end frame
framen=timspec-timestamp(1);
framen=round(framen*sf);
framen(1)=framen(1)+1;

framen(1)=max([framen(1) 1]);
framen(2)=min([framen(2) ndat]);

ifdig=length(int2str(framen(2)));


if diff(framen)<=0
   disp ('mt_movie: 0 frames');
   return
end;


%only needed til mt_audio is upgraded

oldcurp=mt_gcurp;

tmptime=timestamp(1)+([(framen(1)-1) framen(2)]*sampinc);

mt_scurp(tmptime);






figure(hxyf);                 %make sure figure visible

if ~isempty(newtit)
    htit=get(gca,'title');
    set(htit,'string',newtit,'fontweight','bold');  %should restore at end
end;




%create a colorbar as time axis

hcolb=colorbar('horizontal');

%create a line as time cursor

oldax=gca;
axes(hcolb);
hcolbl=line([0 0],get(hcolb,'ylim'),'color','w','linewidth',2);
%keyboard;
xlabel('Time (s)','fontweight','bold');

%make it a bit thinner (tends to overlap xlabel of xy display)
ppp=get(hcolb,'position');
ppp(4)=ppp(4)/2;
set(hcolb,'position',ppp);

axes(oldax);
%                 set (hc,'linewidth',2);
set(hc,'visible','on');
set(hcv(vactive),'visible','on');
set (hmc,'visible','on');

%get audio data and store as wav
adat=mt_gdata(audiochan,tmptime);
wavwrite(0.9*(adat/max(abs(adat))),audiosf./delayfac,16,outfile);
wavwrite(0.9*(adat/max(abs(adat))),audiosf,16,[outfile '_org']);    %e.g for manipulation with praat

%only works for powers of 2
aloop=round(log2(delayfac));

for iii=1:aloop
wavwrite(0.9*(adat/max(abs(adat))),audiosf,16,'tst');    %e.g for manipulation with praat

eval('!"d:\program files\praat\praatcon" praatstretch.txt');

[adat,tmpsf]=wavread('tst_2');

end;

wavwrite(0.9*(adat/max(abs(adat))),audiosf,16,[outfile '_stretch']);

mt_audio('cursor',audiochan,audiosf./delayfac);

havi=avifile(outfile,'compression','RLE','quality',100,'FPS',moviesf,'colormap',mymap);

ifnum=1;

for ifn=framen(1):idown:framen(2)
   cuttime=timestamp(1)+((ifn-1)*sampinc);
   trajtime=(ifn-1)*sampinc;
   
   figure(hxyf);
   
   for iax=1:nax
      axnum=xyindex(iax);
      set(hc(iax),'xdata',MT_XYDATA{axnum,1}(ifn,:),'ydata',MT_XYDATA{axnum,2}(ifn,:),'zdata',MT_XYDATA{axnum,3}(ifn,:));
      if vactive(iax)
         set(hcv(iax),'xdata',MT_XYVDATA{axnum,1}(ifn,:),'ydata',MT_XYVDATA{axnum,2}(ifn,:),'zdata',MT_XYVDATA{axnum,3}(ifn,:));
      end;
      
   end;
   
   %do movie cursor in main window
   set (hmc,'xdata',[cuttime cuttime]);

   %do time cursor in colorbar
   set (hcolbl,'xdata',[trajtime trajtime]);
   
   drawnow;
   
   xim=getframe(gcf);
   if size(xim.cdata,3)~=3
      disp('Image not rgb?')
   end;
   xout=xim.cdata;
    xout=rgb2ind(xout,mymap,'nodither');
   
%note yet sorted out with indexed color
    if doaddfig
      figure(addfigh);
	   ximadd=getframe(gcf);
   ximadd=ximadd.cdata;
    ximadd=rgb2ind(ximadd,mymap,'nodither');
    if doaddfig==1
    xout=[ximadd xout];
end;
    if doaddfig==2
    xout=[xout;ximadd];
end;
   end;
   
havi=addframe(havi,xout);   
%   imwrite(xout,[outfile int2str0(ifnum,ifdig) '.tif'],'TIF')
	ifnum=ifnum+1;   
   
end;	%ifn<


havi=close(havi);


%reset contour???
%        set (hs,'xdata',xbuf,'ydata',ybuf,'zdata',zbuf);
set (hmc,'visible','off');
set(hc,'visible','off');
set(hcv(vactive),'visible','off');

%restore. See note on mt_audio
mt_scurp(oldcurp);

figure(oldf);
delete(hcolb);
