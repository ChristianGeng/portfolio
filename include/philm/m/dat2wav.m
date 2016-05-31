function dat2wav(sonyfile,downstep)
% DAT2WAV Quick and dirty conversion of audio data from dat to wav file
% function dat2wav(sonyfile,downstep)
% dat2wav: Version ???
%
%   Description
%       assumes single channel and 48kHz
%       could check from sony .log file if transfered to computer using sony pc216 or 208 and sony interface
%       downsampled to 24kHz using matlab's decimate function (with default setting 2 passes through
%       8th order cheby with cutoff frequency at 0.8 * 12kHz)
%       mainly designed for handling new DAT version of Schiefer corpus
%       assumes data transferred from DAT in chunks that will fit confortably into main memory (as doubles)
%       downstep: optional, downsample rate, default to 2


idown=2;
if nargin>1 idown=downstep; end;

sf=48000;
fsd=32768;
myext='bin';
issony=1;

disp(sonyfile);
fid=fopen([sonyfile '.' myext],'r');
x=fread(fid,inf,'int16');
fclose(fid);

disp(['Total input samples ' int2str(length(x))]);

if issony
sonycomment=readtxtf([sonyfile '.log']);
disp(sonycomment);
end;
%namestr=[namestr '<Sony LOG file start>' crlf sonycomment crlf '<Sony LOG file start>' crlf];

%convert log file to string matrix, then parse for channel info
%sonylogmat=rv2strm(sonycomment,crlf);
%sftemp=eval(strtok(getsonyf(sonylogmat,'TAPE_SRATE_CH')))
%[sony_chn,sony_desc,sony_unit,sony_scalefactor,sony_signalzero,sony_chrange]=sonych(sonylogmat);

%nchanin=length(sony_chn);

x=decimate(x,idown);
sf=sf/idown;

nbits=16;

disp('writing ....');
wavwrite(x/fsd,sf,nbits,sonyfile);
