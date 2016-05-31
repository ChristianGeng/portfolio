function mtsigcalc(cutname,recpath,reftrial,reclist,exportname,calcstr,newdescrip,newunit,newsamplerate);
% MTSIGCALC Calculate new signals from arithmetic operations on existing signals
% function mtsigcalc(cutname,recpath,reftrial,reclist,exportname,calcstr,newdescrip,newunit,newsamplerate);
% mtsigcalc: Version 11.11.2010
%
%	Purpose
%		Typical use is to compute new signals from weighted combinations of old signals
%		e.g intrinsic tongue from measured tongue - measured jaw
%		or signals defined by factor analysis etc.
%
%	Syntax
%
%		cutname:
%			cut file; segment data not used. All trials occurring in the cut file are processed
%
%		recpath: 
%			actually the common part of the REC file names
%
%		reftrial:
%			number of typical trial, as string. e.g. "001"
%
%		reclist:
%			string matrix specifying mat files, descriptors, and (optionally) internal names of signals to be processed. 
%			Same usage as when calling MTNEW.
%			See mt_ssig for syntax
%
%		exportname:
%			name of output matfiles is generated from recpath plus exportname (plus trial number)
%
%		calcstr
%			A string matrix. Each row defines the arithmetic operations to generate one new signal
%			Signals are referred to as if they are variables, using the names defined in reclist.
%			There is virtually no restriction on the calculations performed since the specifications
%			in calcstr can refer to any function m-file (e.g 'audio-mean(audio)')
%			Exception: If there is only one row, then the result of the operation can be an m*n matrix
%			of n new signals and where m equals the length of the old signals
%
%		newdescrip and newunit
%			string matrices giving the descriptors and units of the new signals
%			normally should have same number of rows as calcstr except for the special case of matrix output noted above
%
%       newsamplerate
%           Optional. Samplerate of output signal
%           Needed in cases where the processing changes the data-rate of
%           the signals.
%           Use with care. i.e make sure this specification matches the
%           effect of any specifications for the processing.
%           If this option is used the program will estimate the change in
%           datarate after processing the first trial, and wait for
%           confirmation before continuing.
%
%	Remarks
%		Calculations should result in new signals that are exactly the same length as the old signals,
%           unless the newsamplerate argument is explicitly used
%		Processing should not change t0
%		Calling program should delete all figures after termination
%		Based on mtvelo
%		
%
%	See Also
%		MTVELO	Specifically designed for filtering, derivatives, and downsampling
%		MTCALC Provides the interface to the matlab eval function
%
%	Updates
%		12.09 Allow vector data (e.g spectra) and in theory other
%		multidimensional data to be processed. Assumes the function
%		evaluated by mt_calc knows how to handle the data

myversion=version;
diary on;
functionname='Mtsigcalc: Version 11.11.2010';
disp (functionname);

diary off;
ncut=mt_org(cutname,recpath,reftrial);
diary on;
mt_ssig(reclist);

signal_list=mt_gcsid('signal_list');

nchan=size(signal_list,1);	%should be same as reclist

trialnums=mt_gcufd('trial_number');
trialnums=unique(trialnums);
ntrial=length(trialnums);


reftrialdig=length(reftrial);	%number of digits for trial in mat file name


sf=mt_gsigv(signal_list,'samplerate');
sampinc=1./sf(1);
samplerate=sf(1);		%check all channels same, if not program will crash

samplerateold=samplerate;       %may not actually be needed
newsr=0;
srchecked=1;
if nargin>8
    newsr=1;
    srchecked=0;        %check done after processing first trial
    samplerate=newsamplerate;
end;

ncalc=size(calcstr,1);

namestr=['Cut file name: ' cutname crlf];
namestr=[namestr 'Signal file path: ' recpath crlf];
namestr=[namestr 'Signal files: ' strm2rv(reclist,' ') crlf];
namestr=[namestr 'Signal calculation specs:' crlf];
namestr=[namestr strm2rv(calcstr) crlf];

%3.98
%get comment from mat file of 1st signal, and first trial
tempname=[recpath mt_gsigv(signal_list(1,:),'mat_name') reftrial];

reccomment=mymatin(tempname,'comment','<No comment>');

namestr=[namestr '==============================' crlf];
namestr=[namestr 'Comment from mat file of first signal ' tempname crlf];
namestr=[namestr '==============================' crlf];
namestr=[namestr reccomment crlf];


comment=namestr;
comment=framecomment(comment,functionname);


diary off;

%main loop, thru trials
for itrialx=1:ntrial
    itrial=trialnums(itrialx);	%may be missing trials
    
    mt_loadt(itrial);
    
    drawnow;
    dsize=mt_gsigv(signal_list(1,:),'data_size');
	timedim=1;
	mat_col=mt_gsigv(signal_list(1,:),'mat_column');
	if mat_col==0 timedim=length(dsize); end;
	
	
%	dsize=dsize(1);		%will this always be correct????
	dsize=dsize(timedim);
    %read data
    
    
    
    for jd=1:ncalc
        xx=mt_calc(deblank(calcstr(jd,:)));
        
        %this fiddling around allows matrix result as special case when only one analysis is
        %	being performed
        if jd==1
            if ncalc==1
                data=xx;
            else
                data=ones(length(xx),ncalc)*NaN;
            end;
        end;
        if ncalc>1
            data(:,jd)=xx;
        end;
    end;
    
    
    newsize=size(data,1);
    
    if ~newsr
        if newsize~=dsize
            disp('Unexpected length of new data???')
            keyboard;
            return;
        end;
    else
        estimatedsr=samplerateold*(newsize/dsize);
        disp(['Estimated new sample rate : ' num2str(estimatedsr)]);
        if ~srchecked
            disp(['Specified new sample rate : ' num2str(samplerate)]);
            disp('Type "return" to continue');
            keyboard;
            srchecked=1;        %only do first time
        end;
    end;
    
    
    if size(data,2)~=size(newdescrip,1)
        disp('Unexpected number of columns in new data');
        keyboard;
    end;
    
    
    item_id=deblank(mt_gtrid('label'));
    numbstr=int2str0(itrial,reftrialdig);
    
    %assume t0 same for all sigs, and not changed by calculations
    t0=mt_gsigv(signal_list(1,:),'t0');
    
    descriptor=newdescrip;
    unit=newunit;
    eval (['save ' recpath exportname numbstr ' data descriptor unit samplerate comment item_id t0']);
end;


delete(mt_gfigh('mt_organization'));
delete(mt_gfigh('mt_f(t)'));

colordef white
