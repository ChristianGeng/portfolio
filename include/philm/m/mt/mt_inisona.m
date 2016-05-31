function mt_inisona(sonanames,subplotspec,slicedimensionv)
% MT_INISONA Initialize sonagram display
% function mt_inisona(sonanames,subplotspec,slicedimensionv)
% mt_inisona: Version 30.07.2012
%
%	Syntax
%		sonanames: List of names for the sonagram axes
%		subplotspec: Optional. 2-element vector to specifiy arrangement of xy axes
%			Defaults to n_axes rows * 1 column
%       slicedimensionv: Required for multidimensional data, e.g.
%           video/ultrasound. Dimension across which to take the data slices
%           If multiple sona displays are to be initialized then
%           slicedimensionv must be a vector corresponding to the number of
%           entries in sonanames. Use zeros for those entries in sonanames
%           that are not multidimensional data.
%
%	Remarks
%		General idea based on mt_inixy
%		Details not worked out yet
%
%	Description
%		This lists the fields in the userdata of the sona figure, and then in the userdata of each axes
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
%			axis_number
%
%			samplerate
%
%			time_spec
%				2-element vector (start and end of trajectory) 
%
%			trial_number
%
%           image_type
%               image or surface
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
%   Updates
%       07.2012. Start implementing display of slices through
%       multidimensional data
%
%	See Also
%		MT_INIXY
%		MT_SXYFD / MT_GXYFD to access parameters stored in xy figure userdata
%		MT_SXYAD / MT_GXYAD to access parameters stored in axes userdata
%		MT_SXYL to set axis limits
%		MT_SXYV	to set axes view
%		MT_GXYCD	get data to prepare for contour display
%		MT_XYDIS	The actual display routine
%		(Not yet implemented:)
%		MT_SXYAP / MT_GXYAP to set axes graphics parameters
%		MT_SXYTP / MT_GXYTP to set trajectories graphics parameters

xynames=sonanames;	%this function based on mt_inixy

figtag='mt_sona';
nax=size(xynames,1);

%alternative if called with no args. delete fig, but also in mt_org figure axis???

myversion=version;	%only needed for graphics details

if ~nax return; end;

hh=mt_gfigh(figtag);
if ~isempty(hh)
    %confirmation??
    disp('mt_inisona: Resetting sona display');
    delete(hh);
    %need to delete cursor handles in figure data..????? (same problem with xy???)
    
    
end;
hh=figure;
myS.axis_names=xynames;
myS.sub_cut_flag=0;					%enable/disable subcut display in ALL axes
myS.display_flag=ones(nax,1);		%all axes enabled for display
set(hh,'tag',[figtag mt_gsnum(1)],'userdata',myS,'papertype','a4letter','pointer','crosshair','colormap',myhsv2rgb);%more settings?????
set(hh,'numbertitle','off','menubar','none');
set(hh,'name',[int2str(hh) ': ' get(mt_gfigh(figtag),'tag')]);
set(hh,'renderer','zbuffer');   %seems to avoid bug in colorbar in combination with surf

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

%handling truecolor video is planned, but not yet implemented
%in fact, rather actually doing a truecolor display, it may be more
%consistent to apply a function like rgb2gray

myfonts=[16 14 14 12 12 12 10 10];
naxx=sprow*spcol;
if naxx>length(myfonts)
    myfs=8;
else
    myfs=myfonts(naxx);
end;

figS=mt_gfigd;
curbuf=figS.time_cursor_handles;	%add cursor handles for sona axes to existing ones

signallist=mt_gcsid('signal_list');

for ii=1:nax
    myname=deblank(xynames(ii,:));
    ha=subplot(sprow,spcol,ii);

    
%initialize the struct for the userdata of each axis
myS=struct(...
    'signal','',...
    'main_overlay_signals','',...
    'dependent_overlay_signals','',...
    'overlay_scaling','dependent',...
    'image_type','image',...
    'clim',[],...
    'shape_vector',[],...   
    'axis_number',1,...
    'samplerate',[],...
    'time_spec',[],...
    'trial_number',[],...
    'sub_cut_marker',str2mat('^','v'),...
    'sub_cut_linestyle',str2mat('-.',':'),...
    'sub_cut_labelposition',[0.5],...
    'slice_data_dimension',[],...
    'slice_position_dimension',[],...
    'slice_position_index',[],...
    'slice_title_template','',...
    'slice_truecolor_dimension','',...
    'slice_truecolor_op','rgb2gray'...
    );

    
    
    
    habuf(ii)=ha;
    myS.axis_number=ii;
    
    
    
    %      title(myname,'interpreter','none','fontsize',myfs);
    htit=title(myname,'interpreter','none','fontsize',10);
    xlabel('Time (s)','interpreter','none','fontsize',myfs);
    
    %more initializing if axis is also a signal
    vs=strmatch(myname,signallist,'exact');
    if length(vs)==1
        myS.signal=myname;
        myS.samplerate=mt_gsigv(myname,'samplerate');
        sigunit=mt_gsigv(myname,'unit');
        mydim=mt_gsigv(myname,'dimension');
        tmpdim=1;
        
        %get datasize
        %           if more than 2 dimensions then 3rd input arg must be present         
        %ndim=??
        datasize=mt_gsigv(myname,'data_size');
        ndim=length(datasize);
        if ndim>2
            if nargin<3
                disp(['mt_inisona: Signal ' myname]);
                disp('mt_inisona: slice dimension must be specified for data with more than two dimensions');
                
                return;
            else;
                
                %check slicedimension in range
                slicedimension=slicedimensionv(ii);
                if ismember(slicedimension,1:(ndim-1))
                    myS.slice_data_dimension=slicedimension;
                    tmpdim=slicedimension;
                    posdims=setxor(1:(ndim-1),slicedimension);
                    myS.slice_position_dimension=posdims;
                    slicepos4tit='Slice at ';
                    for iki=1:length(posdims)
                        slicepos4tit=[slicepos4tit deblank(mydim.descriptor(posdims(iki),:))];
                        slicepos4tit=[slicepos4tit ' (' deblank(mydim.unit(posdims(iki),:)) ') %pos' int2str(iki) '%; '];
                    end;
                    myS.slice_title_template=[myname '. ' slicepos4tit];
                    
                    
                else
                    disp(['mt_inisona: Signal ' myname]);
                    disp(['mt_inisona: slice dimension out of range ' int2str(slicedimension)]);
                    return;
                    
                    
                end;
                
                
            end;       %nargin<3
        end;        %ndim>2
        
        
        dimd=deblank(mydim.descriptor(tmpdim,:));
        dimu=deblank(mydim.unit(tmpdim,:));
        ylabel([dimd ' (' dimu ')'],'interpreter','none','fontsize',myfs);
    else
        disp(['mt_inisona; Not a signal? ' myname]);
        myS=[];
    end;		%initialize signal
    
    set(ha,'tag',myname,'userdata',myS,'xticklabel','');
    
    
end;	%nax loop


%loop to set up colorbars. This will shift the axes position
for ii=1:nax
    myname=deblank(xynames(ii,:));
    axes(habuf(ii));
    oldpos=get(gca,'position');
    sigunit=mt_gsigv(myname,'unit');	%assumes axes is a signal????
    hcb=colorbar;
    axes(hcb);
    
    %make colorbar smaller than default
    cbpos=get(gca,'position');
    cbpos(4)=cbpos(4)/2;
    cbpos(1)=cbpos(1)+0.75*cbpos(3);
    cbpos(3)=cbpos(3)*0.25;
    if spcol==1 cbpos(1)=0.95; end;
    set(hcb,'position',cbpos,'tag',[myname '_colorbar']);
    title(sigunit,'interpreter','none');
    
    %restore data axes position
    set(habuf(ii),'position',oldpos);
    
    %	keyboard;
end;


%if combined with mt_imark, mt_imark should be called afterwards

maxt=max(mt_gcufd('type'));
maxt=max([maxt 1]);

for ii=1:nax
    myname=deblank(xynames(ii,:));
    mypos=get(habuf(ii),'position');
    ha=axes('position',mypos);
    
    
    
    
    set(ha,'tag',[myname '_cursor_axis'],'ylim',[0 maxt],'tickdir','out','ycolor','r');
    
    if myversion(1)>'5' set(ha,'yaxislocation','right');end;
    
    
    ylabel('cut_type','interpreter','none','fontsize',10,'verticalalignment','bottom');%actually horizontal adjustment, to keep away from colorbar
    
    
    tmpcol=figS.cursor_colours;
    curstat=figS.cursor_status;
    %maybe this ought to be a separate axes, as in main time figure
    %create line objects for cursors. Left, right and movie
    curh=line([0 1 0.5;0 1 0.5],[0 0 0;maxt maxt maxt]);
    
    set (curh,'EraseMode','xor','visible','off');
    set (curh(1),'tag','left_cursor','color',tmpcol(curstat(1)+1),'marker','o','markersize',12);
    set (curh(2),'tag','right_cursor','color',tmpcol(curstat(2)+1),'marker','o','markersize',12);
    set (curh(3),'tag','movie_cursor','color',tmpcol(3),'marker','o','markersize',12);
    
    curbuf=[curbuf;curh'];   
    
    
    %create two line objects to show subcut positions   
    %text objects will be created as needed
    
    hl=line([0;0],[0;1]);
    set(hl,'tag','sub_cut_start','visible','off','color','w','markersize',10);
    hl=line([0;0],[0;1]);
    set(hl,'tag','sub_cut_end','visible','off','color','w','markersize',10);
    
end;	%nax loop









%what happens if sona figure is deleted????

figlist=figS.figure_list;
vi=strmatch('mt_sona',figlist);
if isempty(vi) figlist=str2mat(figlist,'mt_sona');end;

mt_sfigd('figure_list',figlist);


mt_sfigd('time_cursor_handles',curbuf);
