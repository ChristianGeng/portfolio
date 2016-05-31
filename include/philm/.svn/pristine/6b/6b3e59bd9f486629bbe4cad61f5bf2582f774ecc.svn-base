function mt_xydis(timspec);
% MT_XYDIS Do x/y display
% function mt_xydis(timspec);
% mt_xydis: Version 18.03.2009
%
%	Syntax
%		timspec: Start and end (in s.) of data to be shown in current trial
%
%	Description
%		Generates an x/y display according to specifications stored in axes userdata of the xy figure.
%		In fact, the description x/y is misleading. The plot is underlyingly 3-d (or 4-d with colour) 
%		even if often only a 2-dimensional view is used.
%		Change the different views of the underlying 3-d object by mt_sxyv or
%		by calling MATLAB's view function "by hand".
%		There are a variety of ways of using the 3 axes (plus the 4th
%		colour axis) of the 3-d object. See mt_inixy for further discussion.
%		This function can also display
%		start, end and label of any sub-cuts located within the movement trajectory
%		See mt_inixy for guidance on manipulating visibility and style of these objects.
%		Display update for individual axes can be enabled and disabled using the 'display_flag' field 
%		in the xy figure's userdata
%
%	Updates
%		3.09 display of xy cursors corrected
%
%	See also
%		MT_INIXY initialize xy figure
%		MT_GXYAD MT_SXYAD get/set xy axes data
%		MT_GXYFD MT_SXYFD get/set xy figure data
%		MT_SXYV or VIEW (matlab function) to change viewing angle
%		MTXSUBCUTPREP

global MT_XYDATA
global MT_XYVDATA

%time axis of display is zero based???
%
%get handles of xy figure
hxyf=mt_gfigh('mt_xy');
if isempty(hxyf)
   disp ('XY display not initialized');
   return;
end;
figure(hxyf);                 %make sure display visible

%?? need a better way of handling figure userdata
figdat=get(hxyf,'userdata');
axislist=mt_gxyad;
dispflag=figdat.display_flag;
vv=find(dispflag==1);
if isempty(vv)
   disp('mt_xydis: All axes disabled');
   return;
else
   axislist=axislist(vv,:);
end;


nax=size(axislist,1);

badtime=0;
if length(timspec)~=2
   badtime=1;
   disp('mt_xydis: Bad time spec');
else
   if timspec(2)<=timspec(1)
      disp('mt_xydis: No time?');
      badtime=1;
   end;
end;

if badtime return; end;

%this is not the only thing that potentially should be checked
% but it is probably the main one

timspec(2)=min([timspec(2) mt_gccud('end')]);

timspecx=timspec;	%need a copy of timspec in loop
itrial=mt_gtrid('number');
icut=mt_gccud('number');
mylabel=mt_gccud('label');


%prepare sub_cuts
subflag=0;
if figdat.sub_cut_flag
   [cutdatax,cutlabel,nsubxy]=mtxsubcutprep(timspec,'mt_xydis');
   subflag=1;
end;






%main loop, thru axislist



for iax=1:nax
   axhasdata=1;
   axname=deblank(axislist(iax,:));
   orgdat=mt_gxyad(axname);
   if isempty(orgdat)
      axhasdata=0;
   else
      ntraj=orgdat.n_trajectories;
      ntrajt=size(orgdat.trajectory_names,1);
      ntraj=min([ntraj ntrajt]);
      if ntraj<=0 axhasdata=0; end;
      
   end;
   
   if axhasdata
      
      
      hxya=findobj(hxyf,'tag',axname,'type','axes');
      axes(hxya);
      hadt=get(hxya,'title');
      sf=orgdat.samplerate;
      axnum=orgdat.axis_number;
      
      
      orgdat.trial_number=itrial;
      
      %adjust timspec to be precisiely located on sample
      %x/y often chosen by cursor position
      %helps ensure cursor inside x/y window , e.g for following movie
      timspec=timspecx*sf;
      timspec(1)=ceil(timspec(1));
      timspec(2)=floor(timspec(2));
%      timspec(1)=floor(timspec(1));
%      timspec(2)=ceil(timspec(2));
      timspec=timspec./sf;
      orgdat.time_spec=timspec;
      mytitle=[axname ': Trial ' int2str(itrial) ', Cut ' int2str(icut) ' "' mylabel '". ' num2str(timspec(1)) ' - ' num2str(timspec(2)) ' s.'];
      
      
      
      ndat=zeros(4,1);
      xbuf=mtxxydis(ntraj,orgdat.x_mode,orgdat.x_specs,timspec,sf);ndat(1)=size(xbuf,1);
      ybuf=mtxxydis(ntraj,orgdat.y_mode,orgdat.y_specs,timspec,sf);ndat(2)=size(ybuf,1);
      zbuf=mtxxydis(ntraj,orgdat.z_mode,orgdat.z_specs,timspec,sf);ndat(3)=size(zbuf,1);
      cbuf=mtxxydis(ntraj,orgdat.c_mode,orgdat.c_specs,timspec,sf);ndat(4)=size(cbuf,1);
      
      dataok=1;
      
      if ~any(ndat)
         disp(['mt_xydis: No data in axes ' axname]);
         dataok=0;
      end;
      if max(ndat)~=min(ndat)
         disp(['mt_xydis: Inconsistent data lengths in axes ' axname]);
         disp(ndat);
         dataok=0;
      end;
      
      if dataok
         
         dotrajectories(hxya,ntraj,xbuf,ybuf,zbuf,cbuf,orgdat.trajectory_names,orgdat.hold_mode);
         
         set (hxya,'userdat',orgdat);
         set (hadt,'string',mytitle);
         
         
         %surface object of complete data set
         
         dosurface(hxya,xbuf,ybuf,zbuf,cbuf,orgdat.surface_mode);
         
         %handle velocity or orientation vectors
         
         if strcmp(orgdat.v_mode,'cartesian') | strcmp(orgdat.v_mode,'spherical')
            odat=orgdat.v_specs;            
            ndatv=zeros(4,1);
            xbufv=mtxxydis(ntraj,odat.x_mode,odat.x_specs,timspec,sf);ndatv(1)=size(xbufv,1);
            ybufv=mtxxydis(ntraj,odat.y_mode,odat.y_specs,timspec,sf);ndatv(2)=size(ybufv,1);
            zbufv=mtxxydis(ntraj,odat.z_mode,odat.z_specs,timspec,sf);ndatv(3)=size(zbufv,1);
            cbufv=mtxxydis(ntraj,odat.c_mode,odat.c_specs,timspec,sf);ndatv(4)=size(cbufv,1);
            
            
            %get into shape as contours
            xusev=ones(ndat(1),ntraj*3)*NaN;
            yusev=xusev; zusev=xusev; cusev=xusev;
            ipi=1;
            
            
            datavok=1;
            if any(ndatv~=ndat(1)) 
               disp(['mt_xydis: Inconsistent vector data lengths in axes ' axname])
               datavok=0;
            end;
            
            if datavok
               %check number of signals also matches ......?
               if strcmp(orgdat.v_mode,'spherical')
                  %convert to cartesian
                  %should get units intelligently?????
                  angfac=pi/180;
                  
                  [xbufv,ybufv,zbufv]=sph2cart(xbufv*angfac,ybufv*angfac,zbufv);
               end;
               
               %apply transform. Currently limited to scalar multiplier
               %main use: set vector length in cartesian mode
               %(not applied to colour)
               myspec=odat.xform;
               
               if ~ischar(myspec)
         disp('Specification in constant mode must be a string that evaluates to a scalar');
         disp('Set to 1');
         myspec='1';
      end;
      try
         myval=eval(myspec);
      catch
         disp('Unable to evaluate specification in constant mode');
         disp('Set to 1');
         myval=1;
      end;
      
      if length(myval)~=1
         disp('Specification in constant mode must be a string that evaluates to a scalar');
         disp('Set to 1');
         myval=1;
      end;
      
      xbufv=xbufv*myval;
      ybufv=ybufv*myval;
      zbufv=zbufv*myval;
      
               for ivv=1:ntraj
                  xusev(:,ipi)=xbuf(:,ivv)-xbufv(:,ivv);
                  xusev(:,ipi+1)=xbuf(:,ivv)+xbufv(:,ivv);
                  yusev(:,ipi)=ybuf(:,ivv)-ybufv(:,ivv);
                  yusev(:,ipi+1)=ybuf(:,ivv)+ybufv(:,ivv);
                  zusev(:,ipi)=zbuf(:,ivv)-zbufv(:,ivv);
                  zusev(:,ipi+1)=zbuf(:,ivv)+zbufv(:,ivv);
                  cusev(:,ipi)=cbuf(:,ivv)-cbufv(:,ivv);
                  cusev(:,ipi+1)=cbuf(:,ivv)+cbufv(:,ivv);
                  ipi=ipi+3;
               end;
               
               %cdata not strictly necessary
               
               MT_XYVDATA{axnum,1}=xusev;
               MT_XYVDATA{axnum,2}=yusev;
               MT_XYVDATA{axnum,3}=zusev;
               MT_XYVDATA{axnum,4}=cusev;
               %surface object (or multiple line object?) of all data????               
            end;	%datavok   
         end;
         
         %do contour reordering and store
         
         
         [ndat,ntraj]=size(xbuf);
         
         [xuse,yuse,zuse,cuse]=fixcontour(xbuf,ybuf,zbuf,cbuf,orgdat.contour_order,orgdat.trajectory_names);
         
         
         %this data mainly intended for use with contour drawing
         %cdata not strictly necessary
         
         MT_XYDATA{axnum,1}=xuse;
         MT_XYDATA{axnum,2}=yuse;
         MT_XYDATA{axnum,3}=zuse;
         MT_XYDATA{axnum,4}=cuse;
         

		 %3.09 updating of xy cursors moved to end (outside axis loop)
         
         %return; %temporary
         
         
         
         
         
         %inner cut display
         %subflag from figure userdata  is used as overall flag
         %individual axes can be turned on and off by manipulating the sub_cut_marker field in axes userdata
         %inner cut display will be attempted if it is a string matrix with 2 rows
         
         if subflag         
            
            tchar=orgdat.sub_cut_marker;
            if size(tchar,1)==2
               tline=orgdat.sub_cut_linestyle;
               if size(tline,1)~=2 tline=str2mat('none','none');end;
               
               subtag=str2mat('start','end');
               
               hlab=findobj(hxya,'tag','xy_segmentlabel');
               hx1=findobj(hxya,'tag','xy_segmentstart');
               hx2=findobj(hxya,'tag','xy_segmentend');
               delete ([hlab;hx1;hx2]);
               
               
               
               
               
               
               if nsubxy                  
                  
                  %convert time to index in data buffers
                  cutdata=cutdatax-timspec(1);
                  cutdata=cutdata*sf;
                  cutdata=round(cutdata)+1;
                  %more checks???
                  %extract the data
                  %one line object each for start and end position for each segment
                  %lines could be created at set up
                  %data transposed so joined up lines will show e.g tongue contours
                  % at each segment position
                  nxuse=size(xuse,1);
                  for ii=1:2
                     ib=cutdata(:,ii);
                     %check ib in range: seems to go wrong sometimes
                     vv=find((ib>0) & (ib<=nxuse));
                     if ~isempty(vv)
                        ib=ib(vv);
                        xx=(xuse(ib,:))';
                        yy=(yuse(ib,:))';
                        zz=(zuse(ib,:))';
                        hll=line(xx,yy,zz);
                        set (hll,'tag',['xy_segment' deblank(subtag(ii,:))],'visible','on');
                        try
                           set(hll,'marker',deblank(tchar(ii,:)));
                        catch
                           disp('mt_xydis: Bad sub_cut marker');
                           disp(lasterr);
                        end;
                        try
                           set(hll,'linestyle',deblank(tline(ii,:)));
                        catch
                           disp('mt_xydis: Bad sub_cut linestyle');
                           disp(lasterr);
                        end;
                        
                     end;
                     
                  end;
                  
                  %label position
                  %Note uses basic data buffer, while lines use reordered contour buffer
                  ib=round(cutdata(:,1)+((cutdata(:,2)-cutdata(:,1))*orgdat.sub_cut_labelposition));
                  
                  vv=find((ib>0) & (ib<=ndat));
                  if ~isempty(vv)
                     ib=ib(vv);
                     cutlx=cutlabel(vv,:);		
                     
                     for ii=1:ntraj
                        xx=xbuf(ib,ii);
                        yy=ybuf(ib,ii);
                        zz=zbuf(ib,ii);
                        hlt=text(xx,yy,zz,cutlx);
                        set (hlt,'tag','xy_segmentlabel','visible','on');
                     end;
                  end;
               end;	%nsubxy                  
               
               
               
            end;	%sub_cut_marker
            
            
            
         end;		%subflag   
         
      end;	%dataok
   end;	%axhasdata
   
end;		%axis loop

		 
%old procedure
%didn't update vectors and also was not necessarily based on current cursor
%position
% what was the point of updating the movie contours?
%		 hl=findobj(hxya,'tag','left_contour');
%         set (hl,'xdata',xuse(1,:),'ydata',yuse(1,:),'zdata',zuse(1,:));
%         hl=findobj(hxya,'tag','right_contour');
%         set (hl,'xdata',xuse(ndat,:),'ydata',yuse(ndat,:),'zdata',zuse(ndat,:));
%         ndat2=round(ndat./2);
%         hl=findobj(hxya,'tag','movie_contour');
%         set (hl,'xdata',xuse(ndat2,:),'ydata',yuse(ndat2,:),'zdata',zuse(ndat2,:));
         
         
         %update vector contours
%prepare xy contours
[xyindex,sfxy,timestampxy,xycontourh,xycontourhv]=mt_gxycd;
if ~isempty(xyindex);         
   
   oldconti=ones(size(xycontourh))*-1;               %for mt_shoco, force complete redrawing
         
         newconti=mt_shoco(xyindex,sfxy,timestampxy,xycontourh,xycontourhv,mt_gcurp,oldconti);               
	mt_tcurs; mt_tcurs;		%make sure line settings match current cursor status (probably only relevant for first call)
end;


drawnow;

function fc=getfacec;
fc=get(gca,'color');
if strcmp(lower(fc),'none') fc=get(gcf,'color');end;

function dotrajectories(hxya,ntraj,xbuf,ybuf,zbuf,cbuf,trajectory_names,hold_mode)
for ii=1:ntraj
   mytag=deblank(trajectory_names(ii,:));
   hs=findobj (hxya,'tag',mytag,'type','surface');
   if isempty(hs) 
      
      fc=getfacec;
      %interp for edgecolor seems ok, probably usually not necessary. Otherwise use flat. For trajectories column meshstyle is probably best. row is also ok 
      hs=surface([],[],[],[],'tag',mytag,'facecolor',fc,'edgecolor','interp','linewidth',2,'linestyle','-','meshstyle','col','visible','off');
      
   end;
   
   xx=xbuf(:,ii);
   yy=ybuf(:,ii);
   zz=zbuf(:,ii);
   cc=cbuf(:,ii);
   %the trajectory has to be plotted as a surface object, in order to be able to use the color axis
   %Copy the data like this to get a surface that looks like a line
   xx=[xx xx];
   yy=[yy yy];
   zz=[zz zz];
   cc=[cc cc];
   
   %handle hold mode by appending new data, may get slow
   if strcmp(hold_mode,'on')
      xold=get(hs,'xdata');
      yold=get(hs,'ydata');
      zold=get(hs,'zdata');
      cold=get(hs,'cdata');
      mynan=[NaN NaN];
      xx=[xold;mynan;xx];
      yy=[yold;mynan;yy];
      zz=[zold;mynan;zz];
      cc=[cold;mynan;cc];
   end;
   set (hs,'xdata',xx,'ydata',yy,'zdata',zz,'cdata',cc,'visible','on');
end;

function dosurface(hxya,xbuf,ybuf,zbuf,cbuf,surface_mode);


hs=findobj(hxya,'tag','surface','type','surface');
mymesh=str2mat('both','row','column');
iset=any(strmatch(surface_mode,mymesh));

if isempty(hs)
   if iset
      %create object
      fc=getfacec;
      %interp for edgecolor?and/or facecolor?
      hs=surface([],[],[],[],'tag','surface','facecolor',fc,'edgecolor','interp','linewidth',0.5,'linestyle','-','meshstyle','row','visible','off');
      
   end;
else
   %delete object
   if ~iset delete(hs); end;
end;
if iset
   set (hs,'xdata',xbuf,'ydata',ybuf,'zdata',zbuf,'cdata',cbuf,'meshstyle',surface_mode,'visible','on');
end;

function [xuse,yuse,zuse,cuse]=fixcontour(xbuf,ybuf,zbuf,cbuf,contour_order,trajectory_names);

[ndat,ntraj]=size(xbuf);
conlist=contour_order;        
inew=1;
if isempty(conlist)
   inew=0;
else
   if strcmp('<default>',deblank(conlist)) inew=0;end;
end;

if inew
   
   
   newcol=size(conlist,1);
   xuse=ones(ndat,newcol)*NaN;
   yuse=ones(ndat,newcol)*NaN;
   zuse=ones(ndat,newcol)*NaN;
   cuse=ones(ndat,newcol)*NaN;
   
   for outcol=1:newcol
      
      incol=strmatch(deblank(conlist(outcol,:)),trajectory_names);
      if length(incol)==1
         xuse(:,outcol)=xbuf(:,incol);
         yuse(:,outcol)=ybuf(:,incol);
         zuse(:,outcol)=zbuf(:,incol);
         cuse(:,outcol)=cbuf(:,incol);
      end;
   end;
   
else
   xuse=xbuf;
   yuse=ybuf;
   zuse=zbuf;
   cuse=cbuf;
end;

