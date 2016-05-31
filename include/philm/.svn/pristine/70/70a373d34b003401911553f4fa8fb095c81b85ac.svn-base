function mt_inixy(xynames,subplotspec)
% MT_INIXY Initialize xy display
% function mt_inixy(xynames,subplotspec)
% mt_inixy: Version 17.3.2009
%
%	Syntax
%		xynames: List of names for the xy axes
%		subplotspec: Optional. 2-element vector to specifiy arrangement of xy axes
%			Defaults to n_axes rows * 1 column
%
%	Description
%		This lists the fields in the userdata of the xy figure, and then in the userdata of each axes
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
%		Axes
%
%			n_trajectories
%
%			trajectory_names
%				Names by which to refer to the trajectories, e.g for contour order or in mt_sxytp
%
%			{x|y|z|c}_mode
%				Type of data to use for each axis. Current possibilities are:
%				signal_data, time, constant, sensor_number
%
%			{x|y|z|c}_specs
%				Some axis modes require futher specifications:
%					signal_data: List of the signals to use
%					constant:    Scalar value (or expression that evaluates to a scalar value)
%
%			v_mode
%				Set to 'spherical' for 5D ema sensor orientations
%				Set to 'cartesian' for velocity vectors
%
%			v_spec
%				This is struct containing x,y,z,c_mode, x,y,z,c_spec to control how vectors are drawn
%				Other fields are: ????
%
%			hold_mode
%				If 'on' old trajectories will not be deleted
%
%			contour_order
%				A list (string matrix) of trajectory names to determine the order in which to draw contours
%				(names can occur more than once, allowing closed shapes to be drawn.
%				Empty list elements can be used to interrupt the contour e.g to seperate tongue and lips
%				If set to '<default>' (or completely empty) use the order in 'trajectory_names'
%
%			(The next 4 items are needed for extracting data from MT_XYDATA for contour drawing:)
%
%			axis_number
%
%			samplerate
%
%			time_spec
%				2-element vector (start and end of trajectory) 
%
%			trial_number
%
%			surface_mode
%				If set to 'both', 'rows' or 'columns' the data will be used to draw a surface object
%				with this mesh specification. See also????
% 
%			(Fields for sub_cut display:)
%
%			sub_cut_marker
%				If this is a 2-row string matrix of marker types, 
%				segmentation boundaries will be placed on the trajectories
%
%			sub_cut_linestyle
%				2-row string matrix of linestyles.
%				Enables contours to be shown at sub_cut boundaries. Defaults to 'none'
%
%			sub_cut_labelposition
%				Relative position of label
%				0=at start of segment, 1=at end of segment; set to NaN or some large number to suppress labels
%
%	Updates
%		3.09 Erasemode of cursors changed to normal (vector cursor made
%		thinner). Introduce xycursor_settings field
%
%	See Also
%		MT_SXYFD / MT_GXYFD to access parameters stored in xy figure userdata
%		MT_SXYAD / MT_GXYAD to access parameters stored in axes userdata
%		MT_SXYL to set axis limits
%		MT_SXYV	to set axes view
%		MT_GXYCD	get data to prepare for contour display
%		MT_XYDIS	The actual display routine
%		(Not yet implemented:)
%		MT_SXYAP / MT_GXYAP to set axes graphics parameters
%		MT_SXYTP / MT_GXYTP to set trajectories graphics parameters


global MT_XYDATA	%used for random access to data for contour display; see also contour_order parameter
global MT_XYVDATA	%used like contour data, but for velocity or sensor orientation vectors

figtag='mt_xy';
nax=size(xynames,1);

%alternative if called with no args. delete fig, but also in mt_org figure axis???

%rows are contour linetype, contour marker, vector linetype vector marker. Columns are free, fixed
xycursor_settings={'-','none';'o','o';'-','none';'o','none'};


if nax
   hh=mt_gfigh(figtag);
   if ~isempty(hh)
      %confirmation??
      disp('mt_inixy: Resetting xy display');
      delete(hh);
   end;
   hh=figure;
   myS.axis_names=xynames;
   myS.sub_cut_flag=0;					%enable/disable subcut display in ALL axes
   myS.display_flag=ones(nax,1);		%all axes enabled for display
   set(hh,'tag',[figtag mt_gsnum(1)],'userdata',myS,'papertype','a4letter','pointer','crosshair','colormap',jet);%more settings?????
   
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
   
   
   %struct for vector display
   %essentially a copy of the top level struct
   %c_mode currently not implemented (use for choice of fixed color??)
   %for cartesian, velocity data, x/y/z will normally be signal data of velocity components
   %	for spherical data, x,y and z will correspond to azimuth, elevation and radius
   %xform should be a cell array of strings to specify a transformation matrix for each signal component
   
   
   vspec=struct(...
      'x_mode','constant',...
      'y_mode','constant',...
      'z_mode','constant',...
      'c_mode','constant',...
      'x_specs','0',...
      'y_specs','0',...
      'z_specs','0',...
      'c_specs','0',...
      'xform','1');				%scalar multiplier. Must be string, so eval can be used
   
   %initialize the struct for the userdata of each axis
   myS=struct(...
      'n_trajectories',0,...
      'trajectory_names','',...
      'x_mode','constant',...
      'y_mode','constant',...
      'z_mode','constant',...
      'c_mode','constant',...
      'x_specs','0',...
      'y_specs','0',...
      'z_specs','0',...
      'c_specs','0',...
      'v_mode','',...
      'v_specs',vspec,...
      'hold_mode','off',...
      'contour_order','<default>',...
      'axis_number',1,...
      'samplerate',[],...
      'time_spec',[],...
      'trial_number',[],...
      'surface_mode','off',...
      'sub_cut_marker',str2mat('^','v'),...
      'sub_cut_linestyle',str2mat('none','none'),...
      'sub_cut_labelposition',[0.5]...
      );
   
   myfonts=[16 14 14 12 12 12 10 10];
   naxx=sprow*spcol;
   if naxx>length(myfonts)
      myfs=8;
   else
      myfs=myfonts(naxx);
   end;
   
   figS=mt_gfigd;
	figS.xycursor_settings=xycursor_settings;
   curbuf=zeros(nax,3);%cursor handles for each axis. Store with mt_sfigd at end
   curbufv=zeros(nax,3);%cursor handles for each axis. Store with mt_sfigd at end
   
   
   for ii=1:nax
      myname=deblank(xynames(ii,:));
      ha=subplot(sprow,spcol,ii);
      myS.axis_number=ii;
      set(ha,'tag',myname,'userdata',myS);
      title(myname,'interpreter','none','fontsize',10);
      xlabel('X','interpreter','none','fontsize',myfs);
      ylabel('Y','interpreter','none','fontsize',myfs);
      zlabel('Z','interpreter','none','fontsize',myfs);
      
      %generate lineobjects for contours
%settings for linestyle and marker are only prelimary
% they are set properly (to match current cursor status) by callint
% mt_tcurs twice at the end
	  
      tmpcol=figS.cursor_colours;
      curstat=figS.cursor_status;
      %create line objects for cursors. Left, right and movie
      curh=line([0 1 0.5;0 1 0.5],[0 0 0;1 1 1]);
      
      set (curh,'EraseMode','normal','visible','off','marker','o','markersize',12,'linewidth',2);
      set (curh(1),'tag','left_contour','color',tmpcol(curstat(1)+1));
      set (curh(2),'tag','right_contour','color',tmpcol(curstat(2)+1));
      set (curh(3),'tag','movie_contour','color',tmpcol(3));
      
      curbuf(ii,:)=curh';   
      
      %generate lineobjects for vectors (velocity, orientation)
      
      curh=line([0 1 0.5;0 1 0.5],[0 0 0;1 1 1]);
      
      %not really sure what colours make sense
      %maybe only for markers, not for line ????
      
      set (curh,'EraseMode','normal','visible','off','linewidth',1.5,'marker','o','markersize',6);
      set (curh(1),'tag','left_vector','color',tmpcol(3),'markerfacecolor',tmpcol(3));
      set (curh(2),'tag','right_vector','color',tmpcol(3),'markerfacecolor',tmpcol(3));
      set (curh(3),'tag','movie_vector','color',tmpcol(3),'markerfacecolor',tmpcol(3));
      
      curbufv(ii,:)=curh';   
   end;	%nax loop
   
   MT_XYDATA=cell(nax,4);		%intialize the global variable for contour data
   MT_XYVDATA=cell(nax,4);		%intialize the global variable for vector data
   
   %what happens if xy figure is deleted
   
   figlist=figS.figure_list;
   vi=strmatch('mt_xy',figlist);
   if isempty(vi) figlist=str2mat(figlist,'mt_xy');end;
   
   mt_sfigd('figure_list',figlist);
   
   
   mt_sfigd('xy_contour_handles',curbuf);
   mt_sfigd('xy_vector_handles',curbufv);
	mt_sfigd('xycursor_settings',xycursor_settings);
end;	%nax not zero
