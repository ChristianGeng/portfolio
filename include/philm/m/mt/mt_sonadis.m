function mt_sonadis(timspec);
% MT_SONADIS Do sona display
% function mt_sonadis(timspec);
% mt_sonadis: Version 30.03.2013
%
%	Syntax
%		timspec: Start and end (in s.) of data to be shown in current trial
%
%	Description
%		Sonagram-style display. Actually can be used for any vector data
%		This function can also display
%		start, end and label of any sub-cuts located within the movement trajectory
%		See mt_inixy for guidance on manipulating visibility and style of these objects.
%		Display update for individual axes can be enabled and disabled using the 'display_flag' field
%		in the xy figure's userdata
%
%	See also
%		MT_INISONA initialize sona figure
%		MT_GXYAD MT_SXYAD get/set xy axes data
%		MT_GXYFD MT_SXYFD get/set xy figure data
%		MT_SXYV or VIEW (matlab function) to change viewing angle
%
%   Updates
%       Make imresize compatible with version 7 (means default antialiasing
%       behaviour is now used)
%       07.2012 Start implementing slice display through multidimensional
%       data
%       03.2013 Start handling interpolation without image processing
%       toolbox

oldfigh=gcf;
%get handles of sona figure
hxyf=mt_gfigh('mt_sona');
if isempty(hxyf)
    disp ('Sona display not initialized');
    return;
end;

%?? need a better way of handling figure userdata
figdat=get(hxyf,'userdata');
axislist=figdat.axis_names;
dispflag=figdat.display_flag;
vv=find(dispflag==1);
if isempty(vv)
    disp('mt_sonadis: All axes disabled');
    return;
else
    axislist=axislist(vv,:);
end;


nax=size(axislist,1);

badtime=0;
if length(timspec)~=2
    badtime=1;
    disp('mt_sonadis: Bad time spec');
else
    if timspec(2)<=timspec(1)
        disp('mt_sonadis: No time?');
        badtime=1;
    end;
end;

if badtime return; end;

timspecx=timspec;	%need a copy of timspec in loop
itrial=mt_gtrid('number');
icut=mt_gccud('number');
mylabel=mt_gccud('label');


%prepare sub_cuts
subflag=0;
if figdat.sub_cut_flag
    [cutdata,cutlabel,nsubxy]=mtxsubcutprep(timspec,'mt_sonadis');
    subflag=1;
end;

figure(hxyf);                 %make sure display visible

%main loop, thru axislist

for iax=1:nax
    axhasdata=1;
    axname=deblank(axislist(iax,:));
    orgdat=mt_gsonaad(axname);
    if isempty(orgdat)
        axhasdata=0;
    else
        mysignal=orgdat.signal;
        %check signal available
        
    end;
    
    if axhasdata
        
        
        hxya=findobj(hxyf,'tag',axname,'type','axes');
        axes(hxya);
        
        hcur=findobj(hxyf,'tag',[axname '_cursor_axis'],'type','axes');
        
        %this must be done here, regardless of current
        %subcut settings. cf. mt_next, BUT mt_xydis!!
        
        hlab=findobj(hcur,'tag','sub_cut_label');
        hx(1)=findobj(hcur,'tag','sub_cut_start');
        hx(2)=findobj(hcur,'tag','sub_cut_end');
        delete (hlab);
        set(hx,'visible','off');
        
        
        
        hadt=get(hxya,'title');
        sf=orgdat.samplerate;
        axnum=orgdat.axis_number;
        
        
        orgdat.trial_number=itrial;
        
        %adjust timspec
        %x/y often chosen by cursor position
        %helps ensure cursor inside x/y window , e.g for following movie
        timspec=timspecx*sf;
        timspec(1)=floor(timspec(1));
        timspec(2)=ceil(timspec(2));
        timspec=timspec./sf;
        
        %may sometimes be useful if mt_gdata does not convert data to
        %double
        [sonadat,actualtime]=mt_gdata(mysignal,timspec);
        
        %what if actualtime differs from timespec
        timspec=actualtime;
        orgdat.time_spec=timspec;
        %      mytitle=str2mat(axname,['Trial ' int2str(itrial) ' "' mylabel '". ' num2str(timspec(1)) ' - ' num2str(timspec(2)) ' s.']);
        mytitle=[axname ': Trial ' int2str(itrial) ', Cut ' int2str(icut) ' "' mylabel '"'];
        
        
        mydim=mt_gsigv(mysignal,'dimension');
        datasize=mt_gsigv(mysignal,'data_size');
        ndim=length(datasize);
        
        ndat=size(sonadat,ndim);
        slicedim=1; %default case for normal sonagram data
        dataok=1;
        %        disp('in mt_sonadis');
        %        keyboard;
        
        if ndim>2
            if ndim>4
                disp('mt_sonadis: unable to handle data with more than 4 dimensions');
                dataok=0;
            end;
            slicedim=orgdat.slice_data_dimension;
            posdim=orgdat.slice_position_dimension;
            posindex=orgdat.slice_position_index;
            if isempty(slicedim) dataok=0;end;
            if isempty(posdim) dataok=0;end;
            if isempty(posindex) dataok=0;end;
            if ~dataok
                disp(['mt_sonadis: Slices not set up for multidimensional data ' mysignal]);
            end;
        end;
        
        
        
        
        if ndat<2
            disp(['mt_sonadis: Not enough data in axes ' axname]);
            dataok=0;
        end;
        
        if dataok
            
            sonat=((0:ndat-1).*(1/sf))+timspec(1);
            sonaf=mydim.axis{slicedim};
            %should be possible to zoom into a selected range of the slice .....
            
            %prepare multidimensional data
            %special case could be to prepare for display as true color
            %assuming the colorplanes form the third dim of a 4D array
            %then first retain this dimension (by not including it in the
            %posdim list) and using indices 1:3 below.
            %then after selecting the slice below rearrange the resulting
            %3D array: sonadat=permute(sonadata,[1 3 2])
            %instead of displaying as truecolor (see video display for
            %handling brightness and contrast) this could be reduced using
            %e.g rgb2gray (which may be more consistent with the sonagram
            %display idea, i.e color or grayscale represents some clear
            %physical dimension, like spectral amplitude, brightness etc.
            %           Fields    'slice_truecolor_dimension',
            %           and    'slice_truecolor_op' with default 'rgb2gray'
            %           are already in the struct, but not yet used
            
            if ndim>2
                dimp=cell(ndim-1);
                %position index defaults to 1 if not otherwise specified
                for ipi=1:(ndim-1) dimp{ipi}=1; end;
                dimp{slicedim}=1:datasize(slicedim);
                nposd=length(posdim);
                titlestr=orgdat.slice_title_template;
                for ipi=1:nposd
                    dimi=posdim(ipi);
                    if ipi<=length(posindex)
                        if posindex(ipi)>0 & posindex(ipi)<=datasize(dimi)
                            dimp{dimi}=posindex(ipi);
                        end;
                    end;
                    tmpaxpos=mydim.axis{dimi};
                    %allow for axis values being strings. e.g red, green,
                    %blue
                    if ischar(tmpaxpos)
                        tmpaxpos=tmpaxpos(dimp{dimi},:);
                        
                    else
                        
                        tmpaxpos=tmpaxpos(dimp{dimi});
                        %disp(tmpaxpos);
                        tmpaxpos=num2str(tmpaxpos);
                    end;
                    
                    titlestr=strrep(titlestr,['%pos' int2str(ipi) '%'],tmpaxpos);
                end;
                mytitle=[mytitle '. ' titlestr];
                if ndim==4
                    sonadat=squeeze(sonadat(dimp{1},dimp{2},dimp{3},:));
                end;
                if ndim==3
                    sonadat=squeeze(sonadat(dimp{1},dimp{2},:));
                end;
            end;
            
            
            %check correct lengths... etc.
            
            dosona(hxya,sonadat,sonat,sonaf,orgdat.image_type,orgdat.shape_vector,orgdat.clim);
            
            set (hxya,'userdat',orgdat);
            set (hadt,'string',mytitle);
            
            %match time axes
            set(hcur,'xlim',get(hxya,'xlim'));
            
            %do overlay signals
            %notes: independent scaling implemented
            %by simply scaling range of each signal individually to
            %match frequency axis
            % Alternative would be another set of axes.
            % dependent overlay signals not yet implemented
            olist=orgdat.main_overlay_signals;
            nolist=size(olist,1);
            
            if nolist
                indepscale=0;
                if strcmp('independent',lower(orgdat.overlay_scaling)) indepscale=1; end;
                for iol=1:nolist
                    sigtmp=deblank(olist(iol,:));
                    mytag=['main_overlay_signal_' sigtmp];
                    hol=findobj(hxya,'type','line','tag',mytag);
                    if isempty(hol)
                        holft=findobj(mt_gfigh('mt_f(t)'),'type','line','tag',sigtmp);
                        if isempty(holft)
                            disp(['Bad overlay signal in mt_sonadis ? ' sigtmp]);
                        else
                            
                            hol=line([0 1],[0 1],'tag',mytag,'color',get(holft,'color'));
                        end;
                    end;
                    [oldat,actualtime]=mt_gdata(sigtmp,timspec);
                    sfol=mt_gsigv(sigtmp,'samplerate');
                    olx=((0:(length(oldat)-1))'/sfol)+actualtime(1);
                    %                    keyboard;
                    %map range of data to frequency range of sonagram
                    if indepscale oldat=interp1([min(oldat) max(oldat)],[sonaf(1) sonaf(end)],oldat); end;
                    
                    
                    
                    set(hol,'xdata',olx,'ydata',oldat);
                end;
            end;
            
            
            
            %inner cut display
            %subflag from figure userdata  is used as overall flag
            %individual axes can be turned on and off by manipulating the sub_cut_marker field in axes userdata
            %inner cut display will be attempted if it is a string matrix with 2 rows
            
            if subflag
                if nsubxy
                    mtxsubcutdis(hcur,orgdat,cutdata,cutlabel,'mt_sonadis');
                end;
            end;		%subflag
            
        end;	%dataok
    end;	%axhasdata
    
end;		%axis loop



drawnow;

figure(oldfigh);
drawnow;
function dosona(hxya,sonadat,sonat,sonaf,image_type,shape_vector,myclim);

useimageproc=0;     %for testing interp2 vs. imresize


axes(hxya);
mytag='sona_display';
hs=findobj (hxya,'tag',mytag);


tlim=[sonat(1) sonat(end)];
flim=[sonaf(1) sonaf(end)];



%if image_type has changed, delete  the old object
if ~isempty(hs)
    oldimage=get(hs,'type');
    if ~strcmp(oldimage,image_type)
        disp('mt_sonadis: Changing image type');
        delete(hs);
        hs=[];
    end;
end;



if isempty(hs)
    if strcmp(image_type,'surface')
        %interp for edgecolor seems ok, probably usually not necessary. Otherwise use flat. For trajectories column meshstyle is probably best. row is also ok
        hs=surface(1:10,1:10,zeros(10,10),'tag',mytag,'facecolor','interp','edgecolor','none','visible','off');
        set(gca,'view',[0 90]);
    end;
    if strcmp(image_type,'image')
        hold on
        hs=imagesc(1:10,1:10,zeros(10,10),'tag',mytag,'visible','off');
        hold off
    end;
    
end;

[ms,ns]=size(shape_vector);
if all([ms ns])
    if ns>ms shape_vector=shape_vector';end;
    sv=shape_vector*ones(1,length(sonat));
    sonadat=sonadat+sv;
end;


if strcmp(image_type,'surface')
    set (hs,'xdata',sonat,'ydata',sonaf,'zdata',sonadat,'cdata',sonadat,'visible','on');
end;
if strcmp(image_type,'image')
    %interpolate to match size in pixels
    oldunit=get(gca,'units');
    set(gca,'units','pixel');
    axpos=get(gca,'position');
    set(gca,'units',oldunit);
    
    %this uses image processing toolbox
    %much faster than 2 calls to interp1
    %Note: final argument means no anti-alias filtering if subsampling
    %   version 6 version of imresize does not like sparse input (e.g from EPG)
    if issparse(sonadat) sonadat=full(sonadat); end;
    %    sonadat=imresize(sonadat,[axpos(4) axpos(3)],'bilinear',0);
    %note: version 7 does not use the final argument in exactly the same way:
    %This was designed to suppress antialias filtering when the new image size
    %is smaller than the original
    %for version 7 this would be done with 'antialiasing','false')
    % 1.08 simply omit and try using default antialiasing behaviour
    %(probably not relevant very often)
    %Another consideration is that imresize had some somewhat strange effects
    %compared to separate use of interp1 when used to handle de-interlaced
    %video data: Maybe consider going back to interp1 in due course, if clearly
    %fast enough
    %
    %3.2012. Start handling cases where no image processing toolbox license is
    %available. Could eventually have a configurable option to explicitly suppress its use
    %
if useimageproc
%    try
        sonadat=imresize(sonadat,[axpos(4) axpos(3)],'bilinear');
else
        %    catch
%        disp('Image processing toolbox not available?');
        disp('mt_sonadis: Using interp2');
%surface mode display looks messy
        %        disp('As alternative, use mt_ssonaad to set image_type to surface');
%        disp('Use the following command to sort out licensing problems');
%        disp('[TF errmsg] = license(''checkout'', ''image_toolbox'')');
        
        nsonat=length(sonat);
        nsonaf=length(sonaf);
        
        ti=linspace(1,nsonat,axpos(3));
        fi=linspace(1,nsonaf,axpos(4));
        
        sonadat=interp2(sonadat,ti,fi','*linear');
    end;
    %   tref=axpos(3);fref=axpos(4);
    %   ti=sonat;
    %   tdiff=(ti(end)-ti(1))/tref;
    %   ti=(ti(1):tdiff:ti(end));
    %   sonadat=(interp1(sonat,sonadat',ti,'*linear'))';
    %
    %   fi=sonaf;
    %   fdiff=(fi(end)-fi(1))/fref;
    %   fi=(fi(1):fdiff:fi(end));
    %   sonadat=interp1(sonaf,sonadat,fi,'*linear');
    
    
    
    
    set (hs,'xdata',tlim,'ydata',flim,'cdata',sonadat,'visible','on');
end;



if length(myclim)==2 set(gca,'clim',myclim);end;

usedclim=get(gca,'clim');
hcbax=findobj(get(gca,'parent'),'tag',[get(gca,'tag') '_colorbar'],'type','axes');
hcbim=findobj(hcbax,'type','image');
set(hcbax,'ylim',usedclim);
set(hcbim,'ydata',usedclim);


%colorbar;	%update colorbar
%why is mode manual anyway?
set(gca,'xlim',tlim);
%image does rather strange automatic scaling
%disabled , 8.2013. should be no reason why user should not control ylim
%directly, especially for surface
%set(gca,'ylim',flim);
