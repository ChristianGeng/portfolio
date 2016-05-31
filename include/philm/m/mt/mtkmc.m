function mtkmc
% MTKMC mt user commands main_cursor
% function mtkmc
% mtkmc: Version 22.08.2013
%
%   Updates
%       08.2013 handle image update for both video and surf

persistent K
persistent Z        %structure for zerocrossing settings
persistent curtdiv
persistent curfastfac      %should not normally need changing
kname='mc';
if isempty(K)
   myS=load('mt_skey',['k_' kname]);
   K=getfield(myS,['k_' kname]);
   clear myS;
    Z.channel=mt_gcsid('audio_channel');
    Z.threshold=0;
    Z.polarity=1;
    Z.difforder=0;
curtdiv=1000;
curfastfac=10;
mlock;   
end;


curh=mt_gcurh;
curth=curh;		%see prepare xy below
curfree=mt_tcurs(curh,1);
timefigh=[mt_gfigh('mt_f(t)') mt_gfigh('mt_sona')];	%figures where mouse movement of time cursor is possible      
forename=mt_gfigd('foreground');      

audiochan=mt_gcsid('audio_channel');	%assumes not changed while cursor active
audiosf=mt_gsigv(audiochan,'samplerate');
%prepare xy contours
[xyindex,sfxy,timestampxy,xycontourh,xycontourhv]=mt_gxycd;
xyavailable=~isempty(xyindex);         
if xyavailable
   curth=[curth;xycontourh];         %so xy contours will be toggled by mt_tcurs
   
   oldconti=ones(size(xycontourh))*-1;               %for mt_shoco, force complete redrawing
   
else
   if strcmp('mt_xy',forename)
      disp('Warning: xy is foreground figure but no contours are available');
   end;
   
   
end;

%prepare for epg display
%needs upgrading for multiple displays, cf. mt_gxyd

doepg=0;
hfepg=mt_gfigh('mt_epg');
if ~isempty(hfepg)
   haepg=findobj(hfepg,'type','axes');
   epgS=get(haepg,'userdata');
   epgsigname=epgS.signal_name;
   epgpos=epgS.sensor_position;
   hlepg=findobj(haepg,'tag',[epgsigname '_data']);
   doepg=1;
end;






forefigh=mt_gfigh(forename);

%This is important for unix systems, should be irrelevant but harmless for Windows
%mouse is moved into target figure
%after leaving cursor level, mouse will be restored to old location
%assumed this was in the command window
oldmousep=get(0,'pointerlocation');
figurepos=get(forefigh,'position');
%set mouse to middle of figure
figurepos(1:2)=figurepos(1:2)+(figurepos(3:4)./2);
set(0,'pointerlocation',figurepos(1:2));


%make foreground figure with fullcrosshair cursor
oldpointer=get(forefigh,'pointer');
set(forefigh,'pointer','fullcrosshair');

figure (forefigh);

cursaxh=findobj(forefigh,'type','axes','tag','cursor_axis');


%cursor character is numeric (ginput has numeric result)
curchar=-1;

%assume display axis not modified while cursor on
timdat=mt_gdtim;
t0=timdat(1);
tend=timdat(2);

%cache any sub-cuts
innercache=mt_gscud;

%basic cursor increment is time/curtdiv
curinc=diff(timdat)/curtdiv;
set (curh,'visible','on');


sampincmax=mt_gcsid('max_sample_inc');



curprompt=[kname '>'];      
singlecursorkeys=[K.slowleft K.fastleft K.slowright K.fastright];
%!!must match length of "singlecursorkeys"
curincs=[-curinc -curinc*curfastfac curinc curinc*curfastfac];

zchansf=mt_gsigv(Z.channel,'samplerate');

clc;
disp(curprompt);		%unlike other command levels do not redisplay after every command
%cursor command loop =======================
while curchar~=K.return
   
   %here allow choice of "immediate mode" (via ginput)
   %or command mode via philinp
   %curchar=abs(philinp('C> '));
   drawnow;
   if philcomempty
      %make sure which axes input is coming from
      %otherwise mouse movement of cursor may have unpredicatable results
      if ~isempty(cursaxh) axes(cursaxh); end;
      [mousepx,mousepy,mousepz,curchar]=mmginput;
      if isempty(curchar) curchar=-1;end;
   else
      %doesnt work if mouse position used???
      curchar=philinp('');
      if length(curchar)~=1 curchar=-1; end;
      mousepx=[];
   end;
   
   %
   
   commandback=mtkcomm(curchar,K,'return');
   if commandback curchar=commandback; end;
   
   curincx=[0 0];
   curp=mt_gcurp(curh);
   %sort out desired cursor increment
   
   %cursor movement with mouse. Must be done differently if xy window in foreground
   if any(timefigh==forefigh)
      if curchar==K.leftcursor2pointer       %probably left button from ginput
         %temporary??? In case input from philinp???
         if ~isempty(mousepx)
            curincx=(-(curp-mousepx)).*[1 0];
         end;
         
      end;
      if curchar==K.rightcursor2pointer       %probably right button from ginput
         %temporary??? In case input from philinp???
         if ~isempty(mousepx)
            curincx=(-(curp-mousepx)).*[0 1];
         end;
         
      end;
   end;
   
   
   curind=find(singlecursorkeys==curchar);
   if ~isempty(curind)
      if length(curind)>1
         disp('cursor index corrupt');
         keyboard
      end;
      %!!!!!temporary
      if (curind>4)|(curind<1)
         disp('cursor index out of range');
         keyboard
      end;
      
      curincx=[curincs(curind) curincs(curind)];
      curincx=curincx.*curfree;
   end;
   
   
   if curchar==K.jumpleft
      curincx=curp(2)-curp(1);
      curdodo=curp(1)-t0;
      curincx=min(curdodo,curincx);
      curincx=[-(curincx) -(curincx)];
   end
   if curchar==K.jumpright
      curincx=curp(2)-curp(1);
      curdodo=(tend-sampincmax)-curp(2);
      curincx=min(curdodo,curincx);
      curincx=[curincx curincx];
   end
   
   if curchar==K.nextsubcut
      subpos=mt_finds('first','data','start','>',curp(1),innercache);
      if ~isempty(subpos)
         curincx=subpos(1:2)-curp;
      end;
   end;
   if curchar==K.previoussubcut
      subpos=mt_finds('last','data','start','<',curp(1),innercache);
      if ~isempty(subpos)
         curincx=subpos(1:2)-curp;
      end;
   end;
   if curchar==K.jumpmstart
      tmp=mt_gmark('start');
      if ~isempty(tmp)
         if ~isnan(tmp)
            curincx=tmp-curp;
            curincx=curincx.*curfree;
         end;
      end;
   end;
   if curchar==K.jumpmend
      tmp=mt_gmark('end');
      if ~isempty(tmp)
         if ~isnan(tmp)
            curincx=tmp-curp;
            curincx=curincx.*curfree;
         end;
      end;
   end;
   
   
   tmp=[];
   if curchar==K.nextzx
      tmp=mt_findz(Z.channel,Z.polarity,'>',Z.threshold,Z.difforder,zchansf,curh);
      if ~isempty(tmp)
         curincx=tmp-curp;
         curincx=curincx.*curfree;
      end;
   end;
   if curchar==K.previouszx
      tmp=mt_findz(Z.channel,Z.polarity,'<',Z.threshold,Z.difforder,zchansf,curh);
      if ~isempty(tmp)
         curincx=tmp-curp;
         curincx=curincx.*curfree;
      end;
   end;
   
   
   
   
   
   
   if any(curincx)
      %movement commands
      mt_scurp(curp+curincx,curh);
      if xyavailable
         drawnow;
         mypos=mt_gcurp(curh);
         newconti=mt_shoco(xyindex,sfxy,timestampxy,xycontourh,xycontourhv,mypos,oldconti);               
         oldconti=newconti;
      end;
      %flag for image autoupdate....
      %initialize to off, and only allow turning on if video available
      
      %positon of free cursor needed for video and epg
      curp=mt_gcurp(curh);
         vtime=curp(logical(curfree));   
         
        updateflag=mt_gfigd('autoimageupdateflag');
        if ~isempty(findstr('v',updateflag))
         mt_video(vtime);	%doesn't run as film if input arg is scalar
      end;
        if ~isempty(findstr('s',updateflag))
         mt_surf(vtime);	%doesn't run as film if input arg is scalar
      end;
      
      if doepg
         mt_epgdis(mt_gdata(epgsigname,vtime),epgpos,hlepg);
      end;
      
      
      
   else
      %non-movement cursor commands
      %=========================================
      
      if curchar == K.swap
         %swap free cursor
         %currently assumes cursor toggling only done from main program
         
         curfree=mt_tcurs(curth);
      end
      
      %===============================
      %audio
      if curchar==K.sound
         mtkmcs
         clc;
         disp(curprompt);
         
      end;
      
      
      %=========================================
      
      
      %change x/y view; desired xy axis must be current axis. This is easier to change
      % in cursor mode if xy is NOT the foreground figure!!???
      %3.02 changed to match new version of mt_sxyv
      
      if curchar==K.xyview
         if xyavailable
            
            %9.99 change to uicommand input
            tmpchar=uigetstring('Choose xy view (e.g xy, xz, zy, 3d): ');
            
            xycax=get(mt_gfigh('mt_xy'),'CurrentAxes');
            if ~isempty(tmpchar) mt_sxyv(get(xycax,'tag'),tmpchar); end;
         end;
         
      end;
      
      if curchar==K.marker
         mtkmcm;
         clc;
         disp(curprompt);
      end;
      
      if curchar==K.edit
         mtkmce;
         clc;
         disp(curprompt);
      end;
      
      
      if curchar==K.imageatcursor
         vtime=curp(logical(curfree));   
            tmph=mt_gfigh('mt_video');
            if ~isempty(tmph)
         mt_video(vtime);	%doesn't run as film if input arg is scalar
            end;
            tmph=mt_gfigh('mt_surf');
            if ~isempty(tmph)
         mt_surf(vtime);	%doesn't run as film if input arg is scalar
            end;
      end;
      
      
      if curchar==K.toggleautoimageupdate
         tmpflag=mt_gfigd('autoimageupdateflag');
         if ~isempty(tmpflag)
            disp('automatic image update disabled');
            tmpflag='';
         else
            tmph=mt_gfigh('mt_video');
            if ~isempty(tmph)
               disp('automatic image update enabled for video');
               tmpflag=[tmpflag 'v'];
            end;
            tmph=mt_gfigh('mt_surf');
            if ~isempty(tmph)
               disp('automatic image update enabled for surf');
               tmpflag=[tmpflag 's'];
            end;
         end;
         mt_sfigd('autoimageupdateflag',tmpflag);
      end;
      
        if curchar==K.zeroxsettings
            disp('Current zero-crossing settings are:')
            disp(Z);
            disp('Set fields of Z by hand, then type "return"');
%potentially dangerous! temporary procedure only
            keyboard;
            
%could also use to check for proper channel setting
            zchansf=mt_gsigv(Z.channel,'samplerate'); 
        end;
        
      
      % end divsion movement/non-movement
   end
   
   %end of while cursor
end
set (curh,'visible','off');
set(forefigh,'pointer',oldpointer);
clc;home;
%restore mouse position
set(0,'pointerlocation',oldmousep);
