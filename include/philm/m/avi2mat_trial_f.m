function avi2mat_trial_f(tifin,basename,synchfile,myset)
% AVI2MAT_TRIAL_F Load video tif images, deinterlace, store as MAT files
% function avi2mat_trial_f(tifin,basename,synchfile,myset)
% avi2mat_trial_f: Version 12.08.2010
%
%   Description
%		Based on tif2mat_trial_f. Some input settings are relicts of this.
%       Each videoframe is deinterlaced. The intermediate rows are restored by interpolation,
%		giving output data with images the same size as the input, but with
%		a frame rate of 50 images/s (assuming normal European standard of
%		25 video frames/s)
%       Requires a synch (segment) file, either from synch information on second
%           audio channel, or from segmenting the audio signal by hand
%       Note: vertical dimension is flipped during deinterlacing, so first row in image has lowest
%           vertical coordinate. (Preferable if calibrated pixel dimensions are
%           available, and if coordinate measurements are to be made)
%       Extraction of corresponding audio data from long audio wav file
%           can also be carried out.
%           If so, it will be necessary to use a program like DAT2MAT_II instead
%
%	Syntax
%		The first 3 input arguments are compulsory
%		tifin: Common part of input tif file names. If empty, no video
%			processed (i.e can be used to run program just for extracting
%			audio) [for avi version must be present, although not actually
%			used (may be retained to allow debugging/cross-checks with tif
%			input)]
%		basename: Common part of name of output mat files (video/audio
%			suffix and trial number is added)
%		synchfile: Segment file giving location of trials in the input data
%			stream
%		Remaining settings should be collected in a struct (input arg
%			myset) with the following fields:
%		avihandle: For avi version must be present. Access to the avi file
%			must be set up by the calling program. Precise contents of this
%			field will depend on the actual package used for reading avi files
%			(currently videoio).
%			Note also that the functions required for avi access must be on
%			matlab's path. This must also be done by the calling program.
%		ndig: 2-element vector giving number of digits in input tif files
%			and output mat files. Defaults to [4 4]. If length==1 use same
%			setting for both [for avi version first element is not actually
%			used]
%		videosuffix: Add to basename for video data. Defaults to '_v0_'
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
%			Default to 1
%		wienersize: If specified (and not empty) the images will be
%			smoothed by the wiener2 function from the image processing toolbox.
%			Must be a two-element vector specifying the neighbourhood size. See
%			help for wiener2 for details.
%			Note that the smoothing is carried out after de-interlacing and
%			interpolation (which is not computationally very efficient)
%			May be useful as a primitive way of removing some of the fiber
%			structure in fiberoptic films.
%			Default is no smoothing.
%		timecoff: Vector of filter coefficients that is applied to the
%			image by treating each pixel as a time function.
%			After deinterlacing there often seems to be a fair bit of noise
%			at half the samplerate, i.e at 25Hz.
%			This noise can be reduced by applying a smoothing filter in the
%			time domain.
%			Currently, only very short filters should be used, e.g
%			timecoff=[0.25 0.5 0.25];
%			Additional information available in the source code below.
%			Default is no smoothing
%			Before activating any smoothing make sure the setting for
%			ifirst is correct. Otherwise results will be very strange!
%
%	Updates
%		7.10 first version with input arguments
%			Also start using random access capability of wavread, so very
%			long wav files no longer need being kept in memory
%
%	See Also TIF2MAT_TRIAL_F Earlier version using individual tif files as
%		input

functionname='AVI2MAT_TRIAL_F. Version 12.08.10';

ndig=[4 4];
if isfield(myset,'ndig')
    tmpf=myset.ndig;
    if ~isempty(tmpf) ndig=tmpf;
    end;
end;
if length(ndig)==1 ndig=[ndig ndig]; end;
ndigin=ndig(1);
ndigout=ndig(2);

%tifin='tiffall\aa_all ';
%basename='mat\parisfiber1_aa1';
%synchfile='parisfiber1_aa1_cut';

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


%coefficients for smoothing in time domain (see subfunction for details)
timecoff=[];			%no time filtering

if isfield(myset,'timecoff')
    timecoff=myset.timecoff;
end;




%set up other image adjust parameters....?????
%might be better to get initially from the aviinfo, but allow to be overridden by
%user
sampleratein=25;
samplerate=sampleratein*2;  %after deinterlacing

load(synchfile);
synchdata=data;
synchlabel=label;
synchcomment=comment;
ntrial=size(synchdata,1);
%ndigout=length(int2str(max(synchdata(:,4))));

%tifin must be specified, even if not actually used
if ~isempty(tifin)
%    flist=dir([tifin '*.tif']);
%    ntif=length(flist);

    %ndigin=length(int2str(ntif));
    %assume tif images start from 1

    avi_hdl=myset.avihandle;
	%for videoio the handle actually contains the reference to the video read object
	%and this causes a warning when the mat file is subsequently loaded
	%because the object class is not known
	myset=rmfield(myset,'avihandle');	
	
    myavi=myset.aviinfo.aviread;	%aviinfo now has structs from both aviinfo and videoio


%    xtif=imread([tifin int2str0(1,ndigin) '.tif']);
    nrowbase=myavi.Height;ncolbase=myavi.Width;

    %
    if isempty(colrange) colrange=1:ncolbase; end;
    if isempty(rowrange) rowrange=1:nrowbase; end;
end;


%convert synch times to tif image numbers
%As any audio is extracted at precisely the synch times (and other signals
%may be synchronized with it too)
% work out t0 value for the video data

%note: these framenums are 1-base. videoio uses 0-based (see below)
framenums=round(synchdata(:,1:2)*sampleratein)+1;
frametime=(framenums-1)./sampleratein;
t0buf=frametime(:,1)-synchdata(:,1);

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
%for itrial=304:ntrial
    item_id=deblank(label(itrial,:));
    trialnum=synchdata(itrial,4);
    disp([int2str(itrial) ' ' int2str(trialnum) ' ' item_id]);
    disp('Frames');
    disp(framenums(itrial,:));
%note videoio may not actually allow access to the last few frames
	if (framenums(itrial,1)<1) | (framenums(itrial,2)>myavi.NumFrames)
        disp('Skipping this trial (frame out of range)');
    else

        comment=['Wiener filter size : ' int2str(wienersize) crlf 'Length of time filter : ' int2str(length(timecoff)) crlf synchcomment];
        comment=framecomment(comment,functionname);

        if ~isempty(tifin)

            nframe=framenums(itrial,2)-framenums(itrial,1)+1;

            data=repmat(uint8(0),[nrowbase ncolbase nframe]);
%            data0=repmat(uint8(0),[size(xtif,1) size(xtif,2) nframe]);

            t0=t0buf(itrial);

            wasrgb=0;
			frame0=framenums(itrial,1)-1;
			seekok=seek(avi_hdl,frame0);
				if ~seekok
					disp(['videoread seek error at frame ' int2str(frame0)]);
				end;
			for ii=1:nframe
%                framen=framenums(itrial,1)+ii-1;
                %        ndigin=3;
                %        if framen>999 ndigin=4; end;

				x=getframe(avi_hdl);
%should check for errors
				nextok=next(avi_hdl);
				if ~nextok
					disp(['videoread next error at frame ' int2str(frame0+ii)]);
				end;
				
%                x = dxAviReadMex(avi_hdl, framen);
%                x=reshape(uint8(x),[nrowbase,ncolbase,3]);

%                		x0=imread([tifin int2str0(framen,ndigin) '.tif']);
                if ndims(x)==3
                    x=rgb2gray(x);
                    wasrgb=1;
                end;
%keyboard;
                data(:,:,ii)=x;
%                data0(:,:,ii)=x0;
            end;
            hi=image(data(:,:,1));
            set(gcf,'colormap',gray(256));
            set(hi,'erasemode','none');
            truesize;
 %           figure;
 %           hi0=image(data0(:,:,1));
 %           set(gcf,'colormap',gray(256));
 %           set(hi0,'erasemode','none');
 %           truesize;
            %activate keyboard to help with setting cropping, also imadjust parameters???
 %               keyboard;

            for ii=1:nframe 
                set(hi,'cdata',data(:,:,ii)); 
  %              set(hi0,'cdata',data0(:,:,ii)); 
                
                drawnow;
                pause(1/sampleratein);
            end;

%            keyboard;
            %cropping
            data=data(rowrange,colrange,:);

            %imadjust here, if desired??

            flipflag=1;
            disp('Deinterlacing');
            data2=deinterlace(data,ifirst,flipflag);

            nrow=size(data2,1);ncol=size(data2,2);
            nframe=size(data2,3);

            %examples of useful functions from the image processing toolbox
            %could be implemented more efficiently in deinterlace before
            %interpolating
            %    x1=adapthisteq(x1,'NumTiles',[4 8]);
            %some spatial smoothing with wiener filter
            if ~isempty(wienersize)
                disp('Wiener filtering');
                for ii=1:nframe
                    data2(:,:,ii)=wiener2(data2(:,:,ii),wienersize);
                end;
            end;

            %time filtering. Often seems useful for deinterlaced data
            %details are hard-coded in the subfunction
            if ~isempty(timecoff)
                disp('Time filtering');
                data2=timefilt(data2,timecoff);
            end;


            figure
            hi2=image(data2(:,:,1));
            set(gcf,'colormap',gray(256));
            set(hi2,'erasemode','none')
            truesize(gcf);
            set(gca,'ydir','normal');
            for ii=1:nframe set(hi2,'cdata',data2(:,:,ii)); pause(1/samplerate);drawnow; end;
            %keyboard;

            data=data2;
            descriptor='VIDEO';

            descriptor='video_mono';
            if wasrgb
                descriptor='video_rgb2gray';
            end;

            unit='AD_Units';

            dimension.descriptor=str2mat('vertical','horizontal','time');
            dimension.unit=str2mat('pixel','pixel','s');
            axtmp=cell(3,1);
            axtmp{1}=1:nrow;
            axtmp{2}=1:ncol;
            axtmp{3}=(((1:nframe)-1)./samplerate)+t0;

            dimension.axis=axtmp;

            %do external dimension specification, e.g for use with show_x_1
            %allow for conversion to real units if scaling available

            dimension.external.descriptor=dimension.descriptor;

            dimension.external.unit=dimension.unit;
            tmp=dimension.axis;
            tmp1=tmp{1};
            tmp{1}=tmp1';
            tmp3=ones(1,1,nframe);
            tmp3(1,1,1:nframe)=tmp{3};
            tmp{3}=tmp3;
            dimension.external.axis=tmp;




            private.avi2mat_trial_f=myset;
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
    %than the simple two-point averaging filter

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
