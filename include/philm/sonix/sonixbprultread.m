function sonixbprultread(mynamein,mynameout,S)
% SONIXBPRULTREAD Read Ultrasonix pre-scan converted data
% function sonixbprultread(mynamein,mynameout,presetfile,commentfile,samplerateuse,tref)
% sonixbprultread: Version 21.10.2013
%
%   Syntax
%       mynamein: Specify without extension, and without trial number (if
%           present)
%       mynameout: MAT output file
%           This name is used for the pre-scan converted data.
%           An additional file name [mynameout '_sc'] contains a simple
%           version of the scan-converted data, i.e. simply projected onto
%           a rectangular grid
%       S:  struct with further specifications.
%           Some fields are optional. Most have default settings given in
%           [...].
%               Ultimately some should be extracted automatically from
%               the preset and probe xml files
%           presetfile: Optional. Name of preset file. If specified, its
%               contents are included in the private variable of the output mat
%               file. Not used for settings (and redundant if complete
%               settings file is available)
%           commentfile: Optional. File with text for comment variable in
%               output mat file
%           inputext: ['bpr'] or 'ult'. handle ultrasonix files, or
%               files exported from AAA
%           trialnumber: [''] Used to complete the input file name.
%               Specify as string.
%           scanconvertsuffix: [''] . If present used to extend output filename
%               for scan converted data. If not present (or empty) no scan
%               converted data is stored (currently rather time consuming)
%           settingsfile: mat file with complete b-mode settings from
%               sonix_ctrl. Not essential for standard .bpr files, but good
%               for documention. For files coming via AAA represents the
%               best way of getting at some of the settings.
%           =====probe geometry====
%               A mat file named 'sonix_probe_specs' should be available on
%               matlab's path.
%               This contains the key settings from the original sonix
%               probe.xml file.
%               If not available default settings for the C9-5/10 are used.
%                   (The crucial settings are pitch and radius)
%                   These are the C9-5/10 specs:
%                       numElements [128]
%                       pitch [205]
%                       radius [10000]
%                       transmitoffset [0]
%=============================================
%           Settings needed for .ult files (for .bpr these settings are in
%           the header):
%           It is intended that for AAA recordings it should also be
%           possible to generate a matlab info file that will supply these
%           settings.
%           probe_id: 19 or 21
%           linedensity. No default
%           b_samplefrequency. No default. This is needed to work out pixel
%               resolution along the scan lines. Corresponds to variable id
%               "b-sampl freq" in ulterius, "BSF" in the B-GEOM menu, and field
%               sf in the bpr files.
%               It is the sample rate of the envelope-detected data (i.e
%               usually downsampled from the radio frequency data)
%               Normal values are 4MHZ for C9-5/10 and 2.5MHZ for C7-3/50
%               Re-arranging the following relationship
%                 depth = (samples_per_scanline * c)/(2*samplerate)
%               gives
%                   samplerate=(samples per scanline * 1540000)/(2 *
%                   depth_in_mm)
%               (where samples per scanline can be found in the
%               pixpervector field in the *US.txt file exported by AAA).
%               But only use this as a last resort, as the system depth
%               setting only seems to be approximate (also the depth
%               setting may be changed during an experiment, whereas it is
%               very unlikely that the samplerate will be changed)
%           ====================
%           tref ['start']
%               Specifies the field to use in the struct returned by
%               findsonixpulse (see below).
%               Currently use 'end' only if it is clear that the cineloop
%               has wrapped round.
%           sonixpulse Struct returned by findsonixpulse
%               (if this field is not present it is assumed the recording
%               does not need to be time-referenced to other data; variable
%               't0' in the output file is set to zero)
%               The time reference in the trial is based on the ultrasonix frame pulse
%               stream analyzed by findsonixpulse.
%               Use of this pulse stream is complicated by the following
%               factors:
%                   (1) If the cineloop wraps round there can be more pulses than
%                   there are frames in the ultrasound file.
%                   (2) Even when the cineloop does not wrap round it seems
%                   that normally one more sync pulse than ultrasound
%                   frames is generated (but not yet known how constant
%                   this is; a difference of 2 has occasionally been
%                   observed).
%                   (3) AAA currently (12.2012) stops the
%                    multichannel acquisition for the trial a few frames before
%                    the frame sync stream is stopped by placing the ultrasound
%                    machine in freeze mode.
%               Thus, if possible, it is on balance best to synchronize ultrasound and
%               other data by assuming that the first ultrasound frame
%               coincides with the first synch pulse (tref='start').
%               If this is clearly not justified (i.e. cine buffer has clearly wrapped round),
%               set tref to 'end'.
%               Then synchronization is calculated back from the last sync
%               pulse. But this needs an assumption about how many pulses
%               occur after the last frame (which can only be observed when
%               the cine loop does not wrap round! bloed!).
%               Currently this defaults to a value of 1, but this can be
%               overridden by field framepulseadj if it turns out that it
%               depends on the ultrasound setup in some way.
%               If tref is set to 'start' and the number of pulses exceeds
%               the number of frames by a margin that still needs to be
%               determined (3.2013) then the user is given a warning that
%               the cinebuffer has probably wrapped round. The program
%               should then be re-run with tref set to 'end' (however, for AAA recordings
%               this not recommended as long as the program does not record the complete sync
%               sequence).
%               Ultimately, it would be better to determine for the current
%               settings how many frames the cine buffer can contain and
%               detect wraparound from this.
%           samplerateuse . Default to framerate in .bpr header, but this
%               is unlikely to be accurate. Should determine empirically from
%               frame sync pulses (research interface parameter ??? may be
%               fairly accurate)
%       ============================
%       imagexdesc ['horizontal_ap'] description of x axis of scan
%           converted images
%       imageydesc ['vertical'] description of y axis of scan
%           converted images
%       angleoffset [0] Angle by which to rotate coordinate system, e.g to
%           get horizontal axis parallel to occlusal plane
%       dimensioncomment [''] Currently no default. Should specify e.g.
%           direction of increasing anterior-posterior values, and effect
%           of any angleoffset
%       ======================
%       pixelresolution: [0.2] Only relevant for scan-converted output
%       clim: Optional. Only relevant for display. No effect on output
%       moviespeedfactor [1] >1 to speed up display, <1 to slow down
%       item_id: Optional. e.g. trial prompt (e.g from AAA export to text
%           file)
%       timefilter: coefficients to filter each pixel along the time
%           dimension
%       spatialfilter: filtering of each scan line
%       spatialdecimation: downsampling factor along scan line
%           e.g if sampling the bpr data with BSF parameter increased from
%           system default (possibly in combination with decimation 0 to
%           give basic system sample rate of 40MHz)
%           note: decimation only possible if spatialfilter also specified
%       helpwinflag: For use with sonix_readheader. Determines whether
%           header is displayed in help window
%==============================================
%       audiochannel and audioname: if present converts wav files exported
%       from AAA to mat
%
%   Notes
%       User presets are in d:\ultrasonix settings\user settings\imaging
%           but should not normally be needed if current settings can be
%           retrieved via the ulterius interface.
%       Notes on probe.xml file (what is its normal location on the ultrasonix
%           system?):
%           If the matlab sonix_probe_specs.mat file needs to be extended
%           look for lines like this:
%           <probe id="19" name="C9-5/10">
%           Then the key geometric information seems to be in these lines:
%           <numElements>128</numElements>
%           <pinOffset>0</pinOffset>
%           <pitch>205</pitch>
%           <radius>10000</radius>
%           <transmitoffset>0.000000</transmitoffset>
%           (not sure what pinOffset is though)
%
%   See Also
%       FINDSONIXPULSE


functionname='sonixbprultread: Version 21.10.2013';

probespecfile='sonix_probe_specs';  %must be on matlab's path

%sonheadlen=19; %bpr header length
%ultrasonix file types (bpr is 2)
type_bpr=2;
%type_bpost=4;
%type_bpost32=8;

readformat='*uint8';
pixelbytes=1;
%scale up data and use int16 for storage internally
inputscalefactor=64;


um2mm=0.001;        %convert micrometers to mm (for probe pitch and radius)

%       depth = (samples_per_scanline * c)/(2*samplerate)
speedofsound = 1540; %m/s; see menu B-RX Sound Velocity).
c_mmpers=speedofsound*1000;

myext='bpr';
if isfield(S,'inputext')
    myext=S.inputext;
end;

trialnumber='';
if isfield(S,'trialnumber') trialnumber=S.trialnumber; end;

myname=[mynamein trialnumber '.' myext];
item_id=[mynamein trialnumber];
if isfield(S,'item_id') item_id=S.item_id; end;

fid=fopen(myname,'r');
if fid==-1
    disp(['Problem opening file ' myname]);
    return;
end;


if strcmp(myext,'bpr')
    helpwinflag=0;
    if isfield(S,'helpwinflag') helpwinflag=S.helpwinflag; end;
    P=sonix_readheader(fid,helpwinflag);
    %    sonhead=fread(fid,sonheadlen,'int32');
end;

infofile='';
I=[];
infofilemat=[mynamein trialnumber '_info'];
%if an info file specifically for this trial exists this takes precedence
if exist([infofilemat '.mat'],'file')
    infofile=infofilemat;
end;

if isempty(infofile)
    if isfield(S,'settingsfile')
        infofile=S.settingsfile;
        if ~exist([infofile '.mat'],'file')
            infofile='';
            disp(['Unable to find settings file given in input struct: ' S.settingsfile]);
            keyboard;
        end;
    end;
end;
if ~isempty(infofile)
    disp(['Using settings file : ' infofile]);
    privatetmp=mymatin(infofile,'private');
    if isfield(privatetmp,'sonix')
        I=privatetmp.sonix;
    else
        disp('Unable to get data from settings file');
        infofile='';
        keyboard;
    end;
    
end;

%temporary measure as our ulterius interface initially didn't store correct probe_id
if strcmp(myext,'bpr')
    if P.probe_id==0
        if ~isempty(infofile)
            P.probe_id=getprobeid(I.probe_name,probespecfile);
            disp(['Replacing dummy probe_id with ' int2str(P.probe_id)]);
        else
            disp('Unable to replace dummy probe_id without info file');
            keyboard;
            return;
        end;
    end;
end;


if strcmp(myext,'ult')
    %Entries in *US.txt file:
    %(not all used, and not sure all are correct)
    %NumVectors=192
    %PixPerVector=364
    %ZeroOffset=50
    %BitsPerPixel=8
    %Angle=0.011
    %PixelsPerMm=10.000
    %FramesPerSec=0.000
    
    ss=file2str([mynamein trialnumber 'US.txt']);
    ss=char(strrep(cellstr(ss),',','.'));
    vv=strmatch('NumVectors',ss);
    tmps=ss(vv,:);
    [tmp1,tmp2]=strtok(tmps,'=');
    P.nvec=str2num(tmp2(2:end));
    
    vv=strmatch('PixPerVector',ss);
    tmps=ss(vv,:);
    [tmp1,tmp2]=strtok(tmps,'=');
    P.nsamp=str2num(tmp2(2:end));
    
    vv=strmatch('BitsPerPixel',ss);
    tmps=ss(vv,:);
    [tmp1,tmp2]=strtok(tmps,'=');
    P.samplesize_bits=str2num(tmp2(2:end));
    
    fstat=fseek(fid,0,'eof');
    fbyte=ftell(fid);
    frewind(fid);
    
    ultframes=fbyte/(pixelbytes*P.nvec*P.nsamp);
    disp(['Frames in .ult file : ' num2str(ultframes)]);
    P.nframes=ultframes;
    
    
    defaultprobe=19;
    
    %as an alternative to fields in the input struct, should allow a
    %matlab info file to be used as input (as generated by sonix_ctrl('ini')
    %and sonix_ctrl('getframedata'))
    
    %probe name from settings file takes priority over probe_id in input
    %struct.
    %Default only used if all else fails (discouraged)
    P.probe_id=[];
    if ~isempty(infofile)
        P.probe_id=getprobeid(I.probe_name,probespecfile);
    end;
    if isempty(P.probe_id)
        if isfield(S,'probe_id') P.probe_id=S.probe_id; end;
    end;
    if isempty(P.probe_id)
        disp('No probe specified in settings file or input struct');
        disp(['Using default probe ' int2str(defaultprobe)]);
        keyboard;
        P.probe_id=defaultprobe;
    end;
    
    
    if ~isempty(infofile)
        P.linedensity=I.bmode_val.B_GEOM.b_ldensity;
    else
        if isfield(S,'linedensity')
            P.linedensity=S.linedensity;
        else
            disp('Must supply linedensity in input struct');
            return;
        end;
    end;
    
    if ~isempty(infofile)
        P.sf=I.bmode_val.B_GEOM.b_sampl_freq;
    else
        if isfield(S,'b_samplefrequency')
            P.sf=S.b_samplefrequency;
        else
            disp('Must supply b_samplefrequency in input struct');
            disp('Likely value is 4000000 for C9-5/10, and 2500000 for C7-3/50');
            disp('See help for more information');
            return;
        end;
    end;
    
    %this is not essential for further processing
    if ~isempty(infofile)
        P.txf=I.bmode_val.B_TX.b_freq;
    end;
    
    
    %get from settings file
    %P.txf=sonhead(15);
    
    P.datatype=type_bpr;
    P.framerate=0;
end;


nvec=P.nvec;
nsamp=P.nsamp;
%datatype=P.datatype;
nframes=P.nframes;
samplesize_bits=P.samplesize_bits;
framerate=P.framerate;


if (samplesize_bits/8) ~=pixelbytes
    disp('rewrite for program for more input formats');
    keyboard;
    return;
end;



disp(P);

%Defaults for dimension.external (i.e. for sagittal scan)
%comment should have default for direction of increasing anterior-posterior
%values
dimensioncomment='';
imagexdesc='horizontal_ap';
imageydesc='vertical';

if isfield(S,'dimensioncomment') dimensioncomment=S.dimensioncomment; end;
if isfield(S,'imagexdesc') imagexdesc=S.imagexdesc; end;
if isfield(S,'imageydesc') imageydesc=S.imageydesc; end;

%curve is a bad name: its probe radius
[pitch,curve,numelements,transmit_offset,probe_name]=getprobegeo(P.probe_id,probespecfile);

if isempty(pitch)
    disp(['Make sure probe geometry is available in ' probespecfile]);
    return;
end;

%if infofile available cross check that probe name matches
if ~isempty(infofile)
    if ~strcmp(I.probe_name,probe_name)
        disp('Inconsistent probe names in info file and data file header');
        disp([I.probe_name ' ' probe_name]);
        keyboard;
    end;
end;


pitch=pitch*um2mm;      %distance between elements on surface of probe, in mm
curve=curve*um2mm;    %radius of probe in mm


%changed 21.01.2013. Depth is no longer an input spec, but is derived from
%samplerate and number of pixels in the scanline
%b_depth=50;
%if isfield(S,'b_depth')
%    b_depth=S.b_depth;
%else
%    disp('Must provide setting for b_depth in input struct');
%    return;
%end;
b_depth = (P.nsamp * c_mmpers)/(2*P.sf);


Probe.numelements=numelements;
Probe.pitch_mm=pitch;
Probe.curve_mm=curve;
Probe.transmit_offset=transmit_offset;
Probe.b_depth=b_depth;      %maybe a better place for this?
Probe.probespecfile=probespecfile;

probesurface=(numelements-(2*transmit_offset))*pitch;
probetotalangle=(probesurface/(2*pi*curve))*360;    %seems to correspond to angle given in probe spec.

probecentreangle=90;        %should this also be configurable?
Probe.probecentreangle=probecentreangle;
angleinc=probetotalangle/P.linedensity;
angleinuse=(nvec/P.linedensity)*probetotalangle;
angleoffset=probecentreangle-(angleinuse/2);
if isfield(S,'angleoffset')
    angleoffset=angleoffset+S.angleoffset;
end;

anglevec=((0:(nvec-1))*angleinc)+angleoffset;


%data=repmat(uint8(0),[nsamp nvec nframes]);

data=fread(fid,[nsamp*nvec nframes],readformat);
data=reshape(data,[nsamp nvec nframes]);
fclose(fid);
data=int16(data)*inputscalefactor;
if isfield(S,'spatialfilter')
    decifac=1;
    if isfield(S,'spatialdecimation') decifac=S.spatialdecimation; end;
    mycoffs=S.spatialfilter;
    disp('spatial filtering');
    for ifi1=1:nframes
        disp([ifi1 nframes]);
        for ifi2=1:nvec
            tmpd=squeeze(double(data(:,ifi2,ifi1)));
            tmpd=decifir(mycoffs,tmpd,decifac);
            %            tmpd(tmpd<0)=0;
            %            tmpd(tmpd>255)=255;
            %            data(:,:,ifi1)=uint8(tmpd);
            nsamp=length(tmpd);
            data(1:nsamp,ifi2,ifi1)=int16(tmpd);
        end;
        
    end;
    if decifac>1
        data((nsamp+1):end,:,:)=[];
    end;
    
end;

%Note: b_depth was actually derived from samplerate and nsamp above
sampleinc=b_depth/nsamp;
%set up here without offset
%but for external dimension specification we will add in the probe radius
samplevec=((0:(nsamp-1))*sampleinc);



if isfield(S,'timefilter')
    mycoffs=S.timefilter;
    disp('time filtering');
    for ifi1=1:nsamp
        disp([ifi1 nsamp]);
        for ifi2=1:nvec
            tmpd=squeeze(double(data(ifi1,ifi2,:)));
            tmpd=decifir(mycoffs,tmpd);
            %            tmpd(tmpd<0)=0;
            %            tmpd(tmpd>255)=255;
            %            data(ifi1,ifi2,:)=uint8(tmpd);
            data(ifi1,ifi2,:)=int16(tmpd);
        end;
    end;
end;



%Assume no more processing of the image data so convert back to uint8
%Could in future consider going back to int16 output
%Or perhaps calculate different uint8 versions optimizing different parts
%of the dynamic range.

data=uint8(data/inputscalefactor);

xdata=repmat(0,[nsamp nvec]);
ydata=repmat(0,[nsamp nvec]);

for ii=1:nsamp
    mysamppos=samplevec(ii)+curve;
    for jj=1:nvec
        myangle=anglevec(jj)*(pi/180);
        xdata(ii,jj)=mysamppos*cos(myangle);
        ydata(ii,jj)=mysamppos*sin(myangle);
    end;
end;


%note: the wiki mentions a 4-byte frame header for bpr files, but the user forum
%makes it clear that this no longer exists


tmpdesc=cellstr(str2mat('scanline_radialposition','scanline_angle','time'));
dimension.descriptor=char(tmpdesc);
tmpunit=cellstr(str2mat('mm','deg','s'));
dimension.unit=char(tmpunit);


%maybe allow optional clim argument
hi=imagesc(anglevec,samplevec,data(:,:,1));
set(gca,'ydir','normal');
set(gca,'xdir','reverse');  %so increasing angle from right to left
%set(gcf,'colormap',gray(256));
set(gcf,'colormap',myhsv2rgb(256));

myclim=get(gca,'clim');
if isfield(S,'clim') myclim=S.clim; end;
set(gca,'clim',myclim);

moviefac=1;
if isfield(S,'moviespeedfactor') moviefac=S.moviespeedfactor; end;


xlabel([tmpdesc{2} ' (' tmpunit{2} ')'],'interpreter','none');
ylabel([tmpdesc{1} ' (' tmpunit{1} ')'],'interpreter','none');

title({dimensioncomment,[trialnumber ' ' item_id]},'interpreter','none');
%fclose(fid);

%first impression is that the integer framerate in the header is unlikely
%to be accurate
samplerate=P.framerate;
if isfield(S,'samplerateuse') samplerate=S.samplerateuse; end;

if samplerate==0
    disp('Please specify samplerateuse in input struct');
    return;
end;

%if settings file available compare with us interval

for ii=1:nframes
    %tmpd=fread(fid,[nsamp nvec],'*uint8');
    %tmpd=tmpd';
    set(hi,'cdata',data(:,:,ii));
    %data(:,:,ii)=tmpd;
    drawnow;
    pause(1/(samplerate*moviefac));
end;


comment='';
if isfield(S,'commentfile')
    comment=readtxtf(S.commentfile);
end;
presetfile='';
presetdata=[];
if isfield(S,'presetfile')
    presetfile=S.presetfile;
    presetdata=readtxtf(presetfile);
end;

private.preset=presetdata;
private.sonixheader=P;
private.probe_geometry=Probe;
private.inputspec=S;
private.sonixparameters=I;
private.settingsfile=infofile;

comment=['Input file: ' mynamein crlf 'Preset file: ' presetfile crlf comment];
comment=framecomment(comment,functionname);

descriptor='Ultrasound_B_mode';
unit='relative_echo_strength';

t0=0;
if isfield(S,'sonixpulse')
    PP=S.sonixpulse;
    %    if strcmp(myext,'bpr') tref='end'; end;
    %    if strcmp(myext,'ult') tref='start'; end;
    tref='start';
    if isfield(S,'tref') tref=S.tref; end;
    mysfield=[tref 'time'];
    if ~isfield(PP,mysfield)
        disp(['Unable to handle tref specification : ' tref]);
        return;
    end;
    synctime=PP.(mysfield);
    if strcmp(tref,'end')
        framepulseadj=1;    %typically seems to be one more pulse than frames
        if isfield(S,'framepulseadj')
            framepulseadj=S.framepulseadj;
            disp(['Overriding default framepulseadj with ' int2str(framepulseadj)]);
        end;
        
        synctime=synctime-((nframes+framepulseadj-1)/samplerate);
        if PP.npulse<nframes
            disp('Pulse stream may be truncated');
            disp('use tref=''start'' instead');
            return;
        end;
    end;
    if strcmp(tref,'start')
        if PP.npulse>(nframes+2) %no idea if this limit makes sense
            %and not accurate for AAA as long as pulse sequence is truncated
            disp(['npulse = ' int2str(PP.npulse) '; nframes = ' int2str(nframes)]);
            disp('Cine loop may have wrapped round');
            disp('Consider using tref=''end'' instead');
            disp('Type ''return'' to simply continue with current settings');
%10.2013 change return to keyboard, as the only occurrence of this
%condition to date seemed to be harmless (so nframes+2 may not always be
%the right criterion for detecting wrapround)
            keyboard;
%            return;
        end;
    end;
    S.sonixpulse.framepulsediff=PP.npulse-nframes;
    t0=synctime;
end;

private.inputspec=S;

dax=cell(3,1);
dax{1}=samplevec;
dax{2}=anglevec;

dax{3}=((0:nframes-1)/samplerate)+t0;
dimension.axis=dax;

dimension.external.descriptor=str2mat(imagexdesc,imageydesc,'time');
dimension.external.unit=str2mat('mm','mm','s');
daxe=cell(3,1);
daxe{1}=xdata;
daxe{2}=ydata;
tmpt=ones(1,1,nframes);
tmpt(1,1,:)=dax{3};
daxe{3}=tmpt;
dimension.external.axis=daxe;
dimension.external.comment=dimensioncomment;

dimsc.descriptor=dimension.external.descriptor;
dimsc.unit=dimension.external.unit;
dimsc.axis=dax;     %will be changed below
dimsc.comment=dimensioncomment;

save([mynameout trialnumber],'data','samplerate','comment','private','descriptor','unit','dimension','t0','item_id');

saveaudio(S,mynamein,myext,item_id,comment);

%display using dimension.external specification as surface object
%should be separate function
figure;
tmpax=dimension.external.axis;
xdata=tmpax{1};
ydata=tmpax{2};
hs=surf(xdata,ydata,double(data(:,:,1)));
%set clim....
set(gca,'ydir','normal');
set(gca,'clim',myclim);
title(dimension.external.comment,'interpreter','none');
tmpdesc=cellstr(dimension.external.descriptor);
tmpunit=cellstr(dimension.external.unit);
xlabel([tmpdesc{1} ' (' tmpunit{1} ')'],'interpreter','none');
ylabel([tmpdesc{2} ' (' tmpunit{2} ')'],'interpreter','none');
scdesc=tmpdesc;
scunit=tmpunit;

%set(gcf,'colormap',gray(256));
set(gcf,'colormap',myhsv2rgb(256));
set(hs,'edgecolor','none','facecolor','interp');

%to demonstrate the scanline data use these settings (then zoom in, or use
%a setting with low line density)
%set(hs,'facecolor','none')
%set(hs,'edgecolor','interp')
%set(hs,'meshstyle','col')
%set(hs,'linewidth',2)

view(0,90);
axis equal;
for ii=1:nframes
    %    disp(ii);
    tmpd=double(data(:,:,ii));
    %tmpd=tmpd';
    set(hs,'cdata',tmpd);
    title(dimension.external.comment,'interpreter','none');
    drawnow;
    pause(1/samplerate);
end;

scsuff='';
if isfield(S,'scanconvertsuffix') scsuff=S.scanconvertsuffix; end;

if ~isempty(scsuff)
    %    keyboard;
    
    
    figure;
    pixres=0.2;
    if isfield(S,'pixelresolution') pixres=S.pixelresolution; end;
    xlo=round(min(xdata(:)));
    xhi=round(max(xdata(:)));
    xi=[xlo:pixres:xhi];
    ylo=round(min(ydata(:)))+curve;
    yhi=round(max(ydata(:)));
    yi=[ylo:pixres:yhi]';
    
    
    %    keyboard;
    DT=delaunaytri(xdata(:),ydata(:));
    [xmesh,ymesh]=meshgrid(xi,yi);
    
    for ii=1:nframes
        disp([ii nframes]);
        
        %Compared to display with surf, interpolation with griddata is very slow
        %TriScatteredInterp is stated in the matlab help to be more efficient
        %however, it is not obviously faster
        ztmp=double(data(:,:,ii));
        %    F=triscatteredinterp(xdata(:),ydata(:),ztmp(:));
        F=triscatteredinterp(DT,ztmp(:));
        zi=F(xmesh,ymesh);
        
        %    zi=griddata(xdata,ydata,double(data(:,:,ii)),xi,yi,'linear');
        if ii==1
            interpbuf=uint8(zeros(size(zi,1),size(zi,2),nframes));
        end;
        interpbuf(:,:,ii)=uint8(zi);
    end;
    
    hi2=imagesc(xi,yi,interpbuf(:,:,1));
    set(gca,'ydir','normal');
    set(gca,'clim',myclim);
    %set(gcf,'colormap',gray(256));
    set(gcf,'colormap',myhsv2rgb(256));
    xlabel([scdesc{1} ' (' scunit{1} ')'],'interpreter','none');
    ylabel([scdesc{2} ' (' scunit{2} ')'],'interpreter','none');
    title(dimensioncomment,'interpreter','none');
    axis equal;
    for ii=1:nframes
        
        set(hi2,'cdata',interpbuf(:,:,ii));
        drawnow;
        pause(1/samplerate);
        
    end;
    data=interpbuf;
    dimension=dimsc;
    %note: dimension.external.descriptor stores in the order x, y, (time)
    dimension.descriptor=str2mat(imageydesc,imagexdesc,'time');
    dimension.unit=str2mat('mm','mm','s');
    
    tmpax=dimension.axis;
    tmpax{1}=yi;
    tmpax{2}=xi;
    dimension.axis=tmpax;
    dimension.comment=dimensioncomment;
    save([mynameout scsuff trialnumber],'data','samplerate','comment','private','descriptor','unit','dimension','t0','item_id');
    
end;
close all
function saveaudio(S,mynamein,myext,item_id,comment)

if isfield(S,'audioname')
    audioname=S.audioname;
    if ~isempty(audioname)
        if isfield(S,'audiochannel')
            if strcmp(myext,'ult')
                trialnumber='';
                if isfield(S,'trialnumber') trialnumber=S.trialnumber; end;
                namein=[mynamein trialnumber '_Track' S.audiochannel '.wav'];
                if exist(namein,'file')
                    [data,samplerate]=wavread(namein);
                    
                    private.sonixbprultread=S;
                    descriptor=['audio_ch' S.audiochannel];
                    unit='normalized';
                    nameout=[audioname trialnumber];
                    data=single(data);
                    save(nameout,'data','descriptor','unit','samplerate','item_id','private','comment');
                    
                else
                    disp(['No audio file ? ' namein]);
                end;
            end;
        end;
    end;
end;
function [pitch,radius,numElements,transmitoffset,probe_name]=getprobegeo(probe_id,probespecfile);
defaultprobe=19;
defaultprobename='C9_5_10mm';
pitch=[];
radius=[];
numElements=[];
transmitoffet=[];
probe_name=[];

if exist([probespecfile '.mat'],'file')
    P=mymatin(probespecfile,'Probe');
    [mylabel,myvalue]=getvaluelabel(probespecfile,'Probe');
    vp=find(probe_id==myvalue);
    if isempty(vp)
        disp('Unable to identify probe');
        keyboard;
        return;
    else
        
        probe_name=deblank(mylabel(vp,:));
        numElements=P.(probe_name).numElements;
        pitch=P.(probe_name).pitch;      %distance between elements on surface of probe, in umeter
        radius=P.(probe_name).radius;    %radius of probe in umeter
        transmitoffset=P.(probe_name).transmitoffset;      %not sure what this is, but it seems to be 0 for our probes
    end;
    
else
    disp(['Probe spec file not found : ' probespecfile]);
    if probe_id==defaultprobe
        %default probe settings
        numElements=128;
        pitch=205;      %distance between elements on surface of probe, in umeter
        radius=10000;    %radius of probe in umeter
        transmitoffset=0;      %not sure what this is, but it seems to be 0 for our probes
        probe_name=defaultprobename;
        disp(['Using default values for probe ' int2str(probe_id) '; ' probe_name]);
        keyboard;
    else
        disp(['Must be set up for probe ' int2str(probe_id)]);
        keyboard;
        return;
    end;
end;

function probe_id=getprobeid(probename,probespecfile);
%probably only needed to determine probe_id automatically for AAA recordings
%if probename is available from settings file
%if useful, could be made an external function that converts in both
%directions (i.e. also for id to name)

probe_id=[];
if exist([probespecfile '.mat'],'file')
    [mylabel,myvalue]=getvaluelabel(probespecfile,'Probe');
    vp=strmatch(probename,mylabel);
    if isempty(vp)
        disp('Unable to identify probe');
        keyboard;
        return;
    else
        probe_id=myvalue(vp(1));
    end;
else
    disp(['Probe spec file not found : ' probespecfile]);
    keyboard;
end;