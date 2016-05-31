function epg_wsum(epgfile,triallist,myweights,outsuffix,outdescriptor,outunit)
% EPG_WSUM Weighted sum of EPG electrodes
% function epg_wsum(epgfile,triallist,myweights,outsuffix,outdescriptor,outunit)
% EPG_WSUM: Version 26.03.10
%
%   Description
%       epgfile: File name without the digits defining the trial number
%       triallist: Vector of trial numbers
%       myweights: Defines a vector of 64 weights to apply to the 64 EPG
%           electrodes. After weighting, the sum over the 64 electrodes is
%           calculated.
%			(Currently, EPG data is stored as a 64*nsamples array.
%           Details of the traditional assignment of the electrodes to rows and columns, possibly even to
%           actual geometrical position, is
%           contained in the dimension.external variable.)
%           Often (e.g to get row sums, centre of gravity etc.) one will think
%           of the 64 electrode positions as subdivided into the traditional 8
%           rows. Row 1 (front), for example, corresponds to the first 8 positions in
%           the vector. Thus, to get the sum of contacts in Row1 set the
%           first 8 elements of myweights to 1, and all other elements to
%           zero.
%           myweights can also be a 64*n matrix, to define n separate weighting
%           schemes.
%			Currently, there is no quick way to calculate centre of
%				gravity: i.e it is necessary to compute all the row sums here
%				(perhaps also total contacts) and then use e.g mt_sigcalc to
%				finish the job.
%			Special case: If any of the weights in a weight vector are
%				negative, then zeros (no contact) in the input data are 
%				converted to -1 before computing the weighted sum.
%				This is convenient when the weight vector is calculated as the
%				difference betwen two reference patterns. If the weights are
%				normalized by sum(abs(weights)) then the output signal ranges
%				from +1 to -1 (corresponding to the two patterns). 
%				This approach can also be used to get the match with a
%				single reference pattern. Assuming this consists of values
%				between 0 and 1 (e.g from averaging contact patterns for
%				some sound), then convert it to (2*refpat)-1 and normalize
%				it as above. Then output values of 1 correspond to a
%				perfect match, and -1 to no match (or a perfect match to
%				the inverse of the reference pattern: in effect the
%				weighting pattern is the difference between the reference
%				pattern and its inverse: refpat-(1-refpat) = (2*refpat)-1).
%       outsuffix:  Added to input file name to form output file name
%       outdescriptor: string matrix with n rows to name the
%                       output parameters
%       outunit:        Optional. Default is 'WSUM'. If present, must also
%                           have n rows
%
%	Notes
%		This function could be actually be used with any data (e.g spectral
%		data) where the signal forms the first dimension of the data
%		variable, and time is the second dimension (the signal vector can actually
%		be any length, i.e it does not have to be 64). Further note:
%		Non-EPG data should not, however, currently be used with negative
%		weights, because of the re-mapping of zero input to -1.
%
%   Updates
%       1.08 input data converted to double. More informative error
%       messages
%		12.08 Automatic difference patterns (i.e negative weights) 
%
%	See Also MTSIGCALC

functionname='EPG_WSUM: Version 26.03.10';

ndig=length(int2str(max(triallist)));

negweight=any(myweights<0);

if any(negweight)
	disp('EPG_WSUM note: Negative weights found. Input data 0 will be re-mapped to -1');
end;


for itrial=triallist
    mytrials=int2str0(itrial,ndig);
    try
        load([epgfile mytrials]);

        epgsize=size(data);

        wsize=size(myweights);
        if epgsize(1)~=wsize(1)
            myweights=myweights';
            wsize=size(myweights);
            if epgsize(1)~=wsize(1)
                disp('Weight vector is wrong size');
                return;
            end;
        end;

        nsamp=epgsize(2);
        npar=wsize(2);

        newdata=zeros(nsamp,npar);
		data=double(data);

        for ii=1:npar
			tmpweight=myweights(:,ii);
			tmpdata=data;
%if any weights are negative, map 0 (no contact) to -1
			if any(tmpweight<0)
				tmpdata(tmpdata==0)=-1;
			end;
			
            newdata(:,ii)=(sum(tmpdata.*repmat(tmpweight,[1 nsamp])))';
        end;

        data=newdata;

        descriptor=outdescriptor;
        unit=repmat('WSUM',[npar 1]);
        if nargin>5 unit=outunit; end;

        private.epg_weights=myweights;

	tmpcomment=['Input name: ' epgfile crlf 'First, last, n trial : ' int2str([triallist(1) triallist(end) length(triallist)]) crlf ...
		'Number of weighting patterns: ' int2str(npar) crlf 'See private.epg_weights for full patterns' crlf];

	if any(negweight)
		tmpcomment=[tmpcomment 'Negative weight status for weight vectors : ' int2str(negweight) crlf];
	end;
	
	comment=framecomment([tmpcomment crlf comment],functionname);
		
		outfile=[epgfile outsuffix mytrials];
        disp(outfile);
        save(outfile,'data','samplerate','descriptor','unit','comment','private');

        if exist('item_id','var') save(outfile,'item_id','-append'); end;
        if exist('t0','var') save(outfile,'t0','-append'); end;

    catch
        disp(lasterr);
        disp(['No EPG input file?' epgfile mytrials]);
    end;
end;
