function mt_iniepg(sonanames,subplotspec)
% MT_INIEPG Initialize epg display
% function mt_iniepg(sonanames,subplotspec)
% mt_iniepg: Version 9.5.2008
%
%	Syntax
%		sonanames: List of names for the video axes; currently must be identical to signal name
%		subplotspec: Optional. 2-element vector to specify arrangement of axes
%			Defaults to n_axes rows * 1 column
%
%	Remarks
%		General idea based on mt_inixy, mt_inisona, mt_inivideo
%		Details not worked out yet
%
%	Description
%		This lists the fields in the userdata of the video figure, and then in the userdata of each axes
%
%		Figure
%
%			axis_names
%				set to input argument xynames
%
%			display_flag
%				enable/disable axes for display (vector of 0s or 1s corresponding to each axes
%
%			lastframe
%				for use with single frame display in cursor mode
%				to avoid unnecessary image update
%				assumes same frames if multiple axes
%				
%
%		Axes
%
% not all really used yet.......
%			signal_name
%			signal_number   
%			clim
%			linespec
%			colspec
%			axis_number
%			samplerate
%			time_spec
%			trial_number



xynames=sonanames;	%this function based on mt_inixy

figtag='mt_epg';
nax=size(xynames,1);

%alternative if called with no args. delete fig, but also in mt_org figure axis???

myversion=version;	%only needed for graphics details

if nax
   hh=mt_gfigh(figtag);
   if ~isempty(hh)
      %confirmation??
      disp('mt_iniepg: Resetting epg display');
      delete(hh);
      
      
   end;
   hh=figure;
   myS.axis_names=xynames;
   myS.display_flag=ones(nax,1);		%all axes enabled for display
   myS.lastframe=0;
%   set(hh,'tag',[figtag mt_gsnum(1)],'userdata',myS,'papertype','a4letter','pointer','fullcrosshair');%more settings?????
%5.08 removed crosshair cursor
set(hh,'tag',[figtag mt_gsnum(1)],'userdata',myS,'papertype','a4letter');%more settings?????
   set(hh,'numbertitle','off','menubar','none');
   set(hh,'name',[int2str(hh) ': ' get(mt_gfigh(figtag),'tag')]);
   
   %sort out subplot arrangement
   usesubplot=0;
   if nargin>1
      if length(subplotspec)==2
         if subplotspec(1)*subplotspec(2)>=nax
            usesubplot=1;
         end;
      end;
   end;
   if usesubplot
      sprow=subplotspec(1);spcol=subplotspec(2);
   else
      sprow=nax;spcol=1;
   end;
   
   %initialize the struct for the userdata of each axis
   myS=struct(...
      'signal_name','',...
      'signal_number',[],...   
      'clim',[0 255],...
    'sensor_position',[],...  
   'axis_number',1,...
      'samplerate',[],...
      'time_spec',[],...
      'trial_number',[]...
      );
   
   myfonts=[16 14 14 12 12 12 10 10];
   naxx=sprow*spcol;
   if naxx>length(myfonts)
      myfs=8;
   else
      myfs=myfonts(naxx);
   end;
   
   
   signallist=mt_gcsid('signal_list');
   
   for ii=1:nax
      myname=deblank(xynames(ii,:));
      ha=subplot(sprow,spcol,ii);
      habuf(ii)=ha;
      myS.axis_number=ii;
      
      
      
      title(myname,'interpreter','none','fontsize',myfs);
      
      %more initializing if axis is also a signal
      
      %dimension.external structure must be present, to define electrode (sensor) positions
      
      
      vs=strmatch(myname,signallist,'exact');
      if length(vs)==1
         myS.signal_name=myname;
         myS.samplerate=mt_gsigv(myname,'samplerate');
         myS.signal_number=mt_gsigv(myname,'signal_number');
         
         sigunit=mt_gsigv(myname,'unit');
         mydim=mt_gsigv(myname,'dimension');
         myD=mydim.external;
         
         dimd=myD.descriptor;
         dimu=myD.unit;
         
         nd=size(dimd,1);
         
         xlabel([deblank(dimd(1,:)) ' (' deblank(dimu(1,:)) ')'],'interpreter','none','fontsize',myfs);
         ylabel([deblank(dimd(2,:)) ' (' deblank(dimu(2,:)) ')'],'interpreter','none','fontsize',myfs);
         
         if nd>2
            zlabel([deblank(dimd(3,:)) ' (' deblank(dimu(3,:)) ')'],'interpreter','none','fontsize',myfs);
         end;
         
         datasize=mt_gsigv(myname,'data_size');
         
         %length of axis vectors should be same as 1st dimension of datasize
         
         dima=myD.axis;
         
         sensor_position=[dima{1} dima{2}];
         if nd>2 
            sensor_position=[sensor_position dima{3}];
         else
            sensor_position=[sensor_position zeros(size(sensor_position,1),1)];
            
         end;
         
         myS.sensor_position=sensor_position;
         
         %set axis limits?
         axis('equal');			%should normally be appropriate
         
         
         %first line remains unchanged, to mark sensor positions
         %second line shows current activated sensors
         
         %second line could easily be replaced by surface or patch for more complicated sensors
         %with signal amplitude given by colour
         
%         hl1=line(sensor_position(:,1),sensor_position(:,2),sensor_position(:,3),'linestyle','none','marker','.','erasemode','xor');
         hl1=line(sensor_position(:,1),sensor_position(:,2),sensor_position(:,3),'linestyle','none','marker','.');
         %marker size better proportional???
%         hl2=line(sensor_position(:,1),sensor_position(:,2),sensor_position(:,3),'linestyle','none','marker','o','markersize',20,'erasemode','xor');
         hl2=line(sensor_position(:,1),sensor_position(:,2),sensor_position(:,3),'linestyle','none','marker','o','markersize',10);
         
         set(hl1,'tag',[myname '_sensor_position']);
         set(hl2,'tag',[myname '_data']);
         
         
      else
         disp(['mt_iniepg; Not a signal? ' myname]);
      end;		%initialize signal
      
      set(ha,'tag',myname,'userdata',myS);
      
      
   end;	%nax loop
   
   
   
   %what happens if xy figure is deleted????
   
   figlist=mt_gfigd('figure_list');
   vi=strmatch('mt_epg',figlist);
   if isempty(vi) figlist=str2mat(figlist,'mt_epg');end;
   
   mt_sfigd('figure_list',figlist);
   
   
   
end;	%nax not zero
