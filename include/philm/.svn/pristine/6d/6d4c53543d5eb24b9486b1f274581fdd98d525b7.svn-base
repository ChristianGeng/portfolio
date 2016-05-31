function dat2mat_ii_f(synchfile,sonyfile,chanlist,outpath,downfac,coff_file,cal_struc)
% DAT2MAT_II_F Split multichannel sony mark II DAT files, store as MAT files
% function dat2mat_ii_f(synchfile,sonyfile,chanlist,outpath,idown,coff_file,cal_struc)
% dat2mat_ii_f: Version 4.12.05
%
% Syntax
%   synchfile: cut file to control extraction, e.g from getlsbc_ii_f
%   sonyfile: Name of sony file (without extension. BIN and LOG must be
%   available
%   chanlist: Numbers of channels to extract
%   outpath: Common part of output file name
%   Following arguments are optional. Use empty variable as placeholder if
%   necessary
%   downfac: Downsampling factor. Default is 1
%   coff_file: FIR file with which to filter data. Required if idown>1
%   cal_struc: Structure specifying calibration to physical values
%       It must have fields ref_voltage, physical_value and output_units
%       entries correspond to input or output channels
%       ref_voltage: nchan*2 matrix specifying a pair of reference voltages
%       physical_value: nchan*2 matrix specifying corresponding physical
%       values
%       output_units: string matrix giving output unit for each channel
%       There is an additional optional field: trial_list
%       If present this specifies the trials to process. Can be used if
%       calibration does not stay the same for the whole experiement
%   Unlike older versions, a cut file for the output data is not generated
%   If necessary use MAKECUTFILE
%
% See also
%   GETLSBC_II_F

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

functionname='dat2mat_ii: Version 4.12.05';

%processing details will be appended to comment

%diary dat2mat_ii.log
%cut file to control extraction of sweeps from long input file
%should be set up so that all times are an integer multiple of the
%sample interval of the signal with the lowest samplerate
%This could either be separately acquired data, of signals resulting
%after downsampling of the DAT data
%
%The labels in this cut file will be copied to the output cut file
%These are included automatically by timadj

saveop='';
myver=version;
if myver(1)>'6' saveop='-v6'; end;


timfile=synchfile;
timdat=mymatin(timfile,'data');
totalcuts=size(timdat,1);
cutlabel=mymatin(timfile,'label');
externalcomment=mymatin(timfile,'comment','No comment in input cut file');

%only used when processing a selection of trials (for calibrated data)
triallist=unique(timdat(:,4));
maxtrial=max(triallist);


namestr=['Control cut file: ' timfile crlf];

infile=sonyfile;
[fidin,message]=fopen([infile '.bin'],'r');
if ~isempty(message)
    disp(message);
    return
end
namestr=[namestr 'Sony file: ' infile crlf];
%bytes per sample for input file
datbyt=2;
indatatype='short';

sonycomment=readtxtf([infile '.log']);
disp(sonycomment);
sonycomment=framecomment(sonycomment,'Sony LOG file');

namestr=[namestr sonycomment];

%convert log file to string matrix, then parse for channel info
sonylogmat=rv2strm(sonycomment,crlf);
[sony_chn,sony_desc,sony_unit,sony_scalefactor,sony_signalzero,sony_chrange]=sonych(sonylogmat);

nchanin=length(sony_chn);

descriptor=sony_desc(chanlist,:);

nchan=length(chanlist);

%may not be needed. Depends how calibration is handled
chanrange=sony_chrange(chanlist);

%will need upgrading for resampling, e.g get 2-element vector
idown=1;
if nargin>4
    if ~isempty(downfac) idown=downfac; end;
end;

%coefficient file optional if idown==1


ncof=0;

if nargin>5
    cofname=coff_file;

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


califlag=0;
if nargin>6
    califlag=1;
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



namestr=[namestr 'Output file path: ' outpath crlf];

externalcomment=framecomment(externalcomment,'Comment from synch file');
namestr=[namestr externalcomment];
comment=namestr;

comment=framecomment(comment,functionname);

chanmax=zeros(totalcuts,nchan);
chanmin=chanmax;
chanmean=chanmax;


%%%check out??
%may be better to use:
ndig=length(int2str(max(maxtrial)));	%i.e trial number, also not quite foolproof in complicated cases


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


        save([outpath int2str0(mytrial,ndig)],'data','samplerate','comment','descriptor','unit','scalefactor','signalzero','item_id',saveop);   %turn off version 7 compression


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
eval(['save ' outpath 'sta comment descriptor unit chanmax chanmin chanmean ' saveop]);


%diary dodo
%diary off
