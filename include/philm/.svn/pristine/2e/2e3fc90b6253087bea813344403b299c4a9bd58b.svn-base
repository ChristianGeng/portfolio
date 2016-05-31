function getsynchfromwav(wavfile,synchchannel,synchthreshold,audiosrin)
% GETSYNCHFROMWAV Get synch pulses from one channel of wav file
% function getsynchfromwav(wavfile,synchchannel,synchthreshold,audiosrin)
% getsynchfromwav: Version 04.03.2013
%
%   Description
%       Get synch signal from wav file
%       Times stored as MAT cutfile
%       Can then be used to control dat2mat_ii_f or tif2mat_trial_f
%       Uses getsynchfromwav.log as log file
%       Similar to getlsbc_ii_f but no lsb function, and assumes threshold
%       symmetrical about zero
%
%   Syntax
%       synchchannel: channel number in wav file
%       synchthreshold: Specified in normalized units (i.e full range is -1
%			to +1 (as displayed by praat, audacity or matlab (when data is read
%			with wavread without the 'native' option)).
%           Specify the threshold for sync on
%           it will be asumed that sync off is the negative of this
%       The generated cut file is stored with same name (and path) as the
%       input wav file, but with suffix '_sync' (extension is .mat)
%		audiosrin: Override samplerate found in wav file
%			It appears that with the mini-DV recorders the actual ratio of
%			audio to video samplerate can deviate slightly from the
%			expected 48000/25.
%			If the deviation is assigned to the audio an adjustment can be
%			calculated by examining the number of audio samples obtained
%			when exporting the sound track from the avi
%			and comparing this with the expected number of samples based on
%			the number of video frames resulting from the export multiplied
%			by 48000/25.
%
%   See Also
%       DAT2MAT_II_F, GETLSBC_II_F, TIF2MAT_TRIAL_F
%
%  Updates
%       7.2010 first version, based on getlsbc_ii_f


namestr='';
functionname='getsynchfromwav: Version 04.03.2013';
disp (functionname);
maxcut=20000;
[abint,abnoint,abscalar,abnoscalar]=abartdef;

timdat=ones(maxcut,4)*NaN;
timdat(:,3)=0;
maxtlen=length(int2str(maxcut));
cutlabel=setstr(zeros(maxcut,maxtlen));
diary getsynchfromwav.log

wavsize=wavread(wavfile,'size');
totalsamp=wavsize(1);
nchanin=wavsize(2);

[y,sf,nbits]=wavread(wavfile,1);

sfuse=sf;
if nargin>3
	sfuse=audiosrin;
end;


synchchan=synchchannel;

    threshold=synchthreshold;
   namestr=[namestr 'Synch channel/threshold: ' int2str(synchchannel) ' ' num2str(threshold) crlf];
   namestr=[namestr 'Samplerate in WAV/Samplerate used : ' num2str([sf sfuse]) crlf];
   
%assume sync off at start of file
lastdat=0;

%cut data stored as MAT file
cutname=[wavfile '_sync'];
namestr=[namestr 'Output cut file: ' cutname crlf];


datlen=12000;
%last incomplete nibble ignored!!!
nibbles=floor(totalsamp/datlen);
sampnum=[1 datlen];
icut=1;

thresha=abs(threshold);
%====================================================
% Main loop
% nibbles thru multiplexed DAT file
%===================================================
for inib=1:nibbles
   disp ([inib nibbles]);
   %data in type as variable
   dat=wavread(wavfile,sampnum);
   dat=dat(:,synchchan);
   ndat=length(dat);

   
    bdat=[lastdat;dat]>thresha;
    bdat=diff(bdat);
    von=find(bdat>0);
    bdat=[lastdat;dat]<(-thresha);
    bdat=diff(bdat);
    voff=find(bdat>0);
    
    if threshold<0
        tmpv=von;
        von=voff;
        voff=tmpv;
    end;
    
   
   lastdat=dat(ndat);

   onoff_flag=[ones(length(von),1);zeros(length(voff),1)];
   vv=[von;voff];
   if ~isempty(vv)
	   [vv,sorti]=sort(vv);
	   onoff_flag=onoff_flag(sorti);
      nv=length(vv);
      disp (['No. of onsets and offsets : ' int2str([length(von) length(voff)])]);
      
      %keyboard;
      xpos=(vv+sampnum(1)-2)./sfuse;     %position in seconds
      for ilsb=1:nv
         if onoff_flag(ilsb)
            %onset
            disp('onset');
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
        end;            %onoff_flag
      end;                %loop thru all pulses
   end;                   %vv not empty
   
   sampnum=sampnum+datlen;

   
   
   
   
end
%================= end of input loop ===================
%
%write cut file as MAT file
[descriptor,unit,valuelabel]=cutstrucn;

%sonycomment=framecomment(sonycomment,'Sony LOG file');


comment=[namestr];
comment=framecomment(comment,functionname);
%check no incomplete cuts??????
totalcuts=icut-1;

if ~isnan(timdat(icut,1))
    disp('Offset missing in last cut');
    totalcuts=icut;
    timdat(icut,2)=(totalsamp-1)/sfuse;
end;


disp (['total cuts : ' int2str(totalcuts)]);

data=timdat(1:totalcuts,:);
label=cutlabel(1:totalcuts,:);
eval (['save ' cutname ' data label descriptor unit comment valuelabel']);


diary dodo
diary off
