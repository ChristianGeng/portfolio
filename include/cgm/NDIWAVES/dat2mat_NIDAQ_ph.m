function dat2mat_NIDAQ(synchFile,daqFile,chanlist,outpath,downfac,coff_file,calstruc)

functionname='dat2mat_NIDAQ: Version 20-Oct-2011';

saveop='';
myver=version;
if myver(1)>'6' saveop='-v6'; end;

timFile=synchFile;
timDat=mymatin(timFile,'data');
private=mymatin(timFile,'private');

sfcorr=mymatin(timFile,'samplerate');

totalcuts=size(timDat,1);
cutlabel=mymatin(timFile,'label');
%exist([timfile,'.mat'])

externalcomment=mymatin(timFile,'comment','No comment in input cut file');
warning off;
synchfileprivate=mymatin(timFile,'private');
warning on;

triallist=unique(timDat(:,4));
maxtrial=max(triallist);

namestr=['Control cut file: ' timFile crlf];
namestr=[namestr 'DAQ file: ' daqFile crlf];

descrTmp=char(private.channels.Name)
descriptor=(descrTmp(chanlist,:))

unit=char(private.channels.MeasurementType)
nchan=length(chanlist); % The channels that need to be extracted from the DAQ file
tmp=load(daqFile,'nchan');
nchanin=tmp.nchan;
%nchanin=mymatin(daqFile,'nchan');

idown=1;
if nargin>4
    if ~isempty(downfac) idown=downfac; end;
end;

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

sftemp=private.NISession.Rate;
dectemp=0; % I don't have the decimation stuff
sfchannel=sftemp/(dectemp+1);

sfbase=sfchannel*nchanin;
sf=sfchannel./idown;
samplerate=sf;
timDat=round(timDat.*sf)./sf;

sfTmpStr=sprintf('%i',sf);
namestr=[namestr 'Channels extracted: ' strm2rv(descriptor,' ') crlf];
namestr=[namestr 'Output sample rate: ' sfTmpStr crlf];
%decimation filter specs:
if ncof
    namestr=[namestr 'Decimation filter file: ' cofname ' ncof: ' int2str(ncof) crlf];
end;
disp(namestr)

unit=char(private.channels.MeasurementType)
unit=cellstr(unit(chanlist,:))


%============================================
%Prepare for calibration to physical values
%=============================================

% CODE UNUSED, ONLY COPIED FROM PHIL %

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


for loop=1:totalcuts % through formerly extracted sweep times 
    timbegin=timDat(loop,1);
    timend=timDat(loop,2);
    mytrial=timDat(loop,4);

    vtr=find(mytrial==triallist);
    
    
     if ~isempty(vtr)
        timlength=timend-timbegin;

        %		keep timbegin as "time of day"
	
        
        item_id=deblank(cutlabel(loop,:));

        disp (['cut#/trial#/label: ' int2str(loop) ' ' int2str(mytrial) ' ' item_id]);
        disp (['Times: ' num2str(timbegin) ' ' num2str(timend)]);
        %position input file at correct offset
        %?????read all data at once for current channel and current sweep
%         filepos=round(timbegin*sfchannel)*framebyt;
        filepos=round(timbegin*sfchannel);
       disp (['Input file byte offset: ' int2str(filepos)]);
%       disp (['starts at % of infile ' num2str(100*(filepos/daqinfo.ObjInfo.SamplesAcquired))]);
       
        %sftemp=daqinfo.ObjInfo.SampleRate;
        sftemp=private.NISession.Rate;
        dectemp=0; % I don't have the decimation stuff
        sfchannel=sftemp/(dectemp+1);

        sfbase=sfchannel*nchanin;
        sf=sfchannel./idown;
        samplerate=sf;



       
        datlen=round(timlength*sfchannel);
        fileend=round(timend*sfchannel);
        %try, 
        %keyboard
        %[data, time, abstime, events, daqinfo]=daqread(daqFile,'Samples',[filepos filepos+datlen],'Channels', [chanlist]);
        DAQDat=load(daqFile,'DAQData');
        %data=DAQDat.DAQData;
        %clear DAQData
        data=mymatin(daqFile,'DAQData');
        data=data(filepos:filepos+datlen,chanlist);
        whos data
        
         if ncof
            %6.00
            %only double if filtering required
            datlen=round(datlen/idown);	%actually tried above to ensure it would be an integer
%             datout=zeros(datlen,nchan); % Phils initialisation seems to
%             fail!
            datout=[];
            for jj=1:nchan
              try, datout(:,jj)=decifir(bcof,double(data(:,jj)),idown); catch, keyboard; end;
            end;
            data=datout;
            clear datout
        end;
        chanmax(loop,:)=max(data);
        chanmin(loop,:)=min(data);
        chanmean(loop,:)=mean(data);
%srcorr
%
%synchFile


        disp(['Channel Max. Amplitude: ',num2str(chanmax(loop,:))]);
%         disp(chanmax(loop,:));
        disp(['Channel Min. Amplitude: ',num2str(chanmin(loop,:))]);
%         disp(chanmin(loop,:));
        disp(['Channel Average Amplitude: ',num2str(chanmean(loop,:))]);
%         disp(chanmean(loop,:));

            disp(['adjust srate, old: ' num2str(samplerate)]) 

            
        
       % if ~isempty (sfcorr)
       %     samplerate=sfcorr(loop);
       % end
        disp(['adjust srate,new: ' num2str(samplerate)]) 

        %'scalefactor','signalzero'
        save([outpath int2str0(mytrial,ndig)],'data','samplerate','comment','descriptor','unit','item_id',saveop);   %turn off version 7 compression
      %    catch, disp('not written'), end
        
        %soundout=soundsc_cg(varargin)
        
%         keyboard
%         disp(['Take care: unsure about sound normalization'])
% Remnants: I do not want to write waves here! Typically in mt2AAA!
%         datnorm=1.0001.*[min(data) max(data)];
%         data2=soundsc_cg(data,datnorm);
%         wavwrite(data2,samplerate,16,[outpath int2str0(mytrial,ndig) '.wav']);
        
%         data2=soundsc_cg(data);
%         wavwrite(data2,samplerate,16,[outpath int2str0(mytrial,ndig) '.wav']);
%         
%         [filepos timlength]
        
        
%         status=fseek(fidin,filepos,'bof');
%         if status~=0
%             disp ('!Bad seek (input)!');
%             return;
        end;
    
end
    

keyboard
