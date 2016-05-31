function getlsbc_ii(cmdfile)
% GETLSBC_II Get lsb signal from multichannel dat. Version for Sony Mark II
% function getlsbc_ii(cmdfile)
% getlsbc_ii: Version 6.6.2005
%
%   Description
%       Get synch signal: can be either lsb signal or actual channel signal
%       times stored as MAT cutfile
%       can then be used to control dat2mat_ii
%       Uses getlsbc_ii.log as log file
%
%   See Also
%       DAT2MAT_II

%=======================================
%
%         2.98 expanded cut file format
%           6.2003, choice of rising/falling flank

%initialize command file control
cmdarg=0;
if nargin cmdarg=cmdfile;end;
philcom(cmdarg);

namestr='';
functionname='getlsbc: Version 6.6.2005';
disp (functionname);
namestr=[namestr '<Start of Comment> ' functionname crlf];
maxcut=20000;
[abint,abnoint,abscalar,abnoscalar]=abartdef;

timdat=ones(maxcut,4)*NaN;
maxtlen=length(int2str(maxcut));
cutlabel=setstr(zeros(maxcut,maxtlen));
diary getlsbc_ii.log

%open input file
%basically same as dat2mat_ii

fidin=0;
while fidin<=2
   infile=philinp('Multiplexed Sony input file (without extension -  .BIN and .LOG files required) : ');
   [fidin,message]=fopen([infile '.bin'],'r');
   if ~isempty(message) disp(message); end
end



%bytes per sample for input file
datbyt=2;
indatatype='ushort';
%get file length
status=fseek(fidin,0,'eof');
filelength=ftell(fidin);
status=fseek(fidin,0,'bof');


sonycomment=readtxtf([infile '.log']);
disp(sonycomment);
namestr=[namestr '<Sony LOG file start>' crlf sonycomment crlf '<Sony LOG file start>' crlf];

%convert log file to string matrix, then parse for channel info
sonylogmat=rv2strm(sonycomment,crlf);
[sony_chn,sony_desc,sony_unit,sony_scalefactor,sony_signalzero,sony_chrange]=sonych(sonylogmat);

nchanin=length(sony_chn);

%sfbase is overall data rate
%sfchannel is samplerate of each channel in the input file
%sf output sample rate for each channel
%i.e will be different from sfchannel if downsampling is performed
sftemp=eval(strtok(getsonyf(sonylogmat,'TAPE_SRATE_CH')));
dectemp=eval(getsonyf(sonylogmat,'DECIMATION'));
sfchannel=sftemp/(dectemp+1);
sfbase=sfchannel*nchanin;
sf=sfchannel;
framebyt=datbyt*nchanin;






synchchan=1;

%replace with abartstr?????
tempstr=philinp('Use channel (C) or lsb (L) data [L] ?' );
if isempty(tempstr) tempstr='L';end;
tempstr=upper(tempstr);
lsbflag=1;
namestr=[namestr 'Channel or LSB mode: ' tempstr crlf];

if strcmp(tempstr,'C') lsbflag=0; end;

falls=upper(abartstr('Flank: P=positive, N=Negative','P'));
fallingflank=0;
if strcmp(falls,'N') fallingflank=1; end;

if ~lsbflag
   [synchname,synchchan]=abartstr ('Name of synch data channel',deblank(sony_desc(synchchan,:)),sony_desc,abscalar);
   
   %????upgrade to voltage at input
   
   threshold=abart('Threshold',16000,-30000,30000,abint,abscalar);
   namestr=[namestr 'Synch channel/threshold: ' synchname ' ' int2str(threshold) crlf];
   
   indatatype='short'; %ushort for lsb, cf. above??
   if fallingflank threshold=-threshold; end;
end;



%prompt for polarity of lsb signal
%assume lsb always off at beginning...???
lastdat=0;



%cut data stored as MAT file
cutname=philinp('Output CUT file name: ');
namestr=[namestr 'Output cut file: ' cutname crlf];

nsamp=0;


%use skip function in fread to select synch channel from complete record
%lsb position will thus be determined with resolution equal to
%channel sample interval, rather than overall data rate

%temporary
lsb_hires=0;
%allow choice of maximum lsb time resolutions as follows:
if lsb_hires & nchanin>1
   %warning of nchanin not same as channels on tape
   if nchanin~=eval(getsonyf(sm,'TAPE_BC_MODE'))
      disp('Warning: Hi-res LSB is not using all tape channels')
   end;
   
   nchanin=1;
   sf=sfbase;
end;



skipbytes=(nchanin-1)*datbyt;
chanbyteoffset=(synchchan-1)*datbyt;

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
[descriptor,unit,cut_type_value,cut_type_label]=cutstruc;

comment=[namestr '<End of Comment> ' functionname crlf];
%check no incomplete cuts??????
totalcuts=icut-1;

if ~isnan(timdat(icut,1))
    disp('Offset missing in last cut');
    totalcuts=icut;
    timdat(icut,2)=(totalsamp-1)/sf;
end;


disp (['total cuts : ' int2str(totalcuts)]);

data=timdat(1:totalcuts,:);
label=cutlabel(1:totalcuts,:);
eval (['save ' cutname ' data label descriptor unit comment cut_type_value cut_type_label']);


diary dodo
diary off
