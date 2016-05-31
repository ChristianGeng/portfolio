function mt_lmark
% MT_LMARK Log markers to MAT file
% function mt_lmark;
% mt_lmark: Version 10.09.2010
%
%	See also
%		MT_IMARK: initialize markers; MT_SMARK: Set markers; MT_CMARK: clear markers; MT_GMARK: get markers
%
%	Notes
%		A warning is issued if only one of the two marker boundaries is set.
%		Unset boundaries appear as NaN in the output MAT file.
%		Markers with neither start nor end boundary set are ignored.
%		If no MAT file enabled for writing, simply resets all markers
%		Sorts the complete cut file every time the function is called.
%		The present way of doing this may be rather time consuming for large cut files
%
%	Graphics
%   1. Cursor axis of the main figure
%   line 'markerstart'
%        userdata markertype (1..nmark)
%   line 'markerend'
%        userdata markertype (1..nmark)
%        linetype '--'
%   text 'markerlabel'
%        position(1) follows xdata of markerstart
%   2. Current cut axis of the organization figure
%   text 'marker_org'
%        position [0 currentmarker]
%        string filename of output cut file
%        userdata [nmarker currentmarker]
%	Updates
%		8.10 catch problem with initialization of session_comment_base in
%		mt_imark

functionname='mt_lmark: Version 10.08.2010';


orgdat=mt_gmarx;
if isempty(orgdat) return; end;
maxmark=orgdat.n_markers;
curmark=orgdat.current_marker;

editmode=orgdat.edit_mode;
matname=orgdat.filename;

autolabelsep=orgdat.autolabelsep;
ichange=0;
newvaluelabel=0;

%check if any edits have been done at all
mstatus=mt_gmarx('status');
if any(mstatus)

	fileactive=((~isempty(matname))&(findstr(editmode,'AE')));


	if fileactive

		cutdata=mymatin(matname,'data');
		cutlabel=mymatin(matname,'label');
		cutdescriptor=mymatin(matname,'descriptor');
		private=mymatin(matname,'private');
		[cltmp,cvtmp]=getvaluelabel(matname,'cut_type');
		CD=desc2struct(cutdescriptor);
		nparout=size(cutdescriptor,1);

		%this should be called 'current cut', rather than 'trial'
		triallabel=mt_gccud('label');
		trialdata=mt_gccud;
		trialdescriptor=mymatin(mt_gcufd('filename'),'descriptor');
		[tltmp,tvtmp]=getvaluelabel(mt_gcufd('filename'),'cut_type');
		TD=desc2struct(trialdescriptor);

		%preferably, mt cut file and marker file should have same number and
		%arrangement of columns, but this is not strictly necessary

		mdata=ones(maxmark,nparout)*NaN;
		trialdataout=ones(1,nparout)*NaN;
		%for all fields in CD, try and find corresponding field in TD
		for ipar=1:nparout
			vv=strmatch(deblank(cutdescriptor(ipar,:)),trialdescriptor,'exact');
			if length(vv)==1
				trialdataout(ipar)=trialdata(vv);
			end;
		end;


		mdata(:,1:4)=[mt_gmarx('start') mt_gmarx('end') (1:maxmark)' ones(maxmark,1)*mt_gccud('trial_number')];

		mlabel=mt_gmarx('label');


		%additional output parameters
		trialtype=trialdata(3);
		if isfield(CD,'link_type')
			mdata(:,CD.link_type)=trialtype;
		end;

		%link_id defaults to zero rather than nan (not sure this is a good
		%idea)
		link_id=NaN;
		if isfield(TD,'link_id') link_id=trialdata(TD.link_id); end;
		if isnan(link_id) link_id=0; end;

		if isfield(CD,'link_target')
			mdata(:,CD.link_target)=link_id;
		end;
		%also insert in the output version of the mt cut data
		if isfield(CD,'link_id') trialdataout(CD.link_id)=link_id; end;

		%similarly for creation/modification date

		sourcecut=mt_gmarx('source_cut');

		%retrieve creation_date and link_id for existing cuts
		for ii=1:maxmark
			if sourcecut(ii)
				if isfield(CD,'creation_date')
					mdata(ii,CD.creation_date)=cutdata(sourcecut(ii),CD.creation_date);
				end;
				if isfield(CD,'link_id')
					mdata(ii,CD.link_id)=cutdata(sourcecut(ii),CD.link_id);
				end;
			end;
		end;



		if isfield(CD,'creation_date')
			vx=find(mstatus & ~sourcecut);
			mdata(vx,CD.creation_date)=now;
		end;

		if isfield(CD,'modification_date')
			%for these cases we need to get the creation date (also what
			%happens with previous values of other extended variables
			%(link_target etc.)???
			vx=find(mstatus & sourcecut);
			mdata(vx,CD.modification_date)=now;
		end;


		vm=find(mstatus);
		%can't be empty; we checked at the beginning
		mdata=mdata(vm,:);
		mlabel=mlabel(vm);
		mstatus=mstatus(vm);


		%eliminate old markers (edited ones) if in full edit mode
		if strcmp(editmode,'E')
			sourcecut=sourcecut(vm);
			vc=find(sourcecut); %find existing cuts if in full edit mode
			if ~isempty(vc)
				vc=sourcecut(vc);
				cutdata(vc,:)=[];
				cutlabel(vc,:)=[];
				ichange=1;
			end;
		end;



		%         only retain data with at least 1 valid time
		%         or a nonempty label????
		vv=find((~isnan(mdata(:,1))) | (~isnan(mdata(:,2))));
		if ~isempty(vv)
			ichange=1;
			mdata=mdata(vv,:);
			mlabel=mlabel(vv);
			mylen=mdata(:,2)-mdata(:,1);
			vl=find(isnan(mylen));
			if ~isempty(vl)
				disp ('MT_LMARK (note): Only one boundary set');
				disp (mdata(vl,1:4))
			end;
			nleft=size(mdata,1);

			%insert current cut label in front of marker label
			%unless this has been disabled
			if orgdat.autocurrentlabelflag
				addstat=orgdat.addlabel_status;
				for ilab=1:nleft
					tmptype=mdata(ilab,3);
					if addstat(tmptype)
						tmpstr=[triallabel autolabelsep mlabel{ilab}];
						mlabel{ilab}=tmpstr;
					end;
				end;
			end;

			mlabel=char(mlabel); %convert to string matrix


			%            sort by cut start (any reason?)
			[tmp,iv]=sort(mdata(:,1));
			mdata=mdata(iv,:);
			mlabel=mlabel(iv,:);

			%            Include trial data in output
			%make sure trial data has same arrangement as marker data (see above).
			%then check if already present in marker file
			addtrialdata=1;
			ncutf=size(cutdata,1);
			%only checks numeric parameters,(not label) (and currently only
			%basic parameters, NaNs could be a problem in additional
			%parameters (NaN==NaN does not return TRUE))
			if ~isempty(cutdata)
				if any(all(repmat(trialdataout(:,1:4)',[1 ncutf])==cutdata(:,1:4)'))
					addtrialdata=0;
				end;
			end;

			if addtrialdata
				mdata=[trialdataout;mdata];
				mlabel=str2mat(triallabel,mlabel);
				%check that cut type label and value are already present????
				if ~any(trialdata(3)==cvtmp)
					vv=find(trialdata(3)==tvtmp);
					if length(vv)==1
						cvtmp=[cvtmp(:);trialdata(3)];
						cltmp=str2mat(cltmp,deblank(tltmp(vv,:)));
						[cvtmp,tmpi]=sort(cvtmp);
						cltmp=cltmp(tmpi,:);
						newvaluelabel=1;
					else
						disp('mt_lmark: unable to add cut type label to valuelabel');
					end;

				end;
			end;








			if isempty(cutlabel)
				cutlabel=mlabel;
			else
				cutlabel=str2mat(cutlabel,mlabel);
			end;
			cutdata=[cutdata;mdata];

			%this may be slow
			%could be speeded up
			[cutdata,cutlabel]=sortcut(cutdata,cutlabel);

		end;        %vv not empty

		if ichange
			data=cutdata;label=cutlabel;
			ncut=size(data,1);

			usercomment=framecomment(orgdat.session_comment,'User session comment');
			%also include count of markers changed, added in this session?
%10.8.10
%sometimes it seems that session_comment_base was not setup correctly by
%mt_imark. Catch here as a temporary measure
		basetmp='?No session_comment_base?';
		if isfield(orgdat,'session_comment_base')
			basetmp=orgdat.session_comment_base;
		else
			disp('mt_lmark: No session_comment_base found');
		end;
		
			
			usercomment=['Segments in marker file : ' int2str(ncut) crlf basetmp crlf usercomment];
			usercomment=framecomment(usercomment,functionname);

			private.mtmark.current_session_log=usercomment;

			if newvaluelabel

				valuelabel=mymatin(matname,'valuelabel');
				valuelabel.cut_type.value=cvtmp;
				valuelabel.cut_type.label=cltmp;
				save(matname,'data','label','private','valuelabel','-append');
			else
				save(matname,'data','label','private','-append');

			end;

		end;



	end;        %fileactive
end;        %any edits

%reset
mt_cmark('kill',1:maxmark);
%reset status (edit flag and cut number)
mt_smarx('status',zeros(maxmark,1));
mt_smarx('source_cut',zeros(maxmark,1));
mt_smarx('addlabel_status',ones(maxmark,1)); %re-enable (may then be disabled by mt_rmark)
