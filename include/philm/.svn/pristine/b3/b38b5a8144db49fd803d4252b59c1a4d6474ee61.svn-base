function dat2mat_ii_fx(synchfile,sonyfile,chanlist,outpath,downfac,coff_file,calstruc)
% DAT2MAT_II_FX Split multichannel sony mark II DAT files, store as MAT files
% function dat2mat_ii_fx(synchfile,sonyfile,chanlist,outpath,idown,coff_file,calstruc)
% dat2mat_ii_fx: Version 27.2.08
%
% Syntax
%   synchfile: cut file to control extraction, e.g from getlsbc_ii_f
%       Trial numbers of the output files are determined by the value in
%       the fourth column of the data variable in synchfile
%   sonyfile: Name of sony file (without extension. BIN and LOG must be available
%   chanlist: Numbers of channels to extract
%   outpath: Common part of output file name
%   Following arguments are optional. Use empty variable as placeholder if
%   necessary
%   downfac: Downsampling factor. Default is 1
%   coff_file: FIR file with which to filter data. Required if idown>1
%   calstruc: Structure specifying calibration to physical values
%       It must have fields ref_voltage, physical_value and output_units
%       entries correspond to the channels in chanlist (i.e the list of
%       output channels)
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
%   GETLSBC_II_F Get synchronization information (including from LSB signal
%   of Sony multichannel DATs)
%   ADDLABCMT2SYNC_F Add comment and labels to
%   synch file (used for comment and item_id variables of dat2mat_ii_f
%   output). Also determines the trial numbers in the synch file
%   GETXMX
%
% Description
%   Long files from Sony data acquisition front ends are split into
%   separate trials based on information in synchfile for storage as MAT
%   files
%   If no filtering or calibration is performed the data is stored in the
%   same format as in the input file (i.e int16 if coming from the PC208
%   etc DATs). Otherwise it is stored as single and any scaling factors and
%   offsets are resolved, so that the output data is in physical units.
%
%   Updates
%       2.08 Implement private variable. Try and read info file from getxmx to include in it.
%           Also put sony log file text in private rather than in comment
%           (also essentially the same text from the the synchfile if
%           possible)
%       27.2.08 First test of calibration input specs; also placed in
%       private

functionname='dat2mat_ii_fx: Version 27.2.08';

datatypelist=str2mat('int8','int16','single');
datatypelengthlist=[1 2 4];
%see also the fixformatspec function below



%log file disabled?
%diary dat2mat_ii.log

saveop='';
myver=version;
if myver(1)>'6' saveop='-v6'; end;


timfile=synchfile;
timdat=mymatin(timfile,'data');
totalcuts=size(timdat,1);
cutlabel=mymatin(timfile,'label');
externalcomment=mymatin(timfile,'comment','No comment in input cut file');
warning off;
synchfileprivate=mymatin(timfile,'private');
warning on;
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

sonycomment=readtxtf([infile '.log']);
disp(sonycomment);

private=[];

if exist([sonyfile '_info.mat'],'file')
    private=mymatin([sonyfile '_info'],'private');
end;

%probably two virtually identical log files
private.dat2mat_ii_fx.sonylogfile=sonycomment;
private.dat2mat_ii_fx.synchfileprivate=synchfileprivate;




%sonycomment=framecomment(sonycomment,'Sony LOG file');

%namestr=[namestr sonycomment];

%convert log file to string matrix, then parse for channel info and format
%info
sonylogmat=rv2strm(sonycomment,crlf);

indatatype=getsonyf(sonylogmat,'FORMAT');
indatatype=fixformatspec(indatatype);

vv=strmatch(indatatype,datatypelist);
if length(vv)~=1
    disp('Unsupported input data type');
    disp(indatatype);
    return;
end;
datbyt=datatypelengthlist(vv);






[sony_chn,sony_desc,sony_unit,sony_scalefactor,sony_signalzero,sony_chrange]=sonych(sonylogmat);

nchanin=length(sony_chn);

descriptor=sony_desc(chanlist,:);

nchan=length(chanlist);

%may not be needed. Depends how calibration is handled
%chanrange=sony_chrange(chanlist);

scalefactor=sony_scalefactor(chanlist);
signalzero=sony_signalzero(chanlist);



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

%preferred way of getting samplerate??
%sftmp=str2num(strtok(getsonyf(sonylogmat,'FILE_INTVL_CH')));



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


%Replaced: Can simply use sony scalefactor and signalzero
%because of headroom (2.5 dB) nominal fsd is at this value, not at 2**15
%fsdval=24576;
%scalefactor=chanrange./fsdval;
%
%signalzero=zeros(1,nchan);

unit=sony_unit(chanlist,:);
unit=cellstr(unit);

%============================================
%Prepare for calibration to physical values
%=============================================


califlag=0;
if nargin>6
    califlag=1;
    %note: Voltages specified at input to DAT recorder
    %      i.e actual output voltage of the transduction system

    v_ref=calstruc.ref_voltage;
    p_ref=calstruc.physical_value;
    outunit=calstruc.output_units;
    
    for ido=1:nchan

        tmpunit=deblank(outunit(ido,:));

        sss=['Input Channel ' int2str(chanlist(ido)) '. Reference voltages and values: ' num2stre([v_ref(ido,:) p_ref(ido,:)],5) ' . Output units ' tmpunit];
        disp(sss);
        namestr=[namestr sss crlf];


        unit{ido}=tmpunit;
    end;

    %for calibrated data allow processing to be restricted to a selection of
    %trials (in case calibration changes)
    if isfield(calstruc,'trial_list')
        triallist=calstruc.trial_list;
        disp('Using trial list from calibration structure');
    end;

    private.dat2mat_ii_fx.calstruc=calstruc;

end;

unit=char(unit);

%
namestr=[namestr 'First, last, total trials processed : ' int2str([triallist(1) triallist(end) length(triallist)]) crlf];



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

        disp (['cut#/trial#/label: ' int2str([loop mytrial]) ' ' item_id]);
        disp (['Times: ' num2str([timbegin timend])]);
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

        data=fread(fidin,[nchanin,datlen],['*' indatatype]);
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

%this must be reset to the input value here as it will be set to 1 and 0
%during filtering or calibration
        scalefactor=sony_scalefactor(chanlist);
        signalzero=sony_signalzero(chanlist);


        
        change2single=0;
        if ncof
            datlen=round(datlen/idown);	%actually tried above to ensure it would be an integer
            datout=zeros(datlen,nchan);
            data=double(data);
            for jj=1:nchan

                tmpd=(data(:,jj)*scalefactor(jj)) + signalzero(jj);

                datout(:,jj)=decifir(bcof,tmpd,idown);
                scalefactor(jj)=1;
                signalzero(jj)=0;
            end;
            data=datout;
            change2single=1;
        end;


        %apply calibration to data, not just to scalefactors

        if califlag
            data=double(data);

            for jj=1:nchan
                tmpd=(data(:,jj)*scalefactor(jj)) + signalzero(jj);
                tmpd=interp1(v_ref(jj,:),p_ref(jj,:),tmpd,'linear','extrap');
                data(:,jj)=tmpd;
                scalefactor(jj)=1;
                signalzero(jj)=0;
            end;    %channel loop
            change2single=1;
        end    %califlag

        chanmax(loop,:)=max(data);
        chanmin(loop,:)=min(data);
        chanmean(loop,:)=mean(data);

        disp('Max');
        disp(chanmax(loop,:));
        disp('Min');
        disp(chanmin(loop,:));
        disp('Mean');
        disp(chanmean(loop,:));

        if change2single data=single(data); end;
        save([outpath int2str0(mytrial,ndig)],'data','samplerate','comment','descriptor','unit','scalefactor','signalzero','item_id','private',saveop);   %turn off version 7 compression


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
function usedspec=fixformatspec(inputspec)
%this is the specification required for int16 if the pcscanii program is to
%be used to display data
usedspec=strrep(inputspec,'0 INTEL-86','int16');
