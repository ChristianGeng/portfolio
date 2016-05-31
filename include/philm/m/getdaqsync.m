function getdaqsync(sonyfile,S,synchmode,synchflank,synchchannel,synchthreshold)
% GETDAQSYNC Get sync signal from multichannel binary file. Version NI Daq
% function getdaqsync(sonyfile,S,synchmode,synchflank,synchchannel,synchthreshold)
% getdaqsync: Version 05.03.2013
%
%   Description
%       Get synch signal: can be either LSB signal or actual channel signal
%           (LSB mainly only for compatibility with Sony Dat versions
%           (getlsbc_ii_f))
%       Times stored as MAT cutfile
%       Can then be used to control daq2mat
%
%   Syntax
%       sonyfile: Specify without extension (must be .bin)
%       S: struct to specify format of input file
%           samplerate
%           nchan
%           datatype
%           scalefactor and signalzero: default to 1 and 0 respectively.
%               Probably only useful when input data is integer. Data can be
%               scaled, so that threshold can be specified in volts
%           timeadjust: Offset to add to the detected times. Default to 0.
%               Mainly intended to compensate for input delays in NI
%               modules.
%               In particular, the 9234 module has a delay in seconds given by
%               ((38.4/samplerate) + (3.2/1000000))
%               (See NI 9234 Operating Instructions and Specifications p.
%               22)
%               This should be taken into account if the sync signal is
%               detected via the digital input module (assume zero delay)
%               In this situation the offset (given by the above formula)
%               is positive.
%               (It would be negative if the sync is detected via a second
%               9234 module running at a slower sample rate than the 'main'
%               9234 module.)
%               Important note: If signals with different delays need to be
%               extracted then use the timeadjust field in daq2mat rather
%               than here (otherwise separate sync files will be needed for
%               separate signals). !Be careful not to do timeadjust twice!
%           Additional fields can be used for informational purposes, as S is
%           placed in the private variable of the output sync file
%       synchmode: C or L (for Channel vs. LSB)
%       synchflank: P or N (positive vs. negative). Indicates whether start
%           of trial is given by positive or negative slope of the synch
%           signal.
%           Note that sybox of AG500 uses negative flank for start of trial
%           (5V to 0V transition) whereas synch signals generated by the
%           prompt program via the parallel port are normally
%           positive-going.
%       synchchannel: number of channel within the BIN file on which the synch signal was
%           recorded (the numbering will depend on how data was extracted from the
%           TDMS or XMS files).
%       synchthreshold: Units depend on how the BIN file was generated. If
%           it contains floating point (single or double) then normally units
%           will be in volts.
%       The generated cut file is stored with same name (and path) as the
%       input sony file, but with suffix '_sync' (extension is .mat)
%
%   Updates
%       11.2012 include timeadjust field in input struct
%
%   See Also
%       DAQ2MAT, CONVERTTDMS_PH, GETLSBC_II_F

%=======================================
%
%         2.98 expanded cut file format
%           6.2003, choice of rising/falling flank
%       6.2005 Warning for incomplete segments
%       6.2005 Converted to control with input arguments
%

namestr='';
functionname='getdaqsync: Version 05.03.2013';
disp (functionname);
maxcut=20000;

datatypelist=str2mat('int8','int16','single','double');
datatypelengthlist=[1 2 4 8];



timdat=ones(maxcut,4)*NaN;
timdat(:,3)=0;
maxtlen=length(int2str(maxcut));
cutlabel=setstr(zeros(maxcut,maxtlen));

%open input file
%basically same as daq2mat

fidin=0;
%while fidin<=2
%   infile=philinp('Multiplexed Sony input file (without extension -  .BIN and .LOG files required) : ');
infile=sonyfile;
[fidin,message]=fopen([infile '.bin'],'r');
   if ~isempty(message) disp(message); return; end
%end


indatatype=S.datatype;

vv=strmatch(indatatype,datatypelist);
if length(vv)~=1
    disp('Unsupported input data type');
    disp(indatatype);
    return;
end;
datbyt=datatypelengthlist(vv);

%get file length
status=fseek(fidin,0,'eof');
filelength=ftell(fidin);
status=fseek(fidin,0,'bof');




nchanin=S.nchan;

%sfbase is overall data rate
%sfchannel is samplerate of each channel in the input file
%sf output sample rate for each channel
%i.e will be different from sfchannel if downsampling is performed
sfchannel=S.samplerate;
sfbase=sfchannel*nchanin;
sf=sfchannel;
framebyt=datbyt*nchanin;

scalefactor=1;
signalzero=0;
if isfield(S,'scalefactor')
scalefactor=S.scalefactor;
end;
if isfield(S,'signalzero')
signalzero=S.signalzero;
end;

timeadjust=0;
if isfield(S,'timeadjust')
    timeadjust=S.timeadjust;
end;


 synchchan=synchchannel;

tempstr=synchmode;
if isempty(tempstr) tempstr='C';end;
tempstr=upper(tempstr);
lsbflag=0;
namestr=[namestr 'Channel or LSB mode: ' tempstr crlf];

if strcmp(tempstr,'L') lsbflag=1; end;

falls=synchflank;
fallingflank=0;
if strcmp(falls,'N') fallingflank=1; end;

if ~lsbflag


    threshold=synchthreshold;
   namestr=[namestr 'Synch channel/threshold: ' int2str(synchchan) ' ' int2str(threshold) crlf];
   
   if fallingflank threshold=-threshold; end;
end;



lastdat=0;



%cut data stored as MAT file
%cutname=philinp('Output CUT file name: ');
cutname=[sonyfile '_sync'];
namestr=[namestr 'Output cut file: ' cutname crlf];

nsamp=0;


%use skip function in fread to select synch channel from complete record


skipbytes=(nchanin-1)*datbyt;
chanbyteoffset=(synchchan-1)*datbyt;
%keyboard;
status=fseek(fidin,chanbyteoffset,'bof');

datlen=12000;
totalsamp=filelength./datbyt;
totalsamp=totalsamp/nchanin;
%last incomplete nibble ignored!!!
nibbles=floor(totalsamp/datlen);

icut=1;
%====================================================
% Main loop
% nibbles thru multiplexed DAT file
%===================================================
for inib=1:nibbles
   disp ([inib nibbles]);
   %data in type as variable
   dat=fread(fidin,datlen,indatatype,skipbytes);
    dat=(dat*scalefactor)+signalzero;
   iocode=showferr(fidin,'DAT file read');
   ndat=length(dat);
   if ndat < datlen
      %it may be better to break off here
      disp ('Read incomplete??');
      disp ([datlen ndat]');
   end

   %convert signal to 0/1
   %may be a more elegant way using input format to just read 1 bit
   %lastdat must be copied, so signal can be differentiated

   %sony seems to treat the lsb TTL input as active low
   % so LSB is SET for 0V input
   
   if lsbflag
        if fallingflank dat=bitcmp(dat,16);end;
       bdat=[lastdat;~bitget(dat,1)]; %replace with bitand in Version 5
   else
    if fallingflank dat=-dat; end;
       bdat=[lastdat;dat>threshold];
   end;
   lastdat=bdat(ndat+1);
   bdat=diff(double(bdat));
   %allow polarity reversal.....
   %look for +1 as onset, -1 as offset
   vv=find(abs(bdat)==1);
   
   if ~isempty(vv)
      nv=length(vv);
      disp (['No. of lsb changes : ' int2str(nv)]);
      disp(vv)
      disp(bdat(vv))
      
      %keyboard;
      xpos=(vv+nsamp-1)./sf;     %position in seconds
      idat=bdat(vv);
      for ilsb=1:nv
         if idat(ilsb) > 0
            %onset
            disp('onset');
            disp(idat(ilsb));
            if ~isnan(timdat(icut,1)) disp('unexpected!!'); end;
            timdat(icut,1)=xpos(ilsb);
         else
            %offset
            timdat(icut,2)=xpos(ilsb);
            timdat(icut,4)=icut;      %trialnumber
            cutlabel(icut,:)=int2str0(icut,maxtlen);
            disp ([icut timdat(icut,1:2) diff(timdat(icut,1:2))]);
            if isnan(timdat(icut,1))
                disp('Missing Onset!!');
            end;
            
            icut=icut+1;
            if icut>maxcut
%not a good solution
                disp('Too many segment in input file');
                icut=maxcut;
            end;
        end;            %lsb sign
      end;                %lsb loop
   end;                   %vv not empty
   
   nsamp=nsamp+datlen;
   
   
   
   
end
%================= end of input loop ===================
fclose(fidin);
%
%write cut file as MAT file
[descriptor,unit,valuelabel]=cutstrucn;


private.getdaqsync.settings=S;

comment=[namestr];
%comment=[namestr sonycomment];
comment=framecomment(comment,functionname);
%check no incomplete cuts??????
totalcuts=icut-1;

if ~isnan(timdat(icut,1))
    disp('Offset missing in last cut');
    totalcuts=icut;
    timdat(icut,2)=(totalsamp-1)/sf;
end;


disp (['total cuts : ' int2str(totalcuts)]);

data=timdat(1:totalcuts,:);
data(:,1:2)=data(:,1:2)+timeadjust;
label=cutlabel(1:totalcuts,:);
save(cutname,'data','label','descriptor','unit','comment','private','valuelabel');
%save(cutname,'data','label','descriptor','unit','comment','private','valuelabel','-v6');

