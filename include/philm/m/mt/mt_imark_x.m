function mt_imark(nmark,markfile,editmode,cut_type_value,cut_type_label,create_comment)
% MT_IMARK Initialize markers
% function mt_imark(nmark,markfile,editmode,cut_type_value,cut_type_label,create_comment)
% mt_imark: Version 18.1.09
%
%	Syntax
%
%		nmark
%			Number of markers to create. If no input arguments, defaults to 10.
%			If empty, but cut_type_value/label is specified then it is set
%			to the maximum value in cut_type_value (this is the recommended
%			procedure for normal work)
%			The program then makes nmark markers ranging from 1 to nmark
%			available
%
%		markfile
%			MAT file from/to which markers are read/stored.
%			If it does not exist a new MAT file is created.
%			If it already exists, behaviour depends on editmode
%			An existing MAT file is backed up with extension .mak
%
%		editmode
%			Controls read/write behaviour to marker file
%			'N' = None (default)
%			'R' = Read
%			'A' = Append
%			'E' = Edit (Existing markers are read in, and replaced when
%			    storing)
%
%		cut_type_value/label
%			Optional but recommended. Enables a label to be assigned to each
%			marker category used. Inserted in the valuelabel structure in
%			the marker file (every time mt_imark is called, not just when
%			the marker file is created, so additional labels can be added, or existing ones redefined)
%			_value should be a column vector of marker types
%			_label should be a string matrix of the same length as _value
%
%       create_comment
%           Optional. Text to insert in the comment variable of the marker
%           file, e.g explaining the kind of segments that it will contain. Could for example be the help
%           text of some function to do semi-automatic gestural analysis.
%           This input argument is only relevant when the marker file is
%           first created. Otherwise it is ignored.
%           In the main userdata structure there is in addition a field
%           called 'session_comment'. This is written to the
%           private.mtmark.current_session_log every time any data is written
%           to the marker file, so this can be set up by the user to give
%           details of e.g labelling functions used in each session (use
%           mt_smarx('session_comment','Some text')).
%           Each time mt_imark is called (after the first time) then the
%           current contents of current_session_log are appended to
%           private.mtmark.session_history
%
%	See also
%		MT_SMARK: Set markers; MT_CMARK: clear markers; MT_LMARK: log markers to disk;
%		MT_GMARK: get markers; MT_RMARK: read markers from MAT file
%       MT_SMARX: Set fields in the marker userdata structure
%
%	Graphics
%
%		1. Cursor axis of the main time figure, and other time figures
%			line 'markerstart'
%				userdata markertype (1..nmark)
%			line 'markerend'
%				userdata markertype (1..nmark)
%				linetype '--'
%			text 'markerlabel'
%				position(1) follows xdata of markerstart
%
%		2. Current cut axis of the organization figure
%			text 'marker_org'
%				position [0 currentmarker]
%				string filename of output cut file
%				userdata [nmarker currentmarker]
%        userdata
%			All marker information are stored in the fields of the userdata structure
%				filename
%				edit_mode
%				n_markers
%				current_marker
%				start
%				end
%				label		!!cell array
%				status
%				source_cut
%				marker_axes_handles
%               !!new 1.09
%               autocurrentlabelflag
%               addlabel_status
%               session_comment
%               session_comment_base
%               type_labels_use
%
%   Updates
%       1.09
%           Allow for better documentation of labelling procedures (in
%           comment and private variable of marker file)
%           Start to revise procedures for including current cut in marker file, and label
%           of current cut in all markers
%           See new fields in userdata




%    These two line objects work like the subcut line objects
%    also in the current cut axis (see also mt_org)
%    line 'marker_start'
%         xdata: marker positions
%         ydata: marker size
%    line 'marker_end'
%         ditto but color red (green for start positions)

functionname='mt_imark: Version 18.1.09';

myversion=version;

matname='';
editstring='/N';

if nargin==0
	nmark=10;
end;

if nargin>1
	if ~isempty(markfile) matname=markfile; end;
end;
if nargin>2
	if ~isempty(matname) editstring(2)=editmode(1); end;
end;

%make sure name specified without extension, otherwise test for existing
%file does not work
matname=strrep(matname,'.mat','');



myok=0;
if nargin>=5
	myok=1;
	if size(cut_type_value,1)~=size(cut_type_label,1)
		disp ('mt_imark: cut_type value and label do not match!');
		myok=0;
	end;
	if ~ischar(cut_type_label)
		disp ('mt_imark: cut_type label is not char!');
		myok=0;
	end;
	if myok
		%May be adjusted below if marker file already exists
		valuelabel.cut_type.value=cut_type_value;
		valuelabel.cut_type.label=cut_type_label;
		if ~isempty(cut_type_value)
			if isempty(nmark) nmark=max(cut_type_value); end;
		end;


	end;
end;

if ~myok cut_type_value=[]; cut_type_label=''; end;


if isempty(nmark) nmark=10; end;

if nargin>5 helpwin(create_comment,'MT_IMARK: Creation comment to marker file');end;




foh=mt_gfigh('mt_organization');

gcaold=gca;

%set up markers in all axes with time displays
timcur=mt_gfigd('time_cursor_handles');
timcur=timcur(:);timcur=timcur(ishandle(timcur));
ll=length(timcur);
hac=[];
if ll
	for ii=1:ll
		hac(ii)=get(timcur(ii),'parent');
	end;
end;
hac=unique(hac);

nhac=length(hac);


hacc=findobj(foh,'tag','current_cut_axis');

oldorg=mt_gmarx;
if ~isempty(oldorg)
	hacold=oldorg.marker_axes_handles;


	%if markers already present then delete; warning????
	h1=findobj([hacold;hacc],'tag','marker_start');
	h2=findobj([hacold;hacc],'tag','marker_end');
	h3=findobj(hacold,'tag','marker_label');
	ho=findobj(hacc,'tag','marker_org');
	hh=[h1;h2;h3;ho];
	if ~isempty(hh)
		disp ('Deleting existing marker objects');
		delete(hh);
	end;
end;



if nhac>0
	newlim=get(hac(1),'ylim');
	newlim(2)=max([newlim(2) nmark]);

	%cursor axis ylim will be set to  [0 maximum_mark_size]

	myx=[NaN;NaN];

	%set(gca,'ytick',ytickpos,'yticklabel',yticklab);
	%?? do yticklabel below??
	set(hac,'ylim',newlim,'ygrid','on','ytick',nmark);

	%adjust size of all cursors

	set(timcur,'ydata',newlim);

	mcolor='w';

%	merase='xor';		%if it looks ok its much faster
	merase='normal';		%if it looks ok its much faster
	mlinewidth=1;
	%loop thru all time cursor axes
	for itax=1:nhac
		axes(hac(itax));

		for ii=1:nmark
			myy=[0;ii];


			hls=line(myx,myy,'color',mcolor,'tag','marker_start','userdata',ii,'erasemode',merase,'linewidth',mlinewidth);
			hle=line(myx,myy,'color',mcolor,'tag','marker_end','userdata',ii,'linestyle','--','erasemode',merase,'linewidth',mlinewidth);
			set(hls,'marker','>','markersize',12);
			set(hle,'marker','<','markersize',12);
			%      set(hls,'marker','>','markersize',12,'markerfacecolor',mcolor);
			%      set(hle,'marker','<','markersize',12,'markerfacecolor',mcolor);

			%Note: using NaN for text x position seemed to cause problems
			%note vertical alignment  'top' is to get label of largest marker away from axes title
%text size maybe also dependent on number of markers?
			text('position',[0 myy(2)],'string',' ','tag','marker_label','userdata',ii,'horizontalalignment','left','verticalalignment','top','clipping','off','erasemode',merase,'fontsize',10,'interpreter','none','fontweight','bold');




		end;

	end;		%loop thru time axes

end;		%nhac>0
%==============================
%



%current cut axis may need rescaling
newlim=get(hacc,'ylim');
%newlim(1)=min([oldlim(1) 1]);
newlim(2)=max([newlim(2) nmark]);
set(hacc,'ylim',newlim);

hpos=findobj('tag','cursor_axis_position');
set (hpos,'ydata',[newlim(2) newlim(2)]);

mynan=ones(nmark,1)*NaN;
%text object for organization in current cut axis
myS.filename=matname;
myS.edit_mode=editmode;
myS.n_markers=nmark;
myS.current_marker=nmark;
myS.start=mynan;
myS.end=mynan;
cc=cell(nmark,1);		%cell array
for imm=1:nmark cc{imm}='';end;
myS.label=cc;
myS.status=zeros(nmark,1);
myS.source_cut=zeros(nmark,1);
myS.marker_axes_handles=hac;



%add label of current mt cut to label of markers when storing (default in on)
%(and strip when reading existing markers in (read and edit mode))
myS.autocurrentlabelflag=1;

%Only relevant if autocurrentlabelflag==1
%overrides for specific markers
%set to true for all markers at the end of each call to mt_lmark
%set to false by mt_rmark for any existing markers that already have a
%label not beginning with the current cut label, i.e these labels will be
%read in and stored as they stand
myS.addlabel_status=ones(nmark,1);
myS.autolabelsep='/';		%needed by mt_lmark and mt_rmark;


myS.session_comment=[];     %free to be set by the user
% see session_comment_base below, which is set automatically


axes(hacc);
hmtext=text(0,nmark,[matname editstring],'tag','marker_org','userdata',myS,'visible','off');
set(hacc,'ytick',nmark,'ygrid','on');
hlab=get(hacc,'xlabel');
temps=get(hlab,'string');
set(hlab,'string',[temps ' (Marker file: ' matname editstring ')']);
set(hlab,'interpreter','none');

%and additional line objects for copies of marker start and end position
hl1=line(mynan,(1:nmark)');
set (hl1,'color','g','tag','marker_start','erasemode',merase,'linewidth',mlinewidth);
hl2=line(mynan,(1:nmark)');
set (hl2,'color','r','tag','marker_end','erasemode',merase,'linewidth',mlinewidth);
%if strcmp(myversion(1),'4')
%    set([hl1;hl2],'linestyle','x');
%else
set(hl1,'marker','>','markersize',12,'markerfacecolor','g','linestyle','none');
set(hl2,'marker','<','markersize',12,'markerfacecolor','r','linestyle','none');
%end;


if ~isempty(matname)
	cutname=mt_gcufd('filename');
	if ~exist([matname '.mat'],'file');
		disp('mt_imark: Creating new marker file');
		data=[];
		label='';

		comment=mymatin(cutname,'comment','<No comment in mtnew cut file>');
		%create new files with a complete set of variables
		[descriptor,unit,dodo]=cutstrucn(1);

		comment=framecomment(comment,['Comment from cut file ' cutname]);

		if nargin>5
			comment=['mt_imark: User comment at creation of marker file:' crlf create_comment crlf comment];
		end;
		comment=framecomment(comment,functionname);



		trial_number_label=mt_gcufd('trial_label');
		trial_number_value=(1:size(trial_number_label,1))';

		valuelabel.trial_number.label=trial_number_label;
		valuelabel.trial_number.value=trial_number_value;

		private.mtmark.current_session_log=[];
		dummyca={'dummy'};
		private.mtmark.session_history=dummyca;
		private.mtmark.session_datenum=now;
		

		save(matname,'data','label','descriptor','unit','comment','valuelabel','private');


	else
		disp('mt_imark: Using existing marker file');
		disp('Current version backed up with extension .mak');
		%mode changed to 'f' (6.07)
		%      [mystat,msg]=copyfile([matname '.mat'],[matname '.mak'],'writable');
		[mystat,msg]=copyfile([matname '.mat'],[matname '.mak'],'f');
		if ~mystat
			disp('mt_imark: Backup of current version may have failed');
			disp(msg);
		end;
		%update private and cut_type valuelabel
		private=mymatin(matname,'private');
		newprivate=1;
		if ~isempty(private)
			if isfield(private,'mtmark')
				newprivate=0;
				oldlog=private.mtmark.current_session_log;
				oldhist=private.mtmark.session_history;
				olddatenum=private.mtmark.session_datenum;
				loglen=length(olddatenum);
				oldhist{loglen}=oldlog;
				oldhist{loglen+1}='dummy';
				olddatenum=[olddatenum;now];
%see below, provisional setting with sessionbasecomment
				private.mtmark.current_session_log=[];
				private.mtmark.session_history=oldhist;
				private.mtmark.session_datenum=olddatenum;
			end;
		end;
%link with case where new marker file is created (see above)
		if newprivate
			private.mtmark.current_session_log=[];
			dummyca={'dummy'};
			private.mtmark.session_history=dummyca;
			private.mtmark.session_datenum=now;
		end;

		[oldcutlabel,oldcutvalue]=getvaluelabel(matname,'cut_type');
		%merge with any specification in input argument
		if exist('valuelabel','var')

			cut_type_value=valuelabel.cut_type.value;
			cut_type_label=valuelabel.cut_type.label;

			[retainoldvalue,reti]=setdiff(oldcutvalue,cut_type_value);
			if ~isempty(retainoldvalue)


				cut_type_label=str2mat(cut_type_label,oldcutlabel(reti,:));
				cut_type_value=[cut_type_value;retainoldvalue];

				[cut_type_value,ui]=sort(cut_type_value);
				cut_type_label=cut_type_label(ui,:);
			end;

			valuelabel=mymatin(matname,'valuelabel');
			valuelabel.cut_type.value=cut_type_value;
			valuelabel.cut_type.label=cut_type_label;

			save(matname,'valuelabel','-append');
		else
			cut_type_label=oldcutlabel;
			cut_type_value=oldcutvalue;
		end;


		save(matname,'private','-append');





		%    set(hmtext,'userdata',myS);

	end; %exist

	W=whos('-file',matname,'data');

	if isempty(cut_type_value)
		disp('No cut_type labels/values are available: Please change in input mark file, or input arguments to mt_imark, if possible');
		keyboard;
	end;

	%also include pwd, hostname, username????
	username=getenv('username');
	if isempty(username)
		[mystat,username]=system('whoami');
		if mystat username='NN'; end;
	end;

	sessionbasecomment=['User name: ' username '. MT cut file: ' cutname '. Working directory: ' pwd crlf 'nmark: ' int2str(nmark) '; editmode: ' editmode '; initial size of marker file: ' int2str(W.size) '; initial number of cut type labels: ' int2str(length(cut_type_value)) crlf];
	%this will give the starting time of the current session
	sessionbasecomment=framecomment(sessionbasecomment,functionname);
	myS.session_comment_base=sessionbasecomment;

	private=mymatin(matname,'private');
%this field is updated every time mt_lmark is called
	private.mtmark.current_session_log=sessionbasecomment;
%this field will not be definitive until mt_imark is called again
	oldhist=private.mtmark.session_history;
	oldhist{end}=sessionbasecomment;
	private.mtmark.session_history=oldhist;
	
	save(matname,'private','-append');
	
	%
	%basic set up based on input argument
	%may be adjusted by mt_lmark when segments from mt cutfile are added to
	%the marker file
	tmplabel=cellstr(cut_type_label);
	tmpcell=cell(nmark,1);
	tmpcell(cut_type_value)=tmplabel;
	tmpcell=strcat(int2str((1:nmark)'),'_',tmpcell);

	myS.type_labels_use=char(tmpcell);
	set(hmtext,'userdata',myS);
	helpwin(char(tmpcell),'Type Labels');
end; %empty


axes(gcaold);
