function outstats=kalman_fb(basepath,kalmansuffix,triallist,chanlist,startpos)
% KALMAN_FB Kalman position calculation (forwards/backwards)
% function outstats=kalman_fb(basepath,kalmansuffix,triallist,chanlist,startpos)
% kalman_fb: Version 19.09.2010
%
%	Description
%		Run kalman amp2pos forwards-backwards-forwards
%			Store these variants, and also mean of backwards and 2nd
%			forwards
%		startpos: Optional, specify as for tapad
%		data is stored in [basepath 'kalman' kalmansuffix pathchar
%		'rawposf0/f/b/m']
%		In rawposm any samples exceeding the hardcoded rms limit (50) or
%		the limit on difference between forward and backward pass (20mm)
%		are set to NaN
%		For each trial and channel prints (and stores in output argument)
%		the following statistics:
%		rms for 2nd forwards, backwards, merged; eucdist in mm between
%		forwards and backwards, number of NaNs in rawposm version.
%		(note: stats are calculated before setting any data to NaN)
%
%	Updates
%		17.3.09 rms and f/b difference limit included
%		19.3.09 use kalmanxpath file to determine location of amp2pos
%			exectuable
%		24.2.10 skip missing trials
%		14.3.10 skip any trials with nans: can happen with any trials that
%			were too short to be filtered by filteramps. Note: criterion for
%			skipping will be determined by whatever channel uses the longest
%			filter. Also give a warning if channel probably not in use (all
%			zero amps)
%		9.10 more meaningful descriptor and unit for forward-backward
%			distance. Include max(fbdist) in stats output. Running stats
%			output format changed.

functionname='kalman_fb amp2pos: Version 19.09.2010';

kxp=[];
if exist('kalmanxpath.mat','file')
	kxp=mymatin('kalmanxpath','kalmanxpath');
end;
if isempty(kxp) kxp='.'; end;
kxp=[kxp pathchar];



maxchan=12;
orifac=pi/180;
ndig=4;
rmsfac=2500;

rmslim=50;
difflim=20;		%maximum allowed difference between forward and backward (in mm)

private.kalman_fb=[];

amppath=[basepath pathchar];

kalmanpath=[amppath 'kalman' kalmansuffix pathchar ];

amppath=[amppath 'amps' pathchar];

startname='start4kalman.pos';
iniposdir='inipos';
iniext='.ini';
userstart=0;

warning off;
mkdir([kalmanpath 'amps']);
warning on;
%no verbose output if optimization start position method is used
verboseswitch='';
initswitch='';
%user-defined start position
if nargin>4
	warning off;
	mkdir(iniposdir);
	warning on;

	ss=ones(1,7,12)*NaN;
	ss(1,1:5,:)=(startpos(:,1:5))';
	savepos(startname,ss);
	userstart=1;
	verboseswitch=' -v ';
	initswitch=[' --initdir ' iniposdir ' '];
	private.kalman_fb.startpos=startpos;
end;

ignoreswitch='';
ignorechan=setdiff(1:maxchan,chanlist);
if ~isempty(ignorechan)
	ignoreswitch=strm2rv(int2str(ignorechan'),',');
	ignoreswitch=strrep(ignoreswitch,' ','');	%remove blanks
	ignoreswitch(end)=' ';		%change trailing comma to blank
	ignoreswitch=[' -i ' ignoreswitch];
end;

chstring=int2str(chanlist);
if size(chanlist,1)==1 chstring=int2str(chanlist'); end;
chstring=strcat(chstring,':');
myblanks=(blanks(length(chanlist)))';

chstring=[chstring myblanks];




kalmanpospath=[kalmanpath 'workpos'];	%raw forwards backwards forwards
kalmanpathf0=[kalmanpath 'rawposf0'];		%mat forwards (1)
kalmanpathf=[kalmanpath 'rawposf'];		%mat forwards (2)
kalmanpathb=[kalmanpath 'rawposb'];		%mat backwards
kalmanpathm=[kalmanpath 'rawposm'];		%mat merged forwards/backwards

warning off;
mkdir(kalmanpospath);
mkdir(kalmanpathf0);
mkdir(kalmanpathf);
mkdir(kalmanpathb);
mkdir(kalmanpathm);
warning on;

%store some stats on rms for different solutions, mean distance between
%forwards-backwards, max dist between forwards and backwards, and number of NaNs (combined from rmslim and difflim)

columnlabels='rms_f rms_b rms_m fbdist(mean) fbdist(max) n_nan';
outstats=ones(max(triallist),maxchan,6)*NaN;


for itrial=triallist



	disp(itrial);
	trials=int2str0(itrial,ndig);
	if exist([amppath trials '.mat'],'file')
		ampdata=mymatin([amppath trials],'data');
		ampx=squeeze(ampdata(:,1,chanlist));

		noskip=1;

		if any(isnan(ampx(:)))
			noskip=0;
			disp('NaNs in input (short trial?). Trial will be skipped');
		end;
		ampsum=sum(ampx);
		vv=find(ampsum==0);
		if ~isempty(vv)
			disp(['These channels are probably not in use : ' int2str(chanlist(vv))]);
			disp('They should be removed from the channel list');
		end;

		if noskip
			samplerate=mymatin([amppath trials],'samplerate');
			dimensionamp=mymatin([amppath trials],'dimension');
			basecomment=mymatin([amppath trials],'comment');

			[descriptor,unit,dimension]=headervariables;
			descriptor=cellstr(descriptor);
			descriptor{end}='fbdist';
			descriptor=char(descriptor);
			unit=cellstr(unit);
			unit{end}=unit{1};
			unit=char(unit);
			dimension.axis(3)=dimensionamp.axis(3);       %copy sensor names from amp file

			kalmanampfile=[kalmanpath 'amps' pathchar trials '.amp'];

			ndat=size(ampdata,1);
			%forwards backwards forwards as one time stream
			%	also helps get rid of startup effects
			ampfb=cat(1,ampdata,flipdim(ampdata,1),ampdata);

			saveamp(kalmanampfile,ampfb);
			if userstart
				copyfile(startname,[iniposdir pathchar trials iniext]);
			end;
			kalmans=[kxp 'amp2pos -s ' ignoreswitch verboseswitch initswitch ' -d ' kalmanpospath ' ' kalmanampfile]; %put unused channel here

			disp(kalmans);
			[status,result]=system(kalmans);
			disp([int2str(status) ' ' result]);

			comment=[kalmans crlf int2str(status) ' ' result crlf basecomment];

			comment=framecomment(comment,functionname);



			tmppos=LoadPos([kalmanpospath pathchar trials]);

			%	get first chunk calculated forwards
			dp=[1 ndat];
			data=tmppos(dp(1):dp(2),:,:);
			dataf0=data;
			data=single(data);


			%save as mat file with standard variables
			save([kalmanpathf0 pathchar trials],'data','descriptor','dimension','samplerate','comment','unit','private');

			%get chunk calculated backwards
			dp=dp+ndat;
			data=tmppos(dp(1):dp(2),:,:);
			data=flipdim(data,1);
			datab=data;
			data=single(data);


			%save as mat file with standard variables
			save([kalmanpathb pathchar trials],'data','descriptor','dimension','samplerate','comment','unit','private');

			%get final chunk calculated forwards
			dp=dp+ndat;
			data=tmppos(dp(1):dp(2),:,:);
			dataf=data;
			data=single(data);


			%save as mat file with standard variables
			save([kalmanpathf pathchar trials],'data','descriptor','dimension','samplerate','comment','unit','private');

			%calculate merged solution
			nchan=size(data,3);

			data=ones(size(data))*NaN;

			for ich=chanlist
				%use loadpos_sph2cartm?????
				%to average the forward and backward solution first convert the spherical
				%coorinates to unit vector
				pos1=dataf(:,1:3,ich);
				ori1=dataf(:,4:5,ich)*orifac;
				[ox1,oy1,oz1]=sph2cart(ori1(:,1),ori1(:,2),1);

				d1=[pos1 ox1 oy1 oz1];

				pos2=datab(:,1:3,ich);
				ori2=datab(:,4:5,ich)*orifac;
				[ox2,oy2,oz2]=sph2cart(ori2(:,1),ori2(:,2),1);

				d2=[pos2 ox2 oy2 oz2];

				dm=(d1+d2)/2;

				oriout=ones(size(dm,1),2)*NaN;
				%convert orientation information back to spherical coordinates
				[oriout(:,1),oriout(:,2),dodo]=cart2sph(dm(:,4),dm(:,5),dm(:,6));

				dm=[dm(:,1:3) oriout/orifac];
				%get posamps and rms for composite solution
				pax=calcamps(dm);

				[newrms,par7tmp]=posampana(ampdata(:,:,ich),pax,rmsfac);
				%compute distance between forwards and backwards as "parameter 7"
				par7=eucdistn(pos1,pos2);
				data(:,:,ich)=[dm newrms par7];
				vx=find((newrms>rmslim) | (par7>difflim));
				n_nan=length(vx);
				outstats(itrial,ich,:)=[mean([dataf(:,6,ich) datab(:,6,ich) newrms par7]) max(par7) n_nan];
				if ~isempty(vx) data(vx,:,ich)=NaN; end;
				%    keyboard;
			end;			%loop thru channels
		
			ss=squeeze(outstats(itrial,chanlist,:));
disp(columnlabels);
			disp([chstring int2str(round(ss(:,1:5)))  myblanks int2str(ss(:,6))]);
				
			%save as mat file with standard variables
			data=single(data);
			save([kalmanpathm pathchar trials],'data','descriptor','dimension','samplerate','comment','unit','private');

		end;		%no skip
	else
		disp(['No data for trial ' trials '?']);
	end;

end;
