function mt_inisurf(sonanames,subplotspec)
% MT_INISURF Initialize surface display
% function mt_inisurf(sonanames,subplotspec)
% mt_inisurf: Version 25.08.2013
%
%	Syntax
%		sonanames: List of names for the surf axes.
%           Must either be identical to signal name or consist of
%           signalname plus '.' plus any string
%           This allows the same signal to be displayed in multiple axes
%           with different settings for each axes.
%           Special case: If the first character after '.' is 'i' then the
%           internal dimension specification is used to define surf x and y
%           coordinates. Otherwise the external dimension specification is
%           used (if available). Thus the same signal can be displayed with
%           both internal and external dimension specification
%		subplotspec: Optional. 2-element vector to specify arrangement of axes
%			Defaults to n_axes rows * 1 column
%
%	Remarks
%		Based on mt_video, but mainly designed to make use of
%		dimension.external specification (e.g defining the arrangement of
%		ultrasound scanlines). Doesn't allow as much flexibility as mt_video when handling multiple axes
%       with truecolor dsata. In fact truecolor data will currently be
%       converted to grayscale for display (it may be possible to relax
%       this constraint in future). In addition, for truecolor video
%       signals it is currently necessary to force the use of the internal
%       dimension specificiation (see above)
%		
%
%	Description
%		This lists the fields in the userdata of the surf figure, and then in the userdata of each axes
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
%           also gamma and colormap (currently takes precedence over any
%           axes settings)
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
%           scalemode
%           colorbarhandle
%
%   Updates
%       6.2013. preliminary version based on mt_inivideo
%
%   See Also MT_SSURFAD see this for details of how properties are set
%       (currently not very consistent)

xynames=sonanames;	%this function based on mt_inixy

figtag='mt_surf';
nax=size(xynames,1);

%alternative if called with no args. delete fig, but also in mt_org figure axis???

myversion=version;	%only needed for graphics details

if nax
    hh=mt_gfigh(figtag);
    if ~isempty(hh)
        %confirmation??
        disp('mt_inisurf: Resetting video display');
        delete(hh);
        
        
    end;
    hh=figure;
    myS.axis_names=xynames;
    myS.sub_cut_flag=0;					%enable/disable subcut display in ALL axes
    myS.display_flag=ones(nax,1);		%all axes enabled for display
    myS.lastframe=0;
    myS.trial_number=0;
%unlike mt_video handle gamma and colormap as figure properties (axes
%properties left, but will be ignored for the moment)
    myS.gamma=1;
    myS.colormap='myhsv2rgb';
    
    set(hh,'tag',[figtag mt_gsnum(1)],'userdata',myS,'papertype','a4letter','pointer','fullcrosshair','colormap',gray(256));%more settings?????
    set(hh,'numbertitle','off','menubar','none');
    set(hh,'name',[int2str(hh) ': ' get(mt_gfigh(figtag),'tag')]);
 set(hh,'renderer','zbuffer');
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
    
    %initialize the struct for the userdata of each axis
    %originally designed for use with image data (mt_video)
    %note: surf uses figure color map, so separate colormaps for each axis will
    %not be possible, unless we play around with truecolor as in mt_video
%   similarly, gamma is set as a figure property, rather than axis by axis
    %linespec and colspec will be applied to the respective dimension of the
    %full dimension.external specification
    %scalemode 'manual' means that x/y/zlim can be set by the user (e.g
    %using mt_ssurfad); scalemode 'auto' means that the axes limits are set
    %to the data range determined by linespec and colspec (the latter is a
    %relict of the procedure used in mt_video; for mt_surf manual mode
    %should be easier to use in most cases
    
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
        'colorbarhandle',[],...
        'zused',0,...
        'externalused',1,...
        'axis_number',1,...
        'samplerate',[],...
        'time_spec',[],...
        'trial_number',[]...
        );
    
    %may be a better default color map
    %set(gcf,'colormap',myhsv2rgb(256));
    
    
    
    
    myfonts=[16 14 14 12 12 12 10 10];
    naxx=sprow*spcol;
    if naxx>length(myfonts)
        myfs=8;
    else
        myfs=myfonts(naxx);
    end;
    
    
    signallist=mt_gcsid('signal_list');
    
    for ii=1:nax
        fullname=deblank(xynames(ii,:));
        myname=fullname;
        forceinternal=0;
        ipi=findstr('.',fullname);
        if ~isempty(ipi)
            ipi=ipi(1);
            myname=myname(1:(ipi-1));
            if strcmp(fullname(ipi+1),'i') forceinternal=1; end;
        end;
        
        
        
        ha=subplot(sprow,spcol,ii);
        habuf(ii)=ha;
        myS.axis_number=ii;
        
        
        
        title(fullname,'interpreter','none','fontsize',myfs);
        
        %more initializing if axis is also a signal
        vs=strmatch(myname,signallist,'exact');
        if length(vs)==1
            myS.signal_name=myname;
            myS.samplerate=mt_gsigv(myname,'samplerate');
            myS.signal_number=mt_gsigv(myname,'signal_number');
            
            sigunit=mt_gsigv(myname,'unit');
            
            
            %preliminary implementation:
            %assume data has a dimension.external specification
            %should eventually be able to revert to non-external spec if missing
            
            mydim=mt_gsigv(myname,'dimension');
            
            myS.externalused=0;
            if ~forceinternal
                if isfield(mydim,'external')
                    mydim=mydim.external;
                    myS.externalused=1;
                else
                    disp('No external dimension specification; using internal')
                end;
            end;
            
            %if only 3 then last dimension must be time
            %currently, truecolor input must be forced to used the
            %internal dimension specification because the program can't
            %distinguish where the third dimension is a true geometrical
            %specification and where it is simply a color plane
            if length(mydim.axis)>3 & myS.externalused myS.zused=1; end;
            
            %data must have 3 dimensions with time as third dimension
            %dimension.external can however refer to either 2 or 3 geometrical
            %dimensions
            datasize=mt_gsigv(myname,'data_size');
            myS.linespec=(1:datasize(1));
            myS.colspec=(1:datasize(2));
            
            
            
            %if internal dimension specification, use same procedure as for video display
            %also needs doing in mt_surf
            
            if myS.externalused
                %unlike the non-external spec, the external spec is simply applied in order to the x, y and possible
                % z graphical axes
                
                dimd=deblank(mydim.descriptor(1,:));
                dimu=deblank(mydim.unit(1,:));
                xlabel([dimd ' (' dimu ')'],'interpreter','none','fontsize',myfs);
                dimd=deblank(mydim.descriptor(2,:));
                dimu=deblank(mydim.unit(2,:));
                ylabel([dimd ' (' dimu ')'],'interpreter','none','fontsize',myfs);
                
                xdata=mydim.axis{1};
                ydata=mydim.axis{2};
            else
                
                %for internal, x is simply the column dimension and y the
                %row dimension
                dimd=deblank(mydim.descriptor(2,:));
                dimu=deblank(mydim.unit(2,:));
                xlabel([dimd ' (' dimu ')'],'interpreter','none','fontsize',myfs);
                dimd=deblank(mydim.descriptor(1,:));
                dimu=deblank(mydim.unit(1,:));
                ylabel([dimd ' (' dimu ')'],'interpreter','none','fontsize',myfs);
                
                
                %for internal, assume these are vectors
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
            set(gca,'xlim',[min(xdata(:)) max(xdata(:))],'ylim',[min(ydata(:)) max(ydata(:))]);
            %can only be with external specification
            if myS.zused
                dimd=deblank(mydim.descriptor(3,:));
                dimu=deblank(mydim.unit(3,:));
                zlabel([dimd ' (' dimu ')'],'interpreter','none','fontsize',myfs);
                
                
                zdata=mydim.axis{3};
                set(gca,'zlim',[min(zdata(:)) max(zdata(:))]);
            else
                zdata=zeros(size(xdata));
            end;
            
            if strcmp(mydim.unit(1,:),mydim.unit(2,:))
                axis('equal');
            end;
            
            
            
            
            hold on
            hc=surf(xdata,ydata,zdata,zeros(datasize(1),datasize(2)));
            
            %         hc=imagesc(zeros(datasize(1),datasize(2)),myS.clim);
            %   not sure what the best erasemode is for animations with surf data
            %note: use fullname rather than myname (signalname) as tag for both the
            %surf and the axes object. Might be more consistent to only use fullname
            %for the axes object, but this makes it quicker to access the surf object
            %unambiguously via the tag
            set(hc,'tag',fullname);
            %         set(hc,'tag',myname,'erasemode','none');
            
            %maybe some of these graphics properties could be duplicated in the axes
            %struct
            
            %default setting for displaying basic image data with interpolation
            set(hc,'edgecolor','none','facecolor','interp');
            
            %to demonstrate e.g ultrasound scanline data use these settings (then zoom in, or use
            %a setting with low line density)
            %set(hc,'facecolor','none')
            %set(hc,'edgecolor','interp')
            %set(hc,'meshstyle','col')
            %set(hc,'linewidth',2)
            
            %for 2-D data probably this should be the default view:
            if ~myS.zused view(0,90); end;
            
            hcb=colorbar;
            hcbtit=get(hcb,'title');
            set(hcbtit,'string',sigunit,'interpreter','none');
            myS.colorbarhandle=hcb;
            
            hold off
        else
            disp(['mt_inisurf; Not a signal? ' myname]);
                    disp('Correct the input argument to mt_inisurf and try again');
        keyboard;

        end;		%initialize signal
        
        set(ha,'tag',fullname,'userdata',myS);
        
        
    end;	%nax loop
    
    
    %??????loop to set up colorbars. This will shift the axes position???? cf. mt_inisona
    
    %what happens if figure is deleted????
    
    figlist=mt_gfigd('figure_list');
    vi=strmatch('mt_surf',figlist);
    if isempty(vi) figlist=str2mat(figlist,'mt_surf');end;
    
    mt_sfigd('figure_list',figlist);
    
    
    
end;	%nax not zero
