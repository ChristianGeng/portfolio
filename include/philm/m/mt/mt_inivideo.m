function mt_inivideo(sonanames,subplotspec)
% MT_INIVIDEO Initialize video display
% function mt_inivideo(sonanames,subplotspec)
% mt_inivideo: Version 14.06.2013
%
%	Syntax
%		sonanames: List of names for the video axes; currently must be identical to signal name
%		subplotspec: Optional. 2-element vector to specify arrangement of axes
%			Defaults to n_axes rows * 1 column
%
%	Remarks
%		General idea based on mt_inixy and mt_inisona
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
%			sub_cut_flag
%				enable/disable subcut display in ALL axes
%
%			display_flag
%				enable/disable axes for display (vector of 0s or 1s corresponding to each axes
%
%			lastframe and trial_number
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
%			gamma
%			linespec
%			colspec
%			axis_number
%			samplerate
%			time_spec
%			trial_number
%           lut      
%
%   Updates
%       03.2012 Added lut (look up table) field (mainly used inside
%       mt_video for handling contrast and gamma of truecolor images, but
%       could also be set externally by the user for special effects)
%       08.2012 Use dimension variable to set 'xdata' and 'ydata'
%       properties of image
%       06.2013 Include colormap field for all axes (preparation for
%       handling all uint8 data like truecolor)

xynames=sonanames;	%this function based on mt_inixy

figtag='mt_video';
nax=size(xynames,1);

%alternative if called with no args. delete fig, but also in mt_org figure axis???

myversion=version;	%only needed for graphics details

if nax
   hh=mt_gfigh(figtag);
   if ~isempty(hh)
      %confirmation??
      disp('mt_inivideo: Resetting video display');
      delete(hh);
      
      
   end;
   hh=figure;
   myS.axis_names=xynames;
   myS.sub_cut_flag=0;					%enable/disable subcut display in ALL axes
   myS.display_flag=ones(nax,1);		%all axes enabled for display
   myS.lastframe=0;
   myS.trial_number=0;
   
   set(hh,'tag',[figtag mt_gsnum(1)],'userdata',myS,'papertype','a4letter','pointer','fullcrosshair','colormap',gray(256));%more settings?????
   set(hh,'numbertitle','off','menubar','none');
		set(hh,'name',[int2str(hh) ': ' get(mt_gfigh(figtag),'tag')]);
   %needed????	set(hh,'doublebuffer','on');   
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

   %initialize the struct for the userdata of each axis
   myS=struct(...
      'signal_name','',...
      'signal_number',[],...   
      'clim',[0 255],...
      'gamma',1,...
      'colormap','gray',...
      'lut',[],...
      'linespec',[],...
      'colspec',[],...
      'scalemode','manual',...
      'axis_number',1,...
      'samplerate',[],...
      'time_spec',[],...
      'trial_number',[]...
      );
      
      habuf(ii)=ha;
      myS.axis_number=ii;
      
      
      
      title(myname,'interpreter','none','fontsize',myfs);
      
      %more initializing if axis is also a signal
      vs=strmatch(myname,signallist,'exact');
      if length(vs)==1
         myS.signal_name=myname;
         myS.samplerate=mt_gsigv(myname,'samplerate');
         myS.signal_number=mt_gsigv(myname,'signal_number');
         
         sigunit=mt_gsigv(myname,'unit');
         mydim=mt_gsigv(myname,'dimension');
         dimd=deblank(mydim.descriptor(1,:));
         dimu=deblank(mydim.unit(1,:));
         ylabel([dimd ' (' dimu ')'],'interpreter','none','fontsize',myfs);
         dimd=deblank(mydim.descriptor(2,:));
         dimu=deblank(mydim.unit(2,:));
         xlabel([dimd ' (' dimu ')'],'interpreter','none','fontsize',myfs);
         
         datasize=mt_gsigv(myname,'data_size');
         myS.linespec=(1:datasize(1));
         myS.colspec=(1:datasize(2));
         
         %this needs linking with dimension.axis
         %include xdata and ydata; ydir???
%         set(gca,'ydir','reverse');
          yvec=mydim.axis{1};
          xvec=mydim.axis{2};
         set(gca,'ylim',[yvec(1) yvec(end)],'xlim',[xvec(1) xvec(end)]);
         axis('equal');
         hold on
         hc=image(xvec,yvec,zeros(datasize(1),datasize(2)));
%         hc=imagesc(zeros(datasize(1),datasize(2)),myS.clim);
         set(hc,'tag',myname,'erasemode','none');
         hold off   
      else
          %mt_inisona sets myS to [], but not sure this is handled
          %correctly by mt_gvideocd and mt_video, so better not to continue
          %if signal not found
          disp(['mt_inivideo; Not a signal? ' myname]);
        disp('Correct the input argument to mt_inivideo and try again');
        keyboard;
         
      end;		%initialize signal
      
      set(ha,'tag',myname,'userdata',myS);
      
      
   end;	%nax loop
   
   
   %loop to set up colorbars. This will shift the axes position???? cf. mt_inisona
   
   %what happens if xy figure is deleted????
   
   figlist=mt_gfigd('figure_list');
   vi=strmatch('mt_video',figlist);
   if isempty(vi) figlist=str2mat(figlist,'mt_video');end;
   
   mt_sfigd('figure_list',figlist);
   
   
   
end;	%nax not zero