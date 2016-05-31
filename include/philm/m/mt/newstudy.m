function newstudy(cutfile,cuttype,recpath,reftrial,filelist,newpath,oldtrialnumflag,trialnumoffset)
% NEWSTUDY Splice out data from existing set of trials, and store as new set of trials
% function newstudy(cutfile,cuttype,recpath,reftrial,filelist,newpath,oldtrialnumflag,trialnumoffset)
% NEWSTUDY: Version 16.05.2013
%
%   Notes
%       The number of new trials corresponds to the number of segments of type cuttype found in cutfile.
%       cuttype can be a vector of possible values.
%       recpath and reftrial: Use as in mt_new etc.
%       filelist: Enables different kinds of data (e.g audio, ema) that is
%			located in different mat files to be processed in one go.
%			Appended to recpath and newpath to form complete file name
%			(plus trial number). Note that filelist cannot be empty, even if
%			only one kind of data is being processed.
%		newpath: Common part of output file name. Output directory must be
%			created by hand.
%		oldtrialnumflag: Optional. Default to false. Use old trial number for output (normally, new trial number is simply the
%			number of the segment in the  cutfile.
%       trialnumoffset: Optional. Default to 0
%       A basic cut file named [newpath '_cut'] is created.
%       Number of digits in the new trial number is determined by the
%       maximum new trial number (not by the length of reftrial)
%
%   Updates
%       11.07: Explicit handling of data variables with 3 dimensions where 3rd
%       dimension is sensor (e.g as used with 3D EMA). In fact, this is
%       probably unnecessary
%		10.08: oldtrialnumberflag
%       05.2013: trialnumberoffset; cuttype can be vector

functionname='NEWSTUDY: Version 16.05.2013';

oldtrialnum=0;
if nargin>6 
    if ~isempty(oldtrialnumflag)
        oldtrialnum=oldtrialnumflag;
    end;
end;

tnoffset=0;
if nargin>7 tnoffset=trialnumoffset; end;

cutdata=mymatin(cutfile,'data');
cutlabel=mymatin(cutfile,'label');
cutcomment=mymatin(cutfile,'comment');
Pc=desc2struct(mymatin(cutfile,'descriptor'));

vv=find(ismember(cutdata(:,Pc.cut_type),cuttype));

cutdata=cutdata(vv,:);
cutlabel=cutlabel(vv,:);


ntrial=size(cutdata,1);

if oldtrialnum
	tnu=unique(cutdata(:,4));
	if length(tnu)<ntrial
		disp('newstudy: trial numbers must be unique if using old trial numbers');
		keyboard;
		return;
	end;
end;


newcutdata=zeros(ntrial,4);
if oldtrialnum

	newcutdata(:,4)=cutdata(:,4);
else
	newcutdata(:,4)=(1:ntrial)';
end;

newcutdata(:,4)=newcutdata(:,4)+tnoffset;

newcutdata(:,2)=cutdata(:,2)-cutdata(:,1);

ndig=length(reftrial);
if oldtrialnum

	ndigout=ndig;
else
	ndigout=length(int2str(max(newcutdata(:,4))));
end;


nfile=size(filelist,1);

%loop thru trial

for itrial=1:ntrial
	intrial=cutdata(itrial,4);
	newtrial=newcutdata(itrial,4);
	disp(['Cut record, in trial, out trial ' int2str([itrial intrial newtrial])]);
	for ifile=1:nfile
		t0=0;		%must exist, even if not in file
		item_id='';
		mynamein=[recpath deblank(filelist(ifile,:)) int2str0(intrial,ndig)];
		mynameout=[newpath deblank(filelist(ifile,:)) int2str0(newtrial,ndigout)];
		load(mynamein);
		%check if output file exists
		if exist([mynameout '.mat'],'file');
			disp(['newstudy: Overwriting ' mynameout]);
		end;

		copyfile([mynamein '.mat'],[mynameout '.mat']);

		sensorstyle=0;
		multi=0;
		ndim=ndims(data);
		ndatin=size(data,1);
		ndesc=size(descriptor,1);

		%Identify sensor-style data
		%criteria: size of descriptor > 1 and number of dimensions in data is 3
		%In fact, matlab probably handles them correctly if they are treated like 'normal'
		%two-dimensional data below, i.e the 3D array is referred to with 2D
		%indexing.
		if ndesc>1 & ndim==3
			sensorstyle=1;
		end;

		%Identify multidimensional data like images (also for vector data like spectral slices or epg frames stored
		% as a vector)
		%Criteria: size of descriptor is 1, and size of second dimension is > 1
		%The time dimension is assumed to be the last dimension
		if ndesc==1 & size(data,2)>1
			multi=1;
			ndatin=size(data,ndim);
		end;


		splicecut=cutdata(itrial,1:2);
		splicecut=splicecut-t0;
		splicecut=splicecut*samplerate;
		splicecut(1)=splicecut(1)+1;
		splicecut=round(splicecut);
		basecut=splicecut;
		splicecut(1)=max([splicecut(1) 1]);
		splicecut(2)=min([splicecut(2) ndatin]);

		t0=(splicecut(1)-basecut(1))*samplerate;

		if ~multi
			%explicit handling of sensor-style data is probably not necessary
			if sensorstyle
				data=data(splicecut(1):splicecut(2),:,:);

			else
				data=data(splicecut(1):splicecut(2),:);
			end;

			%should be a better way of doing this
			%for multidimensional data it may also be necessary to adjust the dimension structure

		else
			switch ndim
				case 2
					data=data(:,splicecut(1):splicecut(2));
				case 3
					data=data(:,:,splicecut(1):splicecut(2));
				case 4
					data=data(:,:,:,splicecut(1):splicecut(2));
				otherwise
					disp('newstudy: rewrite for more dimensions');
					return;
			end;
		end;


		olditem_id=item_id;
		item_id=deblank(cutlabel(itrial,:));

		%update comment

		supcomment=['Data spliced from: ' mynamein crlf];
		supcomment=[supcomment 'Data spliced using: ' cutfile crlf];
		supcomment=[supcomment 'Cut type: ' int2str(cuttype) crlf];
		supcomment=[supcomment 'Old item_id: ' olditem_id crlf];
        supcomment=[supcomment 'Old trial number flag: ' int2str(oldtrialnum) crlf];
        supcomment=[supcomment 'trial number offset: ' int2str(tnoffset) crlf];
        
        
		comment=[supcomment comment];
		comment=framecomment(comment,functionname);

		save(mynameout,'data','item_id','t0','comment','-append');

	end;
end;

[descriptor,unit,valuelabel]=cutstrucn;

data=newcutdata;
label=cutlabel;

supcomment=['Data spliced using: ' cutfile crlf];
supcomment=[supcomment 'Cut type(s): ' int2str(cuttype) crlf];
        supcomment=[supcomment 'Old trial number flag: ' int2str(oldtrialnum) crlf];
        supcomment=[supcomment 'trial number offset: ' int2str(tnoffset) crlf];

comment=[supcomment cutcomment];
comment=framecomment(comment,functionname);

save([newpath '_cut'],'data','label','descriptor','unit','comment','valuelabel');

