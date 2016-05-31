function mtsona2file(cutname,recpath,reftrial,reclist,exportname,cut_type,nfft,mywindow,noverlap,resamplefac,myfilter,lpcord);
% MTSONA2FILE Compute FFT sonagrams; store to mat file (1 per trial) in mt compatible format
% function mtsona2file(cutname,recpath,reftrial,reclist,exportname,cuttype,nfft,window,noverlap,resamplefac,myfilter,lpcord);
% mtsona2file: Version 27.11.2009
%
%	Syntax
%
%		cutname 
%			Cut file; only segment data corresponding to cuttype (see below) is used.
%			Warning if multiple target segments for same trial are found.
%
%		recpath
%			Actually the common part of the REC file names
%
%		reftrial
%			Number of typical trial, as string. e.g. "001"
%
%		reclist
%			String specifying mat file and descriptor of signal to be
%			processed, e.g 'ao.AUDIO'. See mt_ssig for full syntax
%
%		exportname
%			Name of output matfiles is generated from recpath plus exportname (plus trial number)
%
%		cut_type
%			Optional. Defaults to 0 (usually complete trial)
%
%		nfft
%			Optional. Same syntax as used by specgram. (Defaults to 256)
%
%		window
%			Optional. Same syntax as used by specgram BUT must be specified as a string
%			that can be passed to eval. (This is so the window used can be documented in
%			the comment of the output files)
%			(Default is nfft hanning)
%
%		noverlap
%			Optional. Same syntax as used by specgram (default is half window length)
%
%		resamplefac
%			Optional. Defaults to 1 (= no resampling). Should be expressible as a ratio of small integers.
%			See documentation of resample function (the default resample settings are used).
%			Note: nfft, window and noverlap arguments apply to the signal AFTER any resampling
%
%		myfilter
%			Optional. 2 different uses
%           (1) If numeric (default), passed as pre-emphasis flag to specgram_lpc.
%               0 (default) = no pre-emphasis, 1 = pre-emphasis calculated
%               separetely for each frame using first two autocorrelation
%               coefficients. (Other options may be available in future)
%           (2) If character, "myfilter" must be the name of a mat file containing a variable "data" with coefficients
%			for use as a FIR filter. Should also contain a variable "comment" describing the filter.
%			Note: This filtering is carried out AFTER any resampling as
%			specified below, and before passing the data to specgram_lpc.
%			If a filter is specified then no further pre-emphasis is
%			carried out
%			(If constant preemphasis is desired specify a filter with
%			coefficients of e.g [1 -1])
%
%		lpcord
%			Optional. If present then an lpc spectrum is computed using
%			abs(lpcord) as the lpc order
%			If present but empty then a default value is used: ceil(Fs/1000)+2
%				where Fs is the samplerate after any resampling.
%           If positive, formants are calculated and stored in the output
%           file (not the spectral slices)
%           If negative, lpc spectra are stored
%			If string:
%			currently only 'pmtm' possible, multitaper method for
%			spectral analysis is used (may be expanded in future to allow
%			optional arguments to be passed (and other psd methods)). 
%			Note: in this case pre-emphasis use of the filter argument is
%			ignored. window should not be specified (will be ignored
%			anyway)
%
%	Notes
%		If running version Matlab 5.3 or above, fft data is stored as single precision
%
%	See also
%		MT_SSIG DECIFIR SPECGRAM_LPC RESAMPLE

myversion=version;
diary on;
functionname='Mtsona2file: Version 27.11.2009';
disp (functionname);
namestr=['<Start of Comment> ' functionname crlf];
if strcmp(myversion(1),'5')
    namestr=[namestr datestr(now,0) crlf];
end;

%handle optional arguments
%=========================
if nargin>5
    cuttype=cut_type;
else
    cuttype=0;
end;
if isempty(cuttype) cuttype=0; end;

if nargin<7 nfft=256; end;

if nargin<8 mywindow=[];end;
windowstr=char(mywindow);
if ~isempty(mywindow)
    try
        mywindow=eval(windowstr);
	catch
        disp('Unable to evaluate window specification');
        return;
    end;
    windowlength=length(mywindow);
	
else
    windowlength=nfft;
end;

%keyboard;

if nargin<9 noverlap=[];end;

if nargin<10 resamplefac=1;end;
if isempty(resamplefac) resamplefac=1; end;



%handle pre-emphasise/filter specifications
preempflag=0;

%       load the filter files and comments
velfilter='';
nfilt=0;
if nargin>10
    if ~isempty(myfilter)
        if isnumeric(myfilter)
            preempflag=myfilter;
        else
            velfilter=myfilter;
            
        end;
    end;
end;

if ~isempty(velfilter)
    bv=mymatin(velfilter,'data');
    bvcom=mymatin(velfilter,'comment','No comment in filter file');
    
    
    filtercomment=['============' crlf];
    filtercomment=[filtercomment 'Filter: ' velfilter '. Ncof ' int2str(length(bv)) crlf];
    filtercomment=[filtercomment bvcom crlf];
    filtercomment=[filtercomment '============' crlf];
    nfilt=length(bv);
    
end;

dolpc=0;
domtm=0;
if nargin>11
	if ischar(lpcord)
		domtm=1;
	else
		
	lpcuse=lpcord;
    dolpc=1;
	end;
	
end;



if str2num(myversion(1))>5
    disp('mtsona2file: Note, data will be stored as single precision');
end;

diary off;
ncut=mt_org(cutname,recpath,reftrial);
diary on;
mt_ssig(reclist);

signal_list=mt_gcsid('signal_list');



nchan=size(signal_list,1);	%should be same as reclist

trialnums=mt_gcufd('trial_number');
trialnums=unique(trialnums);
ntrial=length(trialnums);

cutdata=mt_gcufd('data');
vc=find(cutdata(:,3)==cuttype);
cutdata=cutdata(vc,:);
%also label??

ncut=size(cutdata,1);
ntrial=length(unique(cutdata(:,4)));
if ntrial~=ncut
    disp('Multiple segments per trial?')
    disp([ncut ntrial]);
end;



reftrialdig=length(reftrial);	%number of digits for trial in mat file name


sf=mt_gsigv(signal_list,'samplerate');
sampleratein=sf(1);		%check all channels same, if not program will crash

%setup resample filter
%note: resample has also to  been modified to use a Fc at 0.95 * Nyquist
%(original was simply at Nyquist frequency)
if resamplefac~=1
    sampleratein=sampleratein*resamplefac;
    [rsp,rsq]=rat(resamplefac);
    %default for N is 10, so 40 makes filter 4 times as long
    [dodo,rsb]=resample_ph(ones(1000,1),rsp,rsq,40);
end;


halfwindowtime=(windowlength/sampleratein)/2;

if dolpc
    if isempty(lpcuse) lpcuse=ceil(sampleratein/1000)+2;end;
end;

alldescrip=mt_gsigv(signal_list,'descriptor');
allunit=mt_gsigv(signal_list,'unit');


descriptor=[alldescrip '_sona'];
if dolpc
    descriptor=[alldescrip '_lpc'];
end;

unit=['dB_' allunit];


dimension.descriptor=str2mat('Frequency','Time');
dimension.unit=str2mat('Hz','');
dimension.axis{1}=[];	%filled in below
dimension.axis{2}=[];	%time axis. No specification




namestr=[namestr 'Cut file name: ' cutname crlf];
namestr=[namestr 'Signal file path: ' recpath crlf];
namestr=[namestr 'Signal files: ' strm2rv(reclist,' ') crlf];


namestr=[namestr 'Cut type : ' int2str(cuttype) crlf];	%get cut_type_label????
%nfft maybe a vector
if length(nfft)==1
    namestr=[namestr 'Nfft : ' int2str(nfft) crlf];
else
    namestr=[namestr 'Frequency vector length  : ' int2str(length(nfft)) crlf];
end;   

namestr=[namestr 'Window specification: ' windowstr crlf];

namestr=[namestr 'n_overlap: ' int2str(noverlap) crlf];

if resamplefac~=1
    namestr=[namestr 'Resample factor: ' num2str(resamplefac) crlf];
    
end;

if dolpc
    namestr=[namestr 'LPC order: ' int2str(lpcuse) crlf];
    
end;
if domtm
    namestr=[namestr 'PSD function: ' lpcord crlf];
    
end;

namestr=[namestr 'Pre-emphasis mode : ' int2str(preempflag) crlf];

if nfilt
    namestr=[namestr filtercomment crlf];
end;



%3.98
%get comment from mat file of 1st signal, and first trial
tempname=[recpath mt_gsigv(signal_list(1,:),'mat_name') reftrial];


reccomment=mymatin(tempname,'comment','<No comment>');

namestr=[namestr '==============================' crlf];
namestr=[namestr 'Comment from mat file of first signal ' tempname crlf];
namestr=[namestr '==============================' crlf];
namestr=[namestr reccomment crlf];


namestr=[namestr '<End of Comment> ' functionname crlf];

comment=namestr;



diary off;

%main loop, thru trials
for icut=1:ncut
    curcut=cutdata(icut,:);
    itrial=curcut(4);
    
    loadflag=mt_loadt(itrial);
    if loadflag==0
        disp('Trial missing?')
    else
        drawnow;
        
        %get signal data and filter
        [xx,actualtime]=mt_gdata(signal_list,curcut(1:2));
        
        %resample??      
        if resamplefac~=1
            xx=resample(xx,rsp,rsq,rsb);
        end;
        
        %filter
        if nfilt
            xx=decifir(bv,xx);
            
        end; 
        
        %do fft
        if dolpc
            [yy,ff,tt]=specgram_lpc(xx,nfft,sampleratein,mywindow,noverlap,[preempflag lpcuse]);
            
            if lpcuse>1
                %compute formants
                fuse=5;     %or determined by lpcord if smaller?
                
                unit=repmat('Hz',[fuse*4 1]);
                fnums=int2str((1:fuse)');
                descriptor=str2mat(strcat('F',fnums),strcat('BW',fnums),strcat('FHI',fnums),strcat('FLO',fnums));
                
                
                nframe=length(tt);
                fbwbuf=ones(nframe,fuse*4)*NaN;
                for iframe=1:nframe
                    a=yy(:,iframe);
                    myroots=roots(a);
                    
                    myf=angle(myroots)*(sampleratein/(2*pi));
                    mybw=-log(abs(myroots))*(sampleratein/pi);
                    
                    myf2=myf;
                    mybw2=mybw;
                    
                    
                    %rough elimination of useless data
                    %Also eliminates the complex conjugate versions of the poles (they have negative frequencies)
                    flim=100;		%lower frequency limit
                    blim=1000;		%upper limit on bandwidth
                    vv=find((myf<flim)|(mybw>blim));
                    myf(vv)=NaN;
                    mybw(vv)=NaN;
                    
                    %sort by bandwidth
                    
                    [mybw,sortindex]=sort(mybw);
                    myf=myf(sortindex);
                    %keep resonances with smallest bandwidths
                    %may need to be more sophisticated
                    myf=myf(1:fuse);
                    mybw=mybw(1:fuse);
                    
                    %then sort by frequency
                    [myf,sortindex]=sort(myf);
                    
                    mybw=mybw(sortindex);
                    fhi=myf+mybw/2;
                    flo=myf-mybw/2;
                    %include fhi and flo in output (could be convenient for
                    %display) (also use to help eliminate further superfluous
                    %formants???)
                    fbwbuf(iframe,:)=[myf' mybw' fhi' flo'];
                    
                    
                end;
            end;
            
            
		else
			if domtm preempflag=lpcord; end;
			[yy,ff,tt]=specgram_lpc(xx,nfft,sampleratein,mywindow,noverlap,preempflag);
        end;   
        
        %workout output samplerate
        samplerate=1./mean(diff(tt));
        
        item_id=deblank(mt_gtrid('label'));
        numbstr=int2str0(itrial,reftrialdig);
        
        t0=actualtime(1)+tt(1)+halfwindowtime; %tt(1) should always be zero
        
        if dolpc
            data=fbwbuf;
            save([recpath exportname numbstr],'data','descriptor','unit','samplerate','comment','item_id','t0');
            
        else   
            %db conversion  
            

			ydb=abs(yy);
            data=20*log10(ydb+eps);
            
%consider postfiltering here?            
            
            
            dimension.axis{1}=ff;  
            
            
            %currently not really needed, but may be useful if using non-double output
            scalefactor=1;
            signalzero=0;
            
            %8.99 use single, from version 5.3
            %  if strcmp(myversion(1:3),'5.3')
            if str2num(myversion(1))>5
                data=single(data);
            end;
            
            eval (['save ' recpath exportname numbstr ' data descriptor unit samplerate comment item_id t0 dimension scalefactor signalzero']);
            
        end;
        
    end;        %trial missing
    
end;


delete(mt_gfigh('mt_organization'));
delete(mt_gfigh('mt_f(t)'));


