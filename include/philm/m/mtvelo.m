function mtvelo(cutname,recpath,reftrial,reclist,exportname,ideriv,tangstr,myfilter,idown,preprocfunc);
% MTVELO Filter signals, compute derivatives and tangential derivatives
% function mtvelo(cutname,recpath,reftrial,reclist,exportname,ideriv,tangstr,myfilter,idown,preprocfunc);
% mtvelo: Version 02.11.2010
%
%	Purpose
%		Compute derivatives (0 to 5th) of input signal for complete trials. Also downsamples.
%		(similar to mulpva and mulsplice but uses new mt functions for access to signal mat files)
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
%			string matrix specifying mat files and descriptors of signals to be processed. 
%			See mt_ssig for syntax
%
%		exportname:
%			name of output matfiles is generated from recpath plus exportname (plus trial number)
%
%		=== Note: Following arguments are optional. Their default values can also be obtained
%						by setting them to empty ([]), e.g if you only want to specify one of the last
%						arguments explicitly
%		ideriv:
%			Optional. Order of time derivative to calculate. Defaults to 1 (i.e velocity). Range is 0 to 5
%				(use order 0 to e.g process signals by a smoothing filter)
%
%		tangstr:
%			Optional. String matrix specifying signals for which tangential velocity etc. is to be computed. 
%			This works as follows:
%			The function looks for all signals in reclist for which each entry
%			in tangstr forms a prefix. E.g reclist contains 'tbackx' and 'tbacky'
%			and tangstr contains 'tback'. After differentiation (if any) the function will
%			will then calculate sqrt(tbackx^2+tbacky^2).
%			This will also work for 3 (or more) dimensions. Also for 1 dimension
%			e.g reclist contains 'tbackx', tangstr='tbackx' --> sqrt(tbackx^2);
%			Note also combinations with nderiv:
%			e.g nderiv=0, reclist contains 'tbackx' and 'tbacky', tangstr='tback'
%			This will give distance of the tback sensor from the origin.
%
%		myfilter:
%			Optional. Defaults to "mf2010" (this mat file of filter coefficients must
%			then be available). This allows the user to specify an alternative filter to
%			the default one. Normally this should be a lowpass (smoothing) filter.
%			See note on algorithm below.
%
%		idown:
%			Optional. Downsampling factor (defaults to 1, i.e no downsampling)
%
%		preprocfunc
%			Optional. Function to apply to data before filtering, e.g 'abs'
%				should be simple functions that do not change the length of the data
%				and have only a single argument (the data itself)
%				For more complicated cases use mtsigcalc
%
%	Remarks
%		Calling program should delete all figures after termination
%		Function appends suffixes to descriptors of input signals, depending on order of derivative.
%			e.g 'V' for velocity. For zeroth derivative 'F' (for 'filtered') is appended.
%			For tangential derivatives first part of suffix is 'T'
%		Maximum order of derivative is currently set to 5, but this could easily be changed
%
%	Updates
%		4.97. version to use with mm_org setting up access to signal files
%		Raw integer output temporarily disabled
%		10.87 --re-enabled
%		2.98. Output comment variable standardized. descriptor and unit variables
%		generated and returned as output variables
%		10.2000 Downsampling included
%
%	Algorithm
%		The default or user-provided filter is 
%		convolved nderiv times with [0.5 0 -0.5] to get a differentiation filter
%		(with a small amount of additional smoothing)
%		The filtered data is multiplied by samplerate^nderiv to give data in units per second etc.

myversion=version;
diary on;
functionname='Mtvelo: Version 9.10.2000';
disp (functionname);
namestr=['<Start of Comment> ' functionname crlf];
if strcmp(myversion(1),'5')
   namestr=[namestr datestr(now,0) crlf];
end;
%       load the filter files and comments
velfilter='mf2010';
if nargin>7
   if ~isempty(myfilter)
      velfilter=myfilter;
   end;
end;


bv=mymatin(velfilter,'data');
bvcom=mymatin(velfilter,'comment','No comment in filter file');


filtercomment=['============' crlf];
filtercomment=[filtercomment 'Filter: ' velfilter '. Ncof ' int2str(length(bv)) crlf];
filtercomment=[filtercomment bvcom crlf];
filtercomment=[filtercomment '============' crlf];
%set up the filters
bd=[0.5 0 -0.5];

nderiv=1;
if nargin>5
   if ~isempty(ideriv)
      nderiv=ideriv;
   end;
end;


if nderiv>0
   for ii=1:nderiv
      bv=conv(bd,bv);
   end;
end;
nfilt=length(bv);




maxderiv=5;
if nderiv>maxderiv
   disp('nderiv too large')
   return
end;

deriv_suffixb=str2mat('F','V','A','J','DT4','DT5');
tang_suffixb=str2mat('ABS','TV','TA','TJ','TDT4','TDT5');
unit_suffixb=str2mat('','/s','/s2','/s3','/s4','/s5');

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
samplerated=samplerate^nderiv;
%filter time
filtertime=sampinc*nfilt;
disp (['Total filter length in samples: ' int2str(nfilt)]);


alldescrip=mt_gsigv(signal_list,'descriptor');
allunit=mt_gsigv(signal_list,'unit');


ndown=1;
if nargin>8 ndown=idown;end;
samplerate=samplerate/ndown;



mypfunc='';
if nargin>9 mypfunc=preprocfunc; end;




%setup tangential calculations
% check for inconsistent specs.
tangflag=0;
if nargin>6
   if ~isempty(tangstr)
      ntang=size(tangstr,1);
      tmp=zeros(ntang,1);
      for ii=1:ntang
         vv=strmatch(deblank(tangstr(ii,:)),alldescrip);
         tmp(ii)=length(vv);
      end;
      if any(tmp)
         if max(tmp)==min(tmp)
            tangflag=1;
            tangdim=max(tmp);
            tangcol=zeros(ntang,tangdim);
            for ii=1:ntang
               
               vv=strmatch(deblank(tangstr(ii,:)),alldescrip);
               tangcol(ii,:)=vv';
            end;
         end;
      end;
      if ~tangflag
         disp('Unexpected tangential signals???')
         disp(tangstr)
      end;
      
   end;
end;



%complete unit/descriptors for derivative
deriv_suffix=deblank(deriv_suffixb(nderiv+1,:));
tang_suffix=deblank(tang_suffixb(nderiv+1,:));
unit_suffix=deblank(unit_suffixb(nderiv+1,:));


ts=setstr(ones(nchan,1)*deriv_suffix);
descv=[alldescrip ts];

descriptor=descv;
%test for tangential velocity etc?????
if tangflag
   ts=setstr(ones(ntang,1)*tang_suffix);
   descv=[tangstr ts];
   
   descriptor=str2mat(descriptor,descv);
end;

descriptor=strmdebl(descriptor);

unitv=allunit;

if ~isempty(unit_suffix)
	ts=setstr(ones(nchan,1)*unit_suffix);
	unitv=[unitv ts];
end;

unit=unitv;
if tangflag unit=str2mat(unit,unitv(1:ntang,:)); end;        
unit=strmdebl(unit);


namestr=[namestr 'Cut file name: ' cutname crlf];
namestr=[namestr 'Signal file path: ' recpath crlf];
namestr=[namestr 'Signal files: ' strm2rv(reclist,' ') crlf];
namestr=[namestr 'Derivative order: ' int2str(nderiv) crlf];
if tangflag
   namestr=[namestr 'Number of dimensions for tangential derivatives: ' int2str(tangdim) crlf];
   namestr=[namestr 'Tangential derivative signals: ' strm2rv(tangstr,' ') crlf];
end;
if ndown>1
   namestr=[namestr 'Downsampling factor: ' int2str(ndown) crlf];
end;

if ~isempty(mypfunc)
   namestr=[namestr 'Pre-processing functon : ' mypfunc crlf];
end;



%3.98
%get comment from mat file of 1st signal, and first trial
tempname=[recpath mt_gsigv(signal_list(1,:),'mat_name') reftrial];


reccomment=mymatin(tempname,'comment','<No comment>');

namestr=[namestr '==============================' crlf];
namestr=[namestr 'Comment from mat file of first signal ' tempname crlf];
namestr=[namestr '==============================' crlf];
namestr=[namestr reccomment crlf];

namestr=[namestr filtercomment crlf];

namestr=[namestr '<End of Comment> ' functionname crlf];

comment=namestr;



diary off;

%main loop, thru trials
for itrialx=1:ntrial
   itrial=trialnums(itrialx);	%may be missing trials
   
   mt_loadt(itrial);
   
   drawnow;
   dsize=mt_gsigv(signal_list(1,:),'data_size');
   dsize=dsize(1);		%will this always be correct????
   %read data
   
   
   
   %get signal data and filter
   for jd=1:nchan
      [xx,actualtime]=mt_gdata(signal_list(jd,:));	%get whole trial
      
      if ~isempty(mypfunc)
         try
            eval(['xx=' mypfunc '(xx);']);
         catch
            disp('Problem with preprocessing function evaluation');
         end;
      end;
      
      xx=decifir(bv,xx,ndown)*samplerated;
      
      if jd==1 
         ndat=length(xx);
         data=zeros(ndat,nchan); 
      end;
      
      data(:,jd)=xx;
   end;
   
   %tangential velocities etc.
   if tangflag 
      tangbuf=zeros(ndat,ntang);
      for jd=1:ntang
         tangtmp=data(:,tangcol(jd,:));
         tangtmp=tangtmp.^2;
         tangbuf(:,jd)=sqrt((sum(tangtmp'))');
      end;
      
      
      data=[data tangbuf]; 
   end;
   
   item_id=deblank(mt_gtrid('label'));
   numbstr=int2str0(itrial,reftrialdig);
   
   t0=mt_gsigv(signal_list(1,:),'t0');
   
   eval (['save ' recpath exportname numbstr ' data descriptor unit samplerate comment item_id t0']);
end;


delete(mt_gfigh('mt_organization'));
delete(mt_gfigh('mt_f(t)'));

%mt_org changes this
colordef white;

