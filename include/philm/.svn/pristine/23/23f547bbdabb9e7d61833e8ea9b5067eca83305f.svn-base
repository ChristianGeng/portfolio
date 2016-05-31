function eucdistpatindex(epgfile,triallist,myweights,selectv,indexlist,normflag,outsuffix,outdescriptor,outunit)
% EUCDISTPATINDEX Euclidean distances from reference patterns, with index calculation
% function eucdistpatindex(epgfile,triallist,myweights,selectv,indexlist,outsuffix,outdescriptor,outunit)
% eucdistpatindex: Version 27.03.10
%
%   Description
%       epgfile: File name without the digits defining the trial number
%			The input data must be arranged like spectral or EPG data with
%			each column defining a data vector, and time proceeding across
%			columns
%			(possible future enhancement: automatically detect spread-sheet style
%			(data vector across columns, time down rows)
%       triallist: Vector of trial numbers
%       myweights: Defines a set of n reference vectors with which the
%			input data is compared at each time slice (i.e euclidean distance
%			is calculated)
%		selectv: The number of rows of myweights must match the length of
%			the input vectors. However, calculation can be confined to a a
%			portion of the data by specifying a set of indices here.
%			If empty, the complete vector is used. (Future enhancements:
%			selectv is a cell array with separate set of indices for each
%			reference vector (e.g to compare with different regions of the
%			spectrum))
%		indexlist: If not empty must define a pair of columns in myweights.
%			An index of the relative position of each input data vector
%			relative to the two reference vectors is then calculated, such
%			that zero distance from reference 1 gives an index value of 1,
%			and zero distance from reference 2 gives an index value of -1
%			(i.e 0 indicates midway between the two).
%			In addition a normalized distance is calculated indicating how
%			close the data vector is to a straight line joining reference 1
%			and 2 in the multidimensional space: distance between the two references
%			divided by the sum of the distances from the data vector to the
%			two references. Finally, the product of the index and this
%			normalized distance is also stored. This normalized index value
%			will stay closer to zero for any pattern that does lot lie on
%			the path between reference 1 and 2.
%			indexlist can also be a matrix with multiple rows and two
%			columns, to define multiple indices
%		normflag: If true, mean is subtracted from reference and data
%			vectors before comparison (may be useful for spectral data where
%			changes in overall signal level are irrelevant). Note means are
%			calculated over the ranges definde by selectv
%       outsuffix:  Added to input file name to form output file name
%       outdescriptor: string matrix with n rows to name the
%                       output parameters. If indices are calculation these
%                       are named automatically from the component
%                       reference vectors
%       outunit:        Optional. Default is 'eucdist_' plus units of input data. If present, must also
%                           have n rows
%
%
%	See Also MTSIGCALC

functionname='eucdistpatindex: Version 27.03.10';

ndig=length(int2str(max(triallist)));

if size(myweights,1)==1 myweights=myweights'; end;
wsize=size(myweights);
if isempty(selectv) selectv=1:wsize(1); end;

nindex=0;
if ~isempty(indexlist)
	nindex=size(indexlist,1);
	if size(indexlist,2)~=2
		disp('bad index list');
		return
	end;
	if any(any(indexlist>wsize(2)))
		disp('bad index list');
		return;
	end;
end;



unit='';		%will normally be overwritten by input data



for itrial=triallist
	mytrials=int2str0(itrial,ndig);
	try
		load([epgfile mytrials]);

		%detect spreadsheet style data and transpose if necessary (what about
		%unit??
		epgsize=size(data);

		if epgsize(1)~=wsize(1)
			disp('eucdistpatindex: Weight vector is wrong size');
			return;
		end;

		nsamp=epgsize(2);
		npar=wsize(2);

		newdata=ones(nsamp,npar)*NaN;
		data=double(data);

		for ii=1:npar
			tmpweight=myweights(selectv,ii);
			tmpdata=data(selectv,:);
			if normflag
				tmpdata=tmpdata-repmat(mean(tmpdata),[length(tmpweight) 1]);
				tmpweight=tmpweight-mean(tmpweight);
			end;
			%            newdata(:,ii)=(sum(tmpdata.*repmat(tmpweight,[1 nsamp])))';
			newdata(:,ii)=eucdistn(tmpdata',repmat(tmpweight',[nsamp 1]));
		end;

		data=newdata;

		descriptor=outdescriptor;
		unit=repmat(['eucdist_' deblank(unit(1,:))],[npar 1]);
		if nargin>8 unit=outunit; end;

		%now handle index values
		for idi=1:nindex
			sumdist=data(:,indexlist(idi,2))+data(:,indexlist(idi,1));

			%zero if at ref2, 1 if at ref1
			tmpi=data(:,indexlist(idi,2))./sumdist;
			%map to range -1 +1
			tmpi=(tmpi-0.5)*2;
			tmpnor=eucdistn(myweights(:,indexlist(idi,1))',myweights(:,indexlist(idi,2))')./sumdist;
			data=[data tmpi tmpnor tmpi.*tmpnor];
			tmpdesc=[deblank(descriptor(indexlist(idi,1),:)) '_vs_' deblank(descriptor(indexlist(idi,2),:)) '_'];
			descriptor=str2mat(descriptor,[tmpdesc 'index'],[tmpdesc 'normdist'],[tmpdesc 'index_x_normdist']);
			unit=str2mat(unit,' ',' ',' ');
		end;




		private.eucdistpatindex.weights=myweights;
		private.eucdistpatindex.select=selectv;

		tmpcomment=['Input name: ' epgfile crlf 'First, last, n trial : ' int2str([triallist(1) triallist(end) length(triallist)]) crlf ...
			'Number of reference patterns: ' int2str(npar) crlf ...
			'Norm flag : ' int2str(normflag) crlf 'See private.eucdistpatindex for detailed settings' crlf];




		comment=framecomment([tmpcomment crlf comment],functionname);

		outfile=[epgfile outsuffix mytrials];
		disp(outfile);
		save(outfile,'data','samplerate','descriptor','unit','comment','private');

		if exist('item_id','var') save(outfile,'item_id','-append'); end;
		if exist('t0','var') save(outfile,'t0','-append'); end;

	catch
		disp(lasterr);
		disp(['No input file?' epgfile mytrials]);
	end;
end;
