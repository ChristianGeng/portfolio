function S=getsyncbu_a(infile)
% GETSYNCBU_A Analyze synch bright up signal in audio track
% function S=getsyncbu_a(infile)
% getsyncbu_a: Version 11.03.2011
%
%   Syntax
%       infile: mat or wav file. Specify without extension. First looks for
%           mat file. If not found looks for wav file.
%           In both cases assumes only one channel in the file.
%       t0: estimated time of first video field with brightup signal
%       samplerate: estimated framerate of video data, using negative
%           vertical sync pulses following the beeps.
%           Empty if not enough pulses are found
%       srcheck: Framerate estimated from beeps. Should be very close to
%           samplerate. Just intended as cross check: if the two frame rate
%           estimates differ a lot something probably went wrong
%       beepontimes and beepofftimes: Time of beep onsets and offsets. Should be 4 elements in
%           both vectors. Also mainly intended to catch problems
%
%   Description
%       Assuming 4 beeps the nominal time of the first field (t0) is set 
%       at onset of first beep + (1/8 * ((offset of last beep) - (onset of
%       first beep)))
%       It is expected that the onset of the first beep and offset of last
%       beep can be determined reliably even if settings are not
%       precise enough to allow all beep onsets and offsets to be detected.
%       The samplerate estimate is then derived by looking for negative
%       vertical sync pulses after the last beep
%
%   See Also GETSYNCBU_V

S=[];
t0=[];
samplerate=[];
srcheck=[];
bont=[];
bofft=[];

fileok=0;
if exist([infile '.mat'],'file')
    fileok=1;
else
if exist([infile '.wav'],'file')
    fileok=2;
    
else
    disp('no input mat or wav file?');
    disp(infile);
    return;
end;
end;

peepf=1000;
w1=peepf*0.8;
w2=peepf*1.2;
bn=100;     %order of band pass filter

peepper=1/peepf;
%frequency threshold to find beep onset and offset in zerocrossing signal
%note: since zx signal does not decline to zero between beeps (depends on
%window length in zeroxrate) the threshold should probably be not too much
%below the actual beep frequency
fthresh=0.75*peepf;

nbeep=4;    %expected number of beeps

nvpulse=12;     %number of vertical synch pulses on which to base framerate estimate.
%Normally, there should be one pulse just after the end of the last beep, and then another
%14

if fileok==1
    y=double(mymatin(infile,'data'));
    sf=mymatin(infile,'samplerate');
end;
if fileok==2
[y,sf]=wavread(wavfile);
end;

sf2=sf/2;

w1=w1/sf2;
w2=w2/sf2;

winlen=round(peepper*5*sf);
wininc=1;       %zero crossing signal calculated at same rate as input signal
%either increase wininc or downsample the input if slow

b=fir1(bn,[w1 w2]);

yf=decifir(b,y);

noiseval=0.3*max(yf);
zxd=zeroxrate(yf,winlen,wininc,noiseval,sf);

%smooth the zerocrossing rate signal a bit
b2=fir1(bn,0.1);
zxdf=decifir(b2,zxd);

zxdf=zxdf/2;        %because zeroxrate counts positive and negative crossings

%look for beep onsets and offsets

zxdf2=zxdf(2:end);
zxdf1=zxdf(1:(end-1));
bon=find(zxdf2>=fthresh & zxdf1<fthresh);
boff=find(zxdf2<=fthresh & zxdf1>fthresh);

%should check not empty

bont=bon/sf;
bofft=boff/sf;
t0=bont(1)+((bofft(end)-bont(1))/(nbeep*2));
samplerate=1./mean([diff(bont);diff(bofft)]);
srcheck=samplerate;
srsamp=round(sf/srcheck);
samplerate=[];
try
    yx=y((boff(end)+srsamp):(boff(end)+(srsamp*(nvpulse+4))));
catch
    %may happen if wav file is too short for some reason
    disp('unable to extract data for vertical sync detection');
    return;
end;

%maybe bandpass filter this data slightly?
pamp=min(yx);
pthresh=pamp*0.5;       %precise threshold should not be too crucial

vp=find((yx(2:end)<pthresh) & (yx(1:(end-1))>=pthresh));
nvp=length(vp);
if nvp<=nvpulse
    disp('Unable to find enough vertical sync pulses');
    keyboard;
else
    samplerate=sf/((vp(nvpulse+1)-vp(1))/nvpulse);
end;
S.samplerate=samplerate;
S.t0=t0;
S.srcheck=srcheck;
S.beepontimes=bont;
S.beepofftimes=bofft;

%keyboard;
 