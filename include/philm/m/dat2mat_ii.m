function dat2mat_ii(cmdfile)
% DAT2MAT_II Split multichannel sony mark II DAT files, store as MAT files
% function dat2mat_ii(cmdfile)
% dat2mat_ii: Version 24.9.03
%
% Syntax
%   cmdfile: optional command file. If absent user is prompted to specify one
%
% Description
%   based on splitphx; also similar to mat2stf
%   controlled by input cut file (MAT file)
%   e.g derived from processing of LSB signal
%   All variables in this cut file, e.g label, comment, are copied to output cut file
%   after appropriate modifications to data and comment
%   Selected input channels can be decimated. User must supply MAT file with filter
%   coefficients (must be FIR)
%		One MAT file per trial. Multiple signals per MAT file possible, but must have
%		same sample rate. So if different decimations are applied to the input data
%		the program must be run more than once
%		Keeps the integer format of the input data to save space
%
% See also
%   GETLSB TIMADJ EMMAPROA
%

%following remarks irrelevant for this version ==========
%first version. Program attempts to read all data for 1 channel for 1 cut
% in one go. If memory fails input cuts must be subdivided.
%To reduce the chances of memory problems, 1 pass is made through the
%input file for each channel.
%This may be somewhat slower. On the other hand, a frequent case is expected
% to be extracting 1 channel from a 4-channel file, where this doesn't make
%any difference
%===========================
%Decimation/resampling intended to be included in due course (also easiest
%initially if a complete sweep can be buffered)
% 7.97 Start implementing decimation
% 1.98 Improved facilities for calibrating to physical units
%=======================================
%6.00 Output stored as int16 if no filtering performed
%5.03 use unit prefixes (m, u, k) for calibrated output
%6.03 Use trial number in input cut file (for handling cases where transfer
%from DAT is not all in one chunk
%9.03 get explicit output units for calibrated output (and remove automatic
%prefixes

functionname='dat2mat_ii: Version 24.9.03';
%initialize command file control
cmdarg=0;
if nargin cmdarg=cmdfile;end;
philcom(cmdarg);
%constants, flag values for abart
[abint,abnoint,abscalar,abnoscalar]=abartdef;

%processing details will be appended to comment
namestr=['<Start of Comment> ' functionname crlf];
namestr=[namestr datestr(now,0) crlf];

diary dat2mat_ii.log
%cut file to control extraction of sweeps from long input file
%should be set up so that all times are an integer multiple of the
%sample interval of the signal with the lowest samplerate
%This could either be separately acquired data, of signals resulting
%after downsampling of the DAT data
%
%The labels in this cut file will be copied to the output cut file
%These are included automatically by timadj

timfile=philinp('MAT file with input cuts: ');
timdat=mymatin(timfile,'data');
totalcuts=size(timdat,1);
cutlabel=mymatin(timfile,'label');
externalcomment=mymatin(timfile,'comment','No comment in input cut file');

%only used when processing a selection of trials (for calibrated data)
triallist=unique(timdat(:,4));
maxtrial=max(triallist);


namestr=[namestr 'Control cut file: ' timfile crlf];

fidin=0;
while fidin<=2
    infile=philinp('Multiplexed Sony input file (without extension -  .BIN and .LOG files required) : ');
    [fidin,message]=fopen([infile '.bin'],'r');
    if ~isempty(message) disp(message); end
end
%namestr=[namestr 'Sony file: ' infile crlf];
%bytes per sample for input file
datbyt=2;
indatatype='short';

sonycomment=readtxtf([infile '.log']);
disp(sonycomment);
namestr=[namestr '<Sony LOG file start>' crlf sonycomment crlf '<Sony LOG file start>' crlf];

%convert log file to string matrix, then parse for channel info
sonylogmat=rv2strm(sonycomment,crlf);
[sony_chn,sony_desc,sony_unit,sony_scalefactor,sony_signalzero,sony_chrange]=sonych(sonylogmat);

nchanin=length(sony_chn);

[descriptor,chanlist]=abartstr ('Channels to extract (blank-separated list of names)',sony_desc,sony_desc,abnoscalar);
nchan=max(size(chanlist));

%may not be needed. Depends how calibration is handled
chanrange=sony_chrange(chanlist);

%will need upgrading for resampling, e.g get 2-element vector
idown=abart('Downsampling factor',1,1,1000,abint,abscalar);
%make coefficient file optional if idown==1


cofname=philinp('Coefficient MAT file (optional if not downsampling) : ');
ncof=0;
if ~isempty(cofname)
    bcof=mymatin(cofname,'data');
    filtcomment=mymatin(cofname,'comment','<No filter comment>');
    ncof=length(bcof);
else
    if idown~=1
        disp('Unable to continue without filter file!');
        return;
    end;
end;



%sfbase is overall data rate
%sfchannel is samplerate of each channel in the input file
%sf output sample rate for each channel
%i.e will be different from sfchannel if downsampling is performed
sftemp=eval(strtok(getsonyf(sonylogmat,'TAPE_SRATE_CH')));
dectemp=eval(getsonyf(sonylogmat,'DECIMATION'));
sfchannel=sftemp/(dectemp+1);
sfbase=sfchannel*nchanin;
sf=sfchannel./idown;
samplerate=sf;
framebyt=datbyt*nchanin;

%adjust input time data to be integer multiples of channel sample interval (after any decimation)
timdat=round(timdat.*sf)./sf;


namestr=[namestr 'Channels extracted: ' strm2rv(descriptor,' ') crlf];
namestr=[namestr 'Output sample rate: ' num2stre(sf) crlf];
%decimation filter specs:
if ncof
    namestr=[namestr 'Decimation filter file: ' cofname ' ncof: ' int2str(ncof) crlf];
end;

%because of headroom (2.5 dB) nominal fsd is at this value, not at 2**15
fsdval=24576;
scalefactor=chanrange./fsdval;
%
signalzero=zeros(1,nchan);

unit=sony_unit(chanlist,:);
unit=cellstr(unit);
%============================================
%calibration to physical values
%Uses channel range settings
%could be replaced by sony scalefactor and signalzero
%=============================================


califlag=upper(philinp('Calibrate to physical values ? [N] '));
if strcmp(califlag,'Y')
    %note: Voltages specified at input to DAT recorder
    %      i.e actual output voltage of the transduction system
    
    for ido=1:nchan
        disp ([]);
        v_ref=abart('Enter a pair of reference voltages (as row vector)',1,-1000,1000,abnoint,abnoscalar);
        p_ref=abart('Enter corresponding pair of physical values',1,-1000000,1000000,abnoint,abnoscalar);
        
        outunit=abartstr('Output units','V');      
        %various checks??????
        
        sss=['Input Channel ' int2str(chanlist(ido)) '. Reference voltages and values: ' num2stre([v_ref p_ref],5)];
        disp(sss);
        namestr=[namestr sss crlf];
        
        physfac=diff(p_ref)./diff(v_ref);
        scalefactor(ido)=scalefactor(ido)*physfac;
        signalzero(ido)=(p_ref(1)-(v_ref(1)*physfac));
        disp(['Resulting scalefactor and signal zero: ' num2stre([scalefactor(ido) signalzero(ido)],5)]);
        
        unit{ido}=outunit;
        %assumes physical values calculated as follows (cf. scaleit.m):
        %signalzero+(rawvalue*scalefactor)
    end;
    
    %for calibrated data allow processing to be restricted to a selection of
    %trials (in case calibration changes)
    procflag=upper(philinp('Process all trials ? [Y] '));
    if strcmp(procflag,'N')
        triallist=abart('Enter list of trials',1,1,maxtrial,abint,abnoscalar);
    end;
    
end;

unit=char(unit);

%
%cut data stored as MAT file
cutname=philinp('Output CUT file name: ');
[mystat,msg]=copyfile([timfile '.mat'],[cutname '.mat']);
if ~isempty(msg)
    disp('Problem copying cut file?');
    disp(msg);
    return;
end;

outpath=philinp('Common part of output MAT file name: ');


namestr=[namestr 'Output cut file: ' cutname crlf];
namestr=[namestr 'Output file path: ' outpath crlf];


namestr=[namestr 'Comment from control cut file===========' crlf];
namestr=[namestr externalcomment crlf];
namestr=[namestr '<End of Comment> ' functionname crlf];
comment=namestr;



chanmax=zeros(totalcuts,nchan);
chanmin=chanmax;
chanmean=chanmax;

%initialize cut buffer
cutdata=zeros(totalcuts,4);
cutdata(:,2)=timdat(:,2)-timdat(:,1);
%changed 6.03
%cutdata(:,4)=(1:totalcuts)';
cutdata(:,4)=timdat(:,4);

%put adjusted cut data and comment in output cut file
%set up output cut file from input cut file and cutlabel

data=cutdata;
save(cutname,'data','comment','-append','-v6');     %turn off compression in v7


%%%check out??
%may be better to use:
ndig=length(int2str(max(cutdata(:,4))));	%i.e trial number, also not quite foolproof in complicated cases
%ndig=length(int2str(totalcuts));		%for trial number in file name      


%disabled, but may be useful again for quick single channel extraction

%use skip function in fread to select 1 input channel from complete record

%skipbytes=(nchanin-1)*datbyt;

%====================================================
% Main loop
%through trials
%===================================================
%          chanoffb=(chanlist(ichan)-1)*datbyt;
for loop=1:totalcuts
    timbegin=timdat(loop,1);timend=timdat(loop,2);
    mytrial=timdat(loop,4);
    
    vtr=find(mytrial==triallist);
    if ~isempty(vtr)
        timlength=timend-timbegin;
        
        %		keep timbegin as "time of day"
        item_id=deblank(cutlabel(loop,:));
        
        disp (['cut#/trial#/label: ' int2str(loop) ' ' int2str(mytrial) ' ' item_id]);
        disp (['Times: ' num2str(timbegin) ' ' num2str(timend)]);
        %position input file at correct offset
        %?????read all data at once for current channel and current sweep
        filepos=round(timbegin*sfchannel)*framebyt;
        %disabled              filepos=filepos+chanoffb;
        disp (['Input file byte offset: ' int2str(filepos)]);
        datlen=round(timlength*sfchannel);
        status=fseek(fidin,filepos,'bof');
        if status~=0 
            disp ('!Bad seek (input)!');
            return;
        end;
        
        %              dat=fread(fidin,datlen,indatatype,skipbytes);
        %   data=fread(fidin,[nchanin,datlen],indatatype);
        %6.00 for long recordings not divided into trials???
        data=int16(fread(fidin,[nchanin,datlen],indatatype));
        data=(data(chanlist,:))';
        datgot=size(data,1);
        iocode=showferr(fidin,'DAT file read');
        if datgot < datlen
            disp ('Read incomplete??');
            disp ([datlen datgot]');
            keyboard;
            return;   
        end
        %process the data, esp. downsample
        %loop thru channels
        
        if ncof
            %6.00
            %only double if filtering required
            datlen=round(datlen/idown);	%actually tried above to ensure it would be an integer
            datout=zeros(datlen,nchan);
            for jj=1:nchan
                
                
                datout(:,jj)=decifir(bcof,double(data(:,jj)),idown);
            end;
            data=datout;
        end;
        
        
        chanmax(loop,:)=max(data);
        chanmin(loop,:)=min(data);
        chanmean(loop,:)=mean(data);
        
        disp('Max');
        disp(chanmax(loop,:));
        disp('Min');
        disp(chanmin(loop,:));
        disp('Mean');
        disp(chanmean(loop,:));
        
        %get trialnumber explicitly from cutdata, rather than implicitly from loop?   
        %implemented 6.03
        
        save([outpath int2str0(mytrial,ndig)],'data','samplerate','comment','descriptor','unit','scalefactor','signalzero','item_id','-v6');   %turn off version 7 compression
        
        
    end;        %trial selection   
end                            %end of cut loop

fclose(fidin);

disp('Overall max');
disp(max(chanmax));
disp('Overall min');
disp(min(chanmin));
disp('Overall mean');
disp(mean(chanmean));


%cf. emmaproa, should use standardized variables
eval(['save ' outpath 'sta comment descriptor unit chanmax chanmin chanmean -v6']);


diary dodo
diary off
