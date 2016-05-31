function pegelstats=filteramps(inpath,outpath,triallist,filterspecs,idownfac,usersensornames,usercomment,outpathraw)
% FILTERAMPS Filter AG500 amplitude data. Store as MAT files
% function pegelstats=filteramps(inpath,outpath,triallist,filterspecs,idownfac,usersensornames,usercomment,outpathraw)
% filteramps: Version 11.09.2012
%
%   Description
%       Filters raw AG500/AG501 amplitude data
%       Stores results as MAT file, adding standard variables
%		Optional output of stats on signal level
%
%	Syntax
%   `   filterspecs: Optional. If missing or empty, no filtering is carried
%			out
%			If present, must be m*2 cell array. In first column, name of mat file with
%			filter coefficients for FIR filter.
%			In second column, vector of channels to which the filter is to be
%			applied.
%			Any channels without a filter specification are copied unchanged but (with
%			downsampling, if specified).
%			Note: If the input data for any channel is considered too short too filter
%			(criterion: must be longer than the filter itself) then the output is set to NaNs
%			(rather than being passed unchanged)
%       inpath and outpath: Common part of filename without 4-digit trial
%			number (i.e. should normally be terminated by path character)
%			Calling program must create the subdirectory for output.
%			Normally the lowest-level subdirectories for input and output
%			should be named 'amps' (also for outpathraw, if used; see
%			below)
%       idownfac: Optional. Downsampling factor. Defaults to 1
%       usersensornames: Optional. List of sensor names to replace default
%			names (string matrix with 12 rows)
%       usercomment: Optional. Free comment to place in comment variable
%		outpathraw: Optional. Output also as raw binary .amp files as used by Carstens calcpos		
%			A small mat file info.mat is also created, containing
%			sensornames, samplerate and comment, for use as input to
%			rawpos2mat
%       pegelstats: Optional output argument. Contains max, min and
%			maxabsdiff of overall signal level. Rows correspond to the entries
%			in triallist (will be set to NaN if not enough data to filter)
%
%   Updates
%       2.08    Include output argument with information on overall signal level
%               Improve handling of MAT files as input
%		3.10    No filtering if data length not longer than filter length
%		3.10    Pegelstats also set to NaN for channels with not enough data
%               to filter
%		8.10    Allow optional raw output (for use with calcpos)
%       2.12    Handle AG501 amp files
%       9.2012  Assume AG501 amp files have header (also when storing raw amps). 
%
%   See Also
%       LOADAMP, SAVEAMP3, READAGHEADER, WRITEAGHEADER

functionname='filteramps: Version 11.09.2012';

ampext='.amp';      %needed for reading timestamp, and for raw amp output

%If mat file input will be taken from mat file
%If raw amp files should eventually allow to be overridden by input
%argument
sampleratedef=200;     %from 9.2012 not really needed, as loadamp should return appropriate samplerate

maxchan=24;         %get from first amp file??

ndig=4;

myver=version;

saveop='';
if myver(1)~='6' saveop='-v6'; end;

idown=1;
if nargin>5 if ~isempty(idownfac) idown=idownfac; end; end;

%should check if appropriate for AG501
ampfac=2500;        %scaling factor for amplitude stats
nstats=3;
ntrial=length(triallist);
statsbuf=ones(ntrial,nstats,maxchan)*NaN;




filterspec=[];
if nargin>4 filterspec=filterspecs; end;



cofbuf=cell(maxchan,1);
filtername=cell(maxchan,1);
filtercomment=cell(maxchan,1);
filtern=zeros(maxchan,1);

nfrow=size(filterspec,1);

for ifi=1:nfrow
	tmpname=filterspec{ifi,1};
	fchan=filterspec{ifi,2};
	mycoffs=mymatin(tmpname,'data');
	mycomment=mymatin(tmpname,'comment');
	myn=length(mycoffs);
	nc=length(fchan);
	for ific=1:nc
		mychan=fchan(ific);
		cofbuf{mychan}=mycoffs;
		filtername{mychan}=tmpname;
		filtercomment{mychan}=mycomment;
		filtern(mychan)=myn;
	end;
end;

sensornames='';
newnames=0;
if nargin>5
	%If mat input existing sensornames will be used, unless new names have
	%been specified

	sensornames=usersensornames;
	newnames=1;
end;


addcomment='';
if nargin>6 addcomment=usercomment; end;




newcomment=['Input, Output : ' inpath ' ' outpath crlf ...
	'First/last/n trials: ' int2str([triallist(1) triallist(end) length(triallist)]) crlf];

myblanks=(blanks(maxchan))';
filtercomment=strcat(int2str((1:maxchan)'),' File: ',filtername,' " ',filtercomment,' ", ncof = ',int2str(filtern));
newcomment=[newcomment 'Filter specs for each channel:' crlf strm2rv(char(filtercomment),crlf) crlf];

rawout='';
if nargin>7 rawout=outpathraw; end;


for iti=1:ntrial
	itrial=triallist(iti);
	disp(itrial);
	%maybe check if already mat file???
	matinp=0;
	extuse=ampext;
	samplerate=sampleratedef;
	matcomment='';
	inname=[inpath int2str0(itrial,ndig)];
	if exist([inname '.mat'],'file')
		matinp=1;
		extuse='.mat';
%		samplerate=mymatin(inname,'samplerate');        %9.2012, via loadamp 
		matcomment=mymatin(inname,'comment','<No comment in input MAT file>');
	end;



	[data,S]=loadamp(inname);
	if ~isempty(data)
		ndim=size(data,2);
		nsensor=size(data,3);
		ndatin=size(data,1);
		ndat=length(1:idown:ndatin);      %assume decifir behaves like this
		dataout=ones(ndat,ndim,nsensor)*NaN;
        if isfield(S,'samplerate')
            samplerate=S.samplerate;
        end;

	samplerate=samplerate/idown;
%2.2012 allow for ag500/ag501 differences
        [descriptor,unit,dimension]=headervariables(1,sensornames,[ndim nsensor]);
        
        
		dirtmp=dir([inname extuse]);
		timestamp=['Timestamp of ' extuse ' input file : '];
		if ~isempty(dirtmp)
			timestamp=[timestamp dirtmp(1).date];
		end;

		comment=[newcomment timestamp crlf 'Comment: ' crlf addcomment crlf];

		if matinp
			matcomment=framecomment(matcomment,'Comment in input MAT file');
		end;

		comment=[comment crlf matcomment];

		comment=framecomment(comment,functionname);

		for isensor=1:nsensor
			tmpdata=data(:,1:ndim,isensor);
			pegel=eucdistn(tmpdata,zeros(size(tmpdata)));
			statsbuf(iti,:,isensor)=[max(pegel) min(pegel) max(abs(diff(pegel)))];

			if filtern(isensor)
				mycoff=cofbuf{isensor};
				ncof=length(mycoff);
				%The criterion here for having enough data to filter is more stringent than
				%that used by decifir
				if ndatin>ncof
					for idim=1:ndim
						%maybe allow for upsampling (interpolation???)
						dataout(:,idim,isensor)=decifir(mycoff,data(:,idim,isensor),idown);
					end;
				else
					disp(['Sensor ' int2str(isensor) ' : Not enough data for filtering']);
					disp('Output amps and pegelstats will be set to NaNs');
					statsbuf(iti,:,isensor)=NaN;
				end;


			else
				dataout(:,:,isensor)=data(1:idown:end,:,isensor);
			end;

		end;

		data=single(dataout);
		outname=[outpath int2str0(itrial,ndig)];
        if isfield(S,'private')
            if isfield(private,'filteramps')
                private.filteramps.filteramps=private.filteramps;
            end;
        end;
        private.filteramps.filterspec=filterspec;
        if isfield(S,'header')
            private.filteramps.loadampheader=S.header;
        end;
        
        
		if matinp
			copyfile([inname '.mat'],[outname '.mat']);
			save(outname,'data','comment','samplerate','private','-append',saveop);
			if newnames
				save(outname,'dimension','-append',saveop);
			end;

		else

			save(outname,'data','samplerate','descriptor','unit','dimension','comment','private',saveop);
		end;
		if ~isempty(rawout)
%9.2012. once AG501 header format has stabilized it may be possible to
%include further information, which could be transferred in turn to the pos
%file by calcpos
            SO.samplerate=samplerate;
			rawampout=[rawout int2str0(itrial,ndig) ampext];
			saveamp3(rawampout,data,SO);
		end;
		
			
	else
		disp('No data?');
	end;


end;

if ~isempty(rawout)
    ntrans=ndim;
    nchan=nsensor; %could also be got from size(sensornames,1)
	save([rawout 'info'],'sensornames','samplerate','comment','ntrans','nchan','private');
end;

if nargout pegelstats=statsbuf; end;
