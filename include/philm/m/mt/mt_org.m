function ncut=mt_org(cutname,mypath,reftrial);
% MT_ORG Set up general organizational structures for mt
% function ncut=mt_org(cutname,mypath,reftrial);
% mt_org: Version 22.08.2013
%
%	Syntax
%
%		Input args:
%			cutname: MAT file of cut data
%        mypath: common part of file name
%        reftrial: Number of reference trial, as string.
%
%		Output args:
%			ncut: Number of cuts in cut file
%
%	Updates
%		xycursor_settings added to figure structure (mt_sfig etc.)
%
%	See Also
%		VIEWMTGRAPH Shows the graphic structures used
%		MT_SSIG Must be called before any signals can actually be displayed or accessed
%		MT_GCUFD MT_GTRID MT_STRID MT_GCSID MT_GSIGV MT_SCSID
%

%	This is no longer up to date......
%	Graphics
%	figure 'mt_organization'
%		children
%			axis 'signal_axis'
%				children
%					text "signal name" (1 text object for each signal)
%						%string "some of the info from the data struct"
%						%userdata: signal data struct .....
%				userdata: various??? e.g no. of digits in trialnumber....
%				xlim: [0 max(data length)] ??how will text strings be arranged
%				ylim: [0 nchan]
%			axis 'cut_file_axis'
%				children
%					text 'cutlabels'
%						userdata: cutlabel
%					text 'trial_labels'
%						userdata: trial labels
%					patch
%						xdata: trial number of each cut
%						ydata: cut length data
%                 cdata: cut type data
%				userdata: cutdata
%				title
%					string: cut file name
%				xlim: "determined by range of trial numbers"
%			axis 'trial_axis'
%				title
%					string: trial label
%				userdata: number of current trial
%				children
%					line 'trialdata_"signalname"', n=1:n_signals
%						xdata: t0 to end of data
%					line 'trial_cut_data'
%						userdata: trial-cut data 
%						xdata: start of trial-cuts in current cut
%						ydata: cuttype of trial-cuts
%					line 'trial_cut_end'
%						xdata: end of trial-cuts in current cut
%						ydata: cuttype trial-cuts
%					text 'trial_cut_labels'
%						userdata: cutlabels for trial
%					line 'trial_current_cut' position of current cut in trial
%				userdata: cut data??
%				xlim: 0 to length of trial
%				ylim: [0 nchan]
%			axis 'current_cut_axis'
%				children
%					line 'sub_cut_data'
%						userdata: sub-cut data (current cut start is subtracted from segment boundaries)
%						xdata: start of sub-cuts in current cut
%						ydata: cuttype sub-cuts
%					line 'sub_cut_end'
%						xdata: end of sub-cuts in current cut
%						ydata: cuttype sub-cuts
%					text 'sub_cut_labels'
%						userdata: sub-cut labels
%                                       
%					line 'cursor_axis_position'
%                                               xdata: from mm_gdtim
%				userdata: cutnumber, cutstart ,cutend, cuttype
%				title
%					string: "label of current cut"
%				xlim: "upper limit = cut length"
%				ylim: "range of cut lengths"
%				sub-cut data in cursor axis?????
%	figure 'timewave_figure'
%		children
%			axis 'timewave_axis_"signalname"', (one axis for each timewave)
%				children
%					line 'osci_"signalname"'
%						xdata: time
%						ydata: signal data for timewave (either complete or reduced to maxmin)
%						userdata: "string indicating whether oscillogram is maxmin"
%				ylabel
%					string: "channel descriptor and units"
%           userdata: original axis position if axis currently magnified, otherwise empty
%           title
%           string: "signalname" (currently invisible)
%			axis 'cursor_axis'
%				children
%					line 'left_cursor'
%					line 'right_cursor'
%           title
%              string: "cut transcription etc."
%           xlabel
%              string: "time (s)"

global MT_SESSION_NUMBER


myversion=version;

%use v4 defaults for graphics
%this is not without problems (axis labels don't print)
%but ensures white lines are visible, and xor mode works
%as expected

%should be restored at program termination

if ~strcmp(myversion(1),'4') colordef('none');end;

%[abint,abnoint,abscalar,abnoscalar]=abartdef;

%???where to put sampincmax

ncut=0;


%open MAT cut file
%must contain variables data and label
cutdata=mymatin(cutname,'data');
cutlabel=mymatin(cutname,'label');
if isempty(cutdata) | isempty(cutlabel)
    disp ('Bad cut file specification');
    return;
end;

ncut=size(cutdata,1);
nlabel=size(cutlabel,1);
if nlabel~=ncut
    disp ('Wrong number of labels?');
    disp ([nlabel ncut]');
end
%ensure cutdata has trial number (and cuttype) field
if size(cutdata,2) < 4
    disp ('Cut file must have trialnumber (and cut type) parameters');
    return;   
end;


warning off;
cutdescriptor=mymatin(cutname,'descriptor');
warning on;
if isempty(cutdescriptor)
    [cutdescriptor,dodounit,dodovaluelabel]=cutstrucn;
end;
C=desc2struct(cutdescriptor);



cut_typecol=C.cut_type;
trialcol=C.trial_number;

triallabel=[];

maxtrial=max(cutdata(:,trialcol));


[trialnumlab,trialnumval]=getvaluelabel(cutname,'trial_number');
if ~isempty(trialnumval)
    maxtrial=max([max(cutdata(:,trialcol)) max(trialnumval)]);
    labsize=size(trialnumlab,2);
    triallabel=repmat(blanks(labsize),[maxtrial 1]);
    triallabel(trialnumval,:)=trialnumlab;
end;


if isempty(triallabel)
    
    trialtype=0;
    [cuttypelab,cuttypeval]=getvaluelabel(cutname,'cut_type');
    if ~isempty(cuttypelab)
        vv=strmatch('trial',cuttypelab);
        if ~isempty(vv)
            trialtype=cuttypeval(vv(1));
        end;
    end;
    
    vv=find(cutdata(:,cut_typecol)==trialtype);
    if ~isempty(vv)
        trialnumval=cutdata(vv,trialcol);
        trialnumlab=cutlabel(vv,:);
        
        labsize=size(trialnumlab,2);
        triallabel=repmat(blanks(labsize),[maxtrial 1]);
        triallabel(trialnumval,:)=trialnumlab;
        
        
    end;
end;

if isempty(triallabel) triallabel=blanks(maxtrial)';end;


norgax=4;       %number of axes in this figure

figorgh=figure;
set (figorgh,'tag',['mt_organization' mt_gsnum(1)]);  %other properties...????
set(figorgh,'numbertitle','off','menubar','none');
set(figorgh,'name',[int2str(figorgh) ': ' get(figorgh,'tag')]);
isub=0;


%================================
%first axis: info on signals
%================================
% axis has 1 text object per channel
% userdata of these objects is the signal info structure, details????
isub=isub+1;
temph=subplot(norgax,1,isub);

%this structure is placed in axis userdata
%empty fields are filled in by mt_ssig
myS=struct('signal_list',[],'signalpath',mypath,'ref_trial',reftrial,'unique_matname',[],'mat2signal',[],'max_sample_inc',[],'audio_channel','');
myS.linux_usematlabsound=0; %if 0, linux uses external application for sound
myS.audioplayer=[]; %stores handle to matlab audioplayer
myS.linuxwavplayer='aplay'; %name of linux application to play wav files if linux_usematlabsound==0
myS.audio_autoscale=1;  %default, scale audio output
myS.audio_fsd=1;        %will need setting to range of audio data if autoscaling is turned off

set (temph,'tag','signal_axis','userdata',myS);



%        set (temph,'xlim',[0 1],'ylim',[0 1]);
%        xlabel????
title(['Signals (from ' mypath '; ref: ' reftrial ')'],'interpreter','none');
ylabel('Signal No.');
%the actual signal info will be done mt_ssig

set(gca,'xtick',[]);        
%=========================
%second axis: cut file axis
%==========================
isub=isub+1;
temph=subplot(norgax,1,isub);
cutS=struct('filename',cutname,'data',cutdata,'label',cutlabel,'trial_label',triallabel);
set (temph,'tag','cut_file_axis','userdata',cutS);


title(cutname,'interpreter','none','verticalalignment','top');
cutlim=[min(cutdata(:,4)) max(cutdata(:,4))];
if ~diff(cutlim) cutlim(2)=cutlim(1)+1;end;
set (temph,'xlim',cutlim);
xlabel('Trial Number','verticalalignment','bottom');

%use patch object to display cutlength as a function of trialnumber
%with line (or marker color in V5) determined by cut type
%(the patch object is currently without its own tag so cut data is not accessible via this object)
%cutlen=cutdata(:,2)-cutdata(:,1);
%        hp=patch('xdata',[cutdata(:,4);flipud(cutdata(:,4))],'ydata',[cutlen;flipud(cutlen)],'cdata',[cutdata(:,3);flipud(cutdata(:,3))],'facecolor','none','edgecolor','interp');
%hp=line('xdata',cutdata(:,4),'ydata',cutlen);
%if strcmp(myversion(1),'5') set (hp,'linestyle','none','marker','o');end;
ylabel('Cut Boundaries (s)');



%9.99
%each cut type is a separate line with its own marker and colour

roundtype=round(cutdata(:,cut_typecol));	%avoid proliferation of cuttypes in unusual cases
typelist=unique(roundtype);

%mymarko={'o','square','diamond','v','^','>','<','pentagram','hexagram'};
%most combinations if one more marker than colours
mymarko={'o','square','diamond','v','^','>','<'};
mycolo='rgbcmy';

ntt=length(typelist);
nmark=length(mymarko);
ncolor=length(mycolo);

myrep=ceil(ntt/nmark);
mymarko=repmat(mymarko,1,myrep);
myrep=ceil(ntt/ncolor);
mycolo=repmat(mycolo,1,myrep);

for ido=1:ntt
    vv=find(roundtype==typelist(ido));
    hl=line([cutdata(vv,4) cutdata(vv,4)],cutdata(vv,1:2),'linestyle','none','marker',mymarko{ido},'color',mycolo(ido));
    
    %distinguish start and end markers
    set(hl(1),'markerfacecolor',mycolo(ido));
end;

mylim=get(gca,'ylim');

%vertical line to indicate current trial???

hltn=line([0;0],[mylim(1);mylim(2)],'tag','current_trial_number','erasemode','xor');         


maxt=max(cutdata(:,3));
%mint=min(cutdata(:,3));
mint=0;
if mint==maxt maxt=mint+1;end;




%======================
%3rd. axis: trial axis
%======================
%axis includes 2 line objects showing temporal extent of available
%signal data for current trial
%cut data for current trial is also displayed here???
%y axis is signal number (cut type is normalized to this) how?



isub=isub+1;
temph=subplot(norgax,1,isub);

trialS=struct('number',0,'label','','cut_data',[],'cut_label','','signal_t0',[],'signal_tend',[],'maxmin_signal','<none>');

set (temph,'tag','trial_axis','userdata',trialS);
title ('Trial label','interpreter','none','verticalalignment','top');	%dummy
%line objects for cuts is updated by mt_loadt

%how to normalize for cut type????
hl1=line(0,0);
xS=struct('min_type',mint,'max_type',maxt);
set (hl1,'color','g','tag','trial_cut_start','userdata',xS);
hl2=line(0,1);
set (hl2,'color','r','tag','trial_cut_end');
if strcmp(myversion(1),'4')
    set([hl1;hl2],'linestyle','o');
else
    set(hl1,'marker','^','linestyle','none','markersize',12);
    set(hl2,'marker','v','linestyle','none','markersize',12);
end;

hl1=line(0,0);
set (hl1,'color','w','tag','signal_t0');
hl2=line(0,1);
set (hl2,'color','w','tag','signal_tend');
if strcmp(myversion(1),'4')
    set([hl1;hl2],'linestyle','o');
else
    set(hl1,'marker','>','linestyle','none');
    set(hl2,'marker','<','linestyle','none');
end;


%axis could include a line object showing current cut position
hpos=line([0 1],[0.5 0.5]);
set(hpos,'tag','current_cut_position','linewidth',2,'erasemode','xor');
xlabel('Time (s)','verticalalignment','bottom');
ylabel('Signal No.');


%two supplementary line objects of e.g maxmin envelope display
hll=line(0,0,'tag','osci_max');
hll=line(0,0,'tag','osci_min');





%===========================
%4th. axis: current cut axis
%===========================


%should marker data also be added to this structure???

ccutS=struct('number',0,'data',[0 1 0 0],'label','','sub_cut_data',[],'sub_cut_label','','maxmin_signal','<none>');

%like cursor axis of f(t) figure will show contained cuts
%also shows position of f(t) display window  (cursor axis)

isub=isub+1;
temph=subplot(norgax,1,isub);
set (temph,'tag','current_cut_axis','userdata',ccutS);
title ('label','interpreter','none','verticalalignment','top');      %dummy

%sub cut data will be
%displayed with cuttype on y axis
% updata 11.97. Additional line object for cut end
%see also mm_next

%similar procedure for markers. See mm_imark and mm_lmark

%new for mt!!!
%xlim correspond to cutstart and cutend, not 0..cutlength
set (temph,'xlim',[0 1],'ylim',[mint maxt]);


hl1=line(0,maxt);
set (hl1,'color','g','tag','sub_cut_start');
hl2=line(0,maxt);
set (hl2,'color','r','tag','sub_cut_end');
if strcmp(myversion(1),'4')
    set([hl1;hl2],'linestyle','o');
else
    set(hl1,'marker','^','linestyle','none','markersize',12);
    set(hl2,'marker','v','linestyle','none','markersize',12);
end;
set([hl1;hl2],'visible','off');

ylabel('Cut type');
xlabel('Time (s)');
%do line object showing display window position
hpos=line([0 1],[maxt maxt]);
set(hpos,'tag','cursor_axis_position','linewidth',2,'erasemode','xor');

%two supplementary line objects of e.g maxmin envelope display
hll=line(0,0,'tag','osci_max');
hll=line(0,0,'tag','osci_min');


%====================================================
%4th axis (not visible). Figure and cursor bookkeeping
%====================================================

haxfig=axes;
set(haxfig,'tag','figure_axis','visible','off');
figS.session_number=MT_SESSION_NUMBER;
%rest of fields filled in after intializing f(t) figure

%=================================================
%5th axis (not visible). Signal editor bookkeeping
%==================================================
haxedit=axes;
set(haxedit,'tag','editor_axis','visible','off');

editS.sig2edit='';
editS.sig4replace='';
editS.editmarker='o';
editS.unsavededits=0;
editS.interpmethod='linear';
editS.equations='';

set(haxedit,'userdata',editS);




%===========================
%graphics initialization of f(t) figure
%===========================

%create figure
figh=figure;
set (figh,'PaperType','a4letter','tag',['mt_f(t)' mt_gsnum(1)],'pointer','crosshair');
set(figh,'numbertitle','off','menubar','none');
set(figh,'name',[int2str(figh) ': ' get(figh,'tag')]);
%userdata has list of signalnames, axisnames and panel numbers
% sub_cut_flag and new_data flag (9.98)
myS=struct('signal_name','','axis_name','','panel_number',[],'active_flag',[],'sub_cut_flag',0,'new_data_flag',0,'bookmark',[],'sub_cut_marker',str2mat('^','v'),'sub_cut_linestyle',str2mat('-.',':'),'sub_cut_labelposition',0.5);
set(figh,'userdata',myS);
%create axes for cursor.
%Actual position will be modified by mt_setft
axiscurh=axes('ylim',[0 maxt],'tag','cursor_axis','tickdir','out','ycolor','r');
if myversion(1)>'4' 
    set(axiscurh,'yaxislocation','right');
    ylabel('cut_type','interpreter','none','fontsize',10,'verticalalignment','bottom');%actually horizontal adjustment, to keep away from colorbar
end;
%create 2 line objects for sub_cut boundaries
%text objects will be created as needed

hl=line([0;0],[0;1]);
subc_colour='w';	%may depend on colormap etc.
set(hl,'tag','sub_cut_start','visible','off','marker',myS.sub_cut_marker(1),'markersize',10,'linestyle',myS.sub_cut_linestyle(1),'color',subc_colour);
hl=line([0;0],[0;1]);
set(hl,'tag','sub_cut_end','visible','off','marker',myS.sub_cut_marker(2),'markersize',10,'linestyle',myS.sub_cut_linestyle(2),'color',subc_colour);



xlabel('Time (s)');
title(cutname,'interpreter','none');    %dummy

%create line objects for cursors. Left, right and movie
curh=line([0 1 0.5;0 1 0.5],[0 0 0;maxt maxt maxt]);

set (curh,'EraseMode','xor','visible','off');
set (curh(1),'tag','left_cursor','color','r');
set (curh(2),'tag','right_cursor','color','g');
set (curh(3),'tag','movie_cursor','color','w');
%cursor free/fixed initialized in main program; see also mm_tcurs

%======================================
%end of graphics initialization
%=====================================

figS.figure_list='mt_f(t)';
figS.foreground='mt_f(t)';	%foreground, i.e current figure, for cursor commands
figS.cursor_status=[0 1];	%for left and right, 0 fixed, 1 free
figS.cursor_colours='rgw'; %for fixed/free/movie ; watch out! must match above
figS.time_cursor_handles=curh';

%as other figure types are developed they should be initialized here


figS.xy_contour_handles=[];
figS.xy_vector_handles=[];
figS.xycursor_settings=[];
figS.autoimageupdateflag='';		%flag whether video image or surf is updated automatically with cursor movement
set(haxfig,'userdata',figS);




%initialize time axis and cursor positions
mt_sdtim([0 1]);


%put the organization figure across the top of the screen
screensize=get(0,'screensize');
xx=0.8*screensize(3);
yy=0.15*screensize(4);
set(figorgh,'position',[0.1*screensize(3) screensize(4)-1.2*yy xx yy]);