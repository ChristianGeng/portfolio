function tif2mat_trial_f(tifin,basename,synchfile,myset)
% TIF2MAT_TRIAL_F Load video images, deinterlace, store as MAT files
% function tif2mat_trial_f(tifin,basename,synchfile,myset)
% tif2mat_trial_f: Version 15.05.2013
%
%   Description
%       Each videoframe is deinterlaced (if ifirst > 0). The intermediate rows are restored by interpolation,
%		giving output data with images the same size as the input, but with
%		a frame rate of 50 images/s (assuming normal European standard of
%		25 video frames/s)
%       Requires a synch (segment) file, either from synch information on second
%           audio channel, or from segmenting the audio signal by hand.
%           Note: synch file not required if images already extracted on a
%           trial by trial basis.
%       Note: vertical dimension is flipped during processing, so first row in image has lowest
%           vertical coordinate. (Preferable if calibrated pixel dimensions are
%           available, and if coordinate measurements are to be made)
%       Extraction of corresponding audio data from long audio wav file
%           can also be carried out.
%       Summary of video processing steps (any given step is optional; see
%           details of settings below):
%           crop, gamma and contrast, convert to grayscale, deinterlace, flip
%           vertical dimension, resize, Wiener filtering, time filtering
%       Graphics: Raw unprocessed images are shown as they are read in.
%           At the end of processing the complete trial is shown roughly in
%           real time.
%
%	Syntax
%		The first 3 input arguments are compulsory
%		tifin: Common part of input tif file names. If empty, no video
%			processed (i.e can be used to run program just for extracting
%			audio)
%		basename: Common part of name of output mat files (video/audio
%			suffix and trial number is added)
%		synchfile: Segment file giving location of trials in the input data
%			stream
%           Alternatively, can be trial number of single trial to build
%           from images in tifin.
%		Remaining settings should be collected in a struct (input arg
%			myset) with the following fields:
%		ndig: 2-element vector giving number of digits in input tif files
%			and output mat files. Defaults to [4 4]. If length==1 use same
%			setting for both
%       imgtype: overrides default setting of 'tif'. Format must be
%           understandable to matlab's imread function.
%		videosuffix: Add to basename for video data. Defaults to '_v0_'
%       samplerateuse: Default to 25 (i.e. framerate before deinterlacing)
%           Needed for NTSC or empirically determined framerate using sync
%           brightup.
%		audioflag: 0 = no audio, 1= mat file, 2 = wav file. Default to no
%			audio. Note: mat file temporarily not supported.
%			If audioflag is a 2-element vector the second element specifies
%			the channel to extract (only one channel can extracted)
%		audioname
%			if audioflag~=0 then this field must contain the filename (without
%			extension) of the input audio data (default is to use tifin)
%		audiosuffix: Also only required if audioflag~0. Added to basename. Defaults to
%			'_av_'. Make sure resulting name does not collide with existing
%			audio mat files (e.g from Sony DAT or EX)
%			(further note on audio: the descriptor in the output audio mat
%			files is set to 'videoaudio')
%		audiosruse: Override the samplefrequency in the wav file
%			The nominal ratio of audio to video samplerate may not be completely accurate for
%			data from the mini-DV recorders. See getsyncfromwav for
%			more information.
%		colrange and rowrange: Specification for cropping the input images
%			(i.e vector of the columns or rows to extract from the input image)
%			Note: setup of cropping and choice of 1st or 2nd field first (see below) is based on
%			the image before it is flipped vertically, so these settings can be worked
%			out independently beforehand by examining one of the tif files.
%			Cropping is worth doing if possible as field interpolation is quite
%			slow.
%			n.b row range should be from odd number row to even number row (see
%			help of deinterlace)
%			If not specified, or empty, the full range is used.
%		ifirst: Specify whether first or second field in frame is earlier.
%			Default to 1. Set to 0 to skip de-interlacing
%		wienersize: If specified (and not empty) the images will be
%			smoothed by the wiener2 function from the image processing toolbox.
%			Must be a two-element vector specifying the neighbourhood size. See
%			help for wiener2 for details.
%			Note that the smoothing is carried out after de-interlacing and
%			resizing (see below).
%			May be useful as a primitive way of removing some of the fiber
%			structure in fiberoptic films.
%			Default is no smoothing.
%       resizefactor: argument to pass to imresize
%           Resizing by a factor of about 0.5 is also a simple way of
%           reducing some of the fiber structure in fiberendoscopic films (currently (03.2012)
%           fibers seem to be about 4 pixels apart), and also gives a big
%           reduction in output file size.
%           Note: resizing is done after de-interlacing but before any
%           Wiener filtering
%		timecoff: Vector of filter coefficients that is applied to the
%			image by treating each pixel as a time function.
%			After deinterlacing there often seems to be a fair bit of noise
%			at half the samplerate, i.e at 25Hz (for PAL).
%			This noise can be reduced by applying a smoothing filter in the
%			time domain.
%			Currently, only very short filters should be used, e.g
%			timecoff=[0.25 0.5 0.25];
%			Additional information available in the source code below.
%			Default is no smoothing.
%			Before activating any smoothing make sure the setting for
%			ifirst is correct. Otherwise results will be very strange!
%        gamma:
%               gamma value to be used by imadjust (defaults to 1, i.e. no
%               change)
%        imglimadj:
%               Passed as second argument to imadjust (low_in;high_in])
%               Use to increase image constrast. Values are given
%               normalized to 0..1.
%        note on gamma and imglimadj:
%           The normal imadjust syntax can be used to apply separate
%           adjustments to each color plane, if desired.
%       usercomment: Additional comment. Mainly for when no synch file is
%           in use
%       item_id: Only relevant when no synch file is used (the synch file automatically provides a
%           trial label)
%       t0adj: Adjustment that is ADDED to the t0 worked out by the program
%       colortype: 'truecolor' or 'grayscale' (default)
%           This determines the dimensionality of the output data.
%           If grayscale time is the third dimension
%           If truecolor time is the fourth dimension, and the third
%           dimension corresponds to the red/green/blue planes
%
%	Updates
%		7.10 first version with input arguments
%			Also start using random access capability of wavread, so very
%			long wav files no longer need being kept in memory
%       02.2012
%           Allow for different input formats.
%           Make it possible to use without synch file (i.e single trial is
%           extracted consisting of all images in input subdirectory)
%       03.2012
%           Prepare for truecolor output as option
%       05.2013
%           De-interlacing optional. Processing re-organized to make more
%           efficient use of memory (i.e. allow longer trials to be
%           processed)

%update 14.05.2013 change to using deinterlacep
%   use imlincomb to implement simple time filters

functionname='TIF2MAT_TRIAL_F. Version 15.05.2013';

graphok=1;
if get(0,'ScreenDepth')==0 graphok=0; end;

ndig=[4 4];
if isfield(myset,'ndig')
    tmpf=myset.ndig;
    if ~isempty(tmpf) ndig=tmpf;
    end;
end;
if length(ndig)==1 ndig=[ndig ndig]; end;
ndigin=ndig(1);
ndigout=ndig(2);


imgtype='tif';
if isfield(myset,'imgtype')
    tmpf=myset.imgtype;
    if ~isempty(tmpf) imgtype=tmpf; end;
end;

truecolflag=0;
nplaneout=1;
if isfield(myset,'colortype')
    tmpf=myset.colortype;
    if strcmp('truecolor',tmpf)
        truecolflag=1;
        nplaneout=3;
    end;
end;

resizefactor=1;
if isfield(myset,'resizefactor')
    tmpf=myset.resizefactor;
    if ~isempty(tmpf)
        resizefactor=tmpf;
    end;
end;



%could be any additional comment
%but mainly intended for use when not using synch file
usercomment='';
if isfield(myset,'usercomment')
    tmpf=myset.usercomment;
    if ~isempty(tmpf) usercomment=tmpf; end;
end;


videosuffix='_v0_';
if isfield(myset,'videosuffix')
    tmpf=myset.videosuffix;
    if ~isempty(tmpf) videosuffix=tmpf; end;
end;

outname=[basename videosuffix];


%Handle audio extraction
% 0 = no audio, 1= mat file, 2 = wav file
audioflag=0;

if isfield(myset,'audioflag')
    tmpf=myset.audioflag;
    if ~isempty(tmpf) audioflag=tmpf; end;
end;

audiochan=1;
if length(audioflag)==2 audiochan=audioflag(2); end;
audioflag=audioflag(1);
if audioflag
    
    %audioname='aa_fiber_audio_all_mono_22050';
    audioname=tifin;
    if isfield(myset,'audioname')
        tmpf=myset.audioname;
        if ~isempty(tmpf)	audioname=tmpf; end;
    end;
    
end;

audiosuffix='_av_';

if isfield(myset,'audiosuffix')
    tmpf=myset.audiosuffix;
    if ~isempty(tmpf) audiosuffix=tmpf; end;
end;



outnamea=[basename audiosuffix];


%If not specified in the input settings they will be set to full range
%below
colrange=[];
rowrange=[];
if isfield(myset,'colrange')
    colrange=myset.colrange;
end;
if isfield(myset,'rowrange')
    rowrange=myset.rowrange;
end;


%set for 1st or second field first
ifirst=1;

if isfield(myset,'ifirst')
    tmpf=myset.ifirst;
    if ~isempty(tmpf) ifirst=tmpf; end;
end;



%wienersize=[5 5];	%smoothing with Wiener filter (seems to be appropriate for fiberscope)
wienersize=[];		%no Wiener filtering
if isfield(myset,'wienersize')
    tmpf=myset.wienersize;
    if length(tmpf)==2
        wienersize=tmpf;
    else
        disp('If wienersize is specified it must have 2 elements');
        return;
    end;
end;
gamma=1;		%gamma adjustment
if isfield(myset,'gamma')
    tmpf=myset.gamma;
    if ~isempty(tmpf) gamma=tmpf; end;
end;

imglimadj=[];		%gamma adjustment
if isfield(myset,'imglimadj')
    tmpf=myset.imglimadj;
    if ~isempty(tmpf) imglimadj=tmpf; end;
end;


%coefficients for smoothing in time domain (see subfunction for details)
timecoff=[];			%no time filtering

if isfield(myset,'timecoff')
    timecoff=myset.timecoff;
end;




%set up other image adjust parameters....?????

sampleratein=25;
if isfield(myset,'samplerateuse')
    sampleratein=myset.samplerateuse;
end;
nfield=1;
samplerate=sampleratein;
if ifirst>0
    nfield=2;
    samplerate=sampleratein*2;  %after deinterlacing
end;

flipflag=1;


nosynch=0;
if ~ischar(synchfile)
    nosynch=synchfile;      %now the trial number
end;

if nosynch
    ntrial=1;
    synchdata=[0 0 0 nosynch]; %dummy record with trial number
    synchcomment='';    %use input field 'usercomment', if possible
    synchlabel='nolabel';
    if isfield(myset,'item_id')
        tmpf=myset.item_id;
        if ~isempty(tmpf) synchlabel=tmpf; end;
    end;
    
else
    
    load(synchfile);
    synchdata=data;
    synchlabel=label;
    synchcomment=comment;
    ntrial=size(synchdata,1);
    %ndigout=length(int2str(max(synchdata(:,4))));
end;


if ~isempty(tifin)
    flist=dir([tifin '*.' imgtype]);
    ntif=length(flist);
    if ntif<1
        disp('No data for this trial?');
        return;
    end;
    
    %ndigin=length(int2str(ntif));
    %assume tif images start from 1
    x=imread([tifin int2str0(1,ndigin) '.' imgtype]);
    nrowbase=size(x,1);ncolbase=size(x,2);
    
    %
    if isempty(colrange) colrange=1:ncolbase; end;
    if isempty(rowrange) rowrange=1:nrowbase; end;
end;


%convert synch times to tif image numbers
%As any audio is extracted at precisely the synch times (and other signals
%may be synchronized with it too)
% work out t0 value for the video data

framenums=round(synchdata(:,1:2)*sampleratein)+1;
if nosynch framenums=[1 ntif]; end;
frametime=(framenums-1)./sampleratein;
t0buf=frametime(:,1)-synchdata(:,1);

if isfield(myset,'t0adj')
    tmpf=myset.t0adj;
    if ~isempty(tmpf) t0buf=t0buf+tmpf; end;
end;

if audioflag
    if audioflag==1
        disp('temporarily unable to handle audio input from mat files');
        return;
        audiodata=mymatin(audioname,'data');
        audiosf=mymatin(audioname,'samplerate');
    end;
    if audioflag==2
        %disp('Reading audio data');
        %just read 1 sample to get samplerate
        [audiodata,audiosf,nbits]=wavread(audioname,1,'native');
        audiosize=wavread(audioname,'size');
        
        audiosfuse=audiosf;
        if isfield(myset,'audiosruse')
            audiosfuse=myset.audiosruse;
        end;
        
        disp('audio samplerate in file, audio samplerate used, n bits, n samples, n channels');
        disp([num2str([audiosf audiosfuse]) ' ' int2str([nbits audiosize])]);
        
        keyboard;
    end;
end;


for itrial=1:ntrial
    item_id=deblank(synchlabel(itrial,:));
    trialnum=synchdata(itrial,4);
    disp([int2str(itrial) ' ' int2str(trialnum) ' ' item_id]);
    disp('Frames');
    disp(framenums(itrial,:));
    if framenums(itrial,1)<1
        disp('Skipping this trial');
    else
        
        
        comment=['See private for full list of settings' crlf 'Wiener filter size : ' int2str(wienersize) crlf 'Length of time filter : ' int2str(length(timecoff)) crlf synchcomment crlf usercomment];
        comment=framecomment(comment,functionname);
        
        if ~isempty(tifin)
            
            nframe=framenums(itrial,2)-framenums(itrial,1)+1;
            
            %            data=repmat(uint8(0),[nrowbase ncolbase nplaneout nframe]);
            
            t0=t0buf(itrial);
            
            wasrgb=0;
            %            keyboard;
            irunf=1;        %pointer in main output buffer
            %            maxframe=0;
            for ii=1:nframe
                framen=framenums(itrial,1)+ii-1;
                %        ndigin=3;
                %        if framen>999 ndigin=4; end;
                myname=[tifin int2str0(framen,ndigin) '.' imgtype];
                if exist(myname,'file')
                    %                    maxframe=ii;
                    x=imread(myname);
                    
                    
                    if graphok
                        if ii==1
                            hi=image(x);
                            set(gcf,'colormap',gray(256));  %irrelevant if true color
                            set(hi,'erasemode','none');
                            truesize;
                            %activate keyboard to help with setting cropping, also imadjust parameters???
                            %    keyboard;
                            
                        else
                            set(hi,'cdata',x);
                            title(int2str(ii));
                            drawnow;
                        end;
                    end;
                    
                    
                    
                    
                    %image adjustments:
                    %crop
                    x=x(rowrange,colrange,:);
                    
                    %Adjustments done on all 3 color planes (if present), even if then converted to
                    %gray
                    
                    if (gamma~=1) | ~isempty(imglimadj)
                        x=imadjust(x,imglimadj,[],gamma);
                    end;
                    
                    if ndims(x)==3
                        if ~truecolflag
                            x=rgb2gray(x);
                            wasrgb=1;
                        end;
                    end;
                    
                    
                    if ifirst>0 x=deinterlacep(x,ifirst); end;
                    if flipflag x=flipdim(x,1); end;
                    for ififi=1:nfield
                        if ~truecolflag
                            xtmp=x(:,:,ififi);
                        else
                            xtmp=x(:,:,:,ififi);
                        end;
                        
                        if resizefactor~=1
                            xtmp=imresize(xtmp,resizefactor);
                        end;
            %some spatial smoothing with wiener filter
                        if ~isempty(wienersize)
%                disp('Wiener filtering');
                for iplane=1:nplaneout
                        datatmp=xtmp(:,:,iplane);
                        xtmp(:,:,iplane)=wiener2(datatmp,wienersize);
                end;
            end;
                        if irunf==1
                            nrow=size(xtmp,1);
                            ncol=size(xtmp,2);
                            data=repmat(uint8(0),[nrow ncol nplaneout nframe*nfield]);
                        end;
            
                        data(:,:,1:nplaneout,irunf)=xtmp;
                        irunf=irunf+1;
                    end;        %mini loop thru fields
                    
                    
                    
                else
                    disp([myname ' not found']);
                end;
                
            end;        %loop thru input frames
            nframe=nframe*nfield;
            
            %keyboard;
            
            
            
            %further examples of useful functions from the image processing toolbox
            %(possibly implemented more efficiently in deinterlace before
            %interpolating)
            %    x1=adapthisteq(x1,'NumTiles',[4 8]);
            
            %time filtering. Often seems useful for deinterlaced data
            %details are hard-coded in the subfunction
            if ~isempty(timecoff)
                ncoff=length(timecoff);
                if ncoff==3
                    ncoff2=ceil(ncoff/2);
                    ncoff21=ncoff2-1;
                    plist=1:ncoff
                disp('Time filtering, imlincomb');
                    for iframe=1:(nframe-ncoff2)
                        disp(iframe)
                        data(:,:,:,iframe)=imlincomb(timecoff(1),data(:,:,:,plist(1)),timecoff(2),data(:,:,:,plist(2)),timecoff(3),data(:,:,:,plist(3)));
                        plist=plist+1;
                    end;
                    data(:,:,:,(nframe-ncoff21):nframe)=[];
                    t0=t0+((1/samplerate)*ncoff21);
                    nframe=nframe-ncoff2;
                else
                    
                        
                    disp('Time filtering, old method');

                
                for iplane=1:nplaneout
                    data(:,:,iplane,:)=timefilt(squeeze(data(:,:,iplane,:)),timecoff);
                end;
                end;
                
            end;
            
            if graphok
                
                figure
                hi2=image(data(:,:,:,1));
                set(gcf,'colormap',gray(256));
                set(hi2,'erasemode','none')
                truesize(gcf);
                set(gca,'ydir','normal');
                for ii=1:nframe set(hi2,'cdata',data(:,:,:,ii)); pause(1/samplerate);drawnow; end;
            end;
            
            %keyboard;
            
            data=squeeze(data);        %remove singleton 3rd dimension for grayscale
            descriptor='VIDEO';
            
            descriptor='video_mono';
            if truecolflag descriptor='video_rgb'; end;
            if wasrgb
                descriptor='video_rgb2gray';
            end;
            
            unit='AD_Units';
            
            if ~truecolflag
                dimension.descriptor=str2mat('vertical','horizontal','time');
                dimension.unit=str2mat('pixel','pixel','s');
                axtmp=cell(3,1);
                axtmp{1}=1:nrow;
                axtmp{2}=1:ncol;
                axtmp{3}=(((1:nframe)-1)./samplerate)+t0;
            else
                dimension.descriptor=str2mat('vertical','horizontal','color','time');
                dimension.unit=str2mat('pixel','pixel','plane','s');
                axtmp=cell(4,1);
                axtmp{1}=1:nrow;
                axtmp{2}=1:ncol;
                axtmp{3}=str2mat('red','green','blue');
                axtmp{4}=(((1:nframe)-1)./samplerate)+t0;
                
                
            end;
            
            dimension.axis=axtmp;
            
            %do external dimension specification, e.g for use with show_x_1
            %allow for conversion to real units if scaling available
            
            dimension.external.descriptor=dimension.descriptor;
            
            dimension.external.unit=dimension.unit;
            tmp=dimension.axis;
            if truecolflag
                tmp1=tmp{1};
                tmp{1}=tmp1';
                %not sure how external dimension specification works for non-spatial
                %dimensions, i.e here for color
                tmp3=tmp{3};
                tmp3=ones(1,1,nplaneout);
                tmp3(:,:,:)=1:nplaneout;
                tmp{3}=tmp3;
                tmp4=ones(1,1,1,nframe);
                tmp4(1,1,1,1:nframe)=tmp{4};
                tmp{4}=tmp4;
            else
                tmp1=tmp{1};
                tmp{1}=tmp1';
                tmp3=ones(1,1,nframe);
                tmp3(1,1,1:nframe)=tmp{3};
                tmp{3}=tmp3;
                
                
            end;
            
            dimension.external.axis=tmp;
            
            
            
            
            private.tif2mat_trial_f=myset;
            save([outname int2str0(trialnum,ndigout)],'data','samplerate','descriptor','unit','item_id','comment','dimension','t0','private');
            
        end;		%tifin not empty
        
        if audioflag
            audionameout=[outnamea int2str0(trialnum,ndigout)];
            saveaudio(audionameout,audioname,synchdata(itrial,1:2),audiosfuse,audiochan,item_id,comment,private);
        end;
        
        close all;
    end;		%framenums in range
end;		%trial loop



function saveaudio(audionameout,audioname,atime,samplerate,audiochan,item_id,comment,private);

audiosamp=round(atime*samplerate)+1;

data=wavread(audioname,[audiosamp(1) audiosamp(2)],'native');
data=data(:,audiochan);

descriptor='videoaudio';
unit=' ';
save(audionameout,'data','samplerate','descriptor','unit','item_id','comment','private');

function data2=timefilt(data2,b)
%still worth doing some time filtering
%there usually seems to be appreciable noise at 25hz
% so in practice, after filtering, we don't get the full 25Hz bandwidth
% after deinterlacing

[nrow,ncol,nframe]=size(data2);

%coefficients must be set by calling program
%b=kaiserd(20,25,40,50);

%note: this causes a half-field (10ms) time shift (and first frame is
%rubbish)
%    b=[0.5 0.5];
%no time shift
%		b=[0.25 0.5 0.25];


slowfilt=0;

if slowfilt
    for jj=1:nrow
        %		disp([jj nrow]);
        for ll=1:ncol
            ff=double(squeeze(data2(jj,ll,:)));
            data2(jj,ll,:)=uint8(decifir(b,ff));
        end;
    end;
    
else
    
    %this is much quicker, but not recommended if using a longer filter
    %than the simple two or three point filter
    
    for ll=1:ncol
        %		disp([ll ncol]);
        x=squeeze(data2(:,ll,:));
        x=x';
        x=x(:);
        x=uint8(round(decifir(b,double(x))));
        x=reshape(x,[nframe nrow]);
        x=x';
        data2(:,ll,:)=x;
    end;
    
    
end;
