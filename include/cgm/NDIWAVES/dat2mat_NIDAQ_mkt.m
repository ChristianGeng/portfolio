function dat2mat_NIDAQ_mkt(synchFile,recpath,chanlist,exampleFile,outpath,ndig,downfac,coff_file,calstruc)
% dat2mat_NIDAQ(synchFile,daqFile,chanlist,outpath,downfac,coff_file,calstruc)
% Renaming scheme
% chanlist: Channels that need to be extracted from the DAQ file
%
% Gepspeichert wird aufgrund der item_id
% Gelesen wird aus dem timFile(=synchFile)
% 21-Jun-2012: 
% + error caused by negative start indices
% + Reorganized code to output correct filename in case of
% warning or error
% 
% SEE ALSO dat2mat_NIDAQ_mkt.
%
%  updated $21-Jun-2012$ CGeng
%
%

functionname='dat2mat_NIDAQ: Version 20-Oct-2011';
warning('off','all');

saveop='-v7';
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
%warning on;

triallist=unique(timDat(:,4));
maxtrial=max(triallist);

namestr=['Control cut file: ' timFile crlf];
namestr=[namestr 'DAQ file: ' recpath crlf];

if ismatlab
  descrTmp=char(private.NIDAQ.channels.Name);
  unit=char(private.NIDAQ.channels.MeasurementType);
  sftemp=private.NIDAQ.NISession.Rate;
elseif isoctave
  descrTmp=mymatin(timFile,'channelNames');
  unit=mymatin(timFile,'measurementType');
  sftemp=mymatin(timFile,'samplerate');
end

descriptor=(descrTmp(chanlist,:));


idown=1;
if nargin>6
    if ~isempty(downfac) idown=downfac; end;
end;

ncof=0;

if nargin>7
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


dectemp=0; % I don't have the decimation stuff


nchan=length(chanlist); % The channels that need to be extracted from the DAQ file

theinfile=[recpath int2str0vec(exampleFile)];
tmp=load([recpath int2str0vec(exampleFile)],'nchan'); %daqFile
disp(['loading File ' theinfile]);
nchanin=tmp.nchan;

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

%unit=char(private.NIDAQ.channels.MeasurementType); % OCTAVE, see above
unit=cellstr(unit(chanlist,:));


%============================================
%Prepare for calibration to physical values
%=============================================

% CODE UNUSED, ONLY COPIED FROM PHIL %

califlag=0;
if (nargin>8 && isstruct(calstruc))
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
    
    
    return
    %for calibrated data allow processing to be restricted to a selection of
    %trials (in case calibration changes)
    if isfield(calstruc,'trial_list')
        triallist=calstruc.trial_list;
        disp('Using trial list from calibration structure');
    end;
    
    private.dat2mat_ii_fx.calstruc=calstruc;
    
end;


unit=char(unit);
namestr=[namestr 'First, last, total trials processed : ' int2str([triallist(1) triallist(end) length(triallist)]) crlf];
namestr=[namestr 'Output file path: ' outpath crlf];

externalcomment=framecomment(externalcomment,'Comment from synch file');
namestr=[namestr externalcomment];
comment=namestr;
comment=framecomment(comment,functionname);

chanmax=zeros(totalcuts,nchan);
chanmin=chanmax;
chanmean=chanmax;
timdebug=0;

for loop=1:totalcuts % through formerly extracted sweep times
    
    item_id=deblank(cutlabel(loop,:));
    try,
        % for the cases in which label has been saved as a numeric
        % array
        outFnum=int2str0vec(item_id,ndig);
    catch,
        outFnum=int2str0vec(str2num(item_id),ndig);
    end
    
    
    outFileName=[outpath outFnum];
    
    timbegin=timDat(loop,1);
    timend=timDat(loop,2);
    mytrial=timDat(loop,4);
    
    % timFile ist hier = Synchfile. Der gelesene File wird aus "data" aus dem
    % gecutteten synchFile extrahiert
    tmpFile=[recpath int2str0vec(timDat(loop,4))];
    
%     disp([ tmpFile ' -> ' outFileName]);
    
    
    
    vtr=find(mytrial==triallist);
    
    
    if ~isempty(vtr)
        timlength=timend-timbegin;
        
        %		keep timbegin as "time of day"
        
        
        
        %position input file at correct offset
        %?????read all data at once for current channel and current sweep
        %         filepos=round(timbegin*sfchannel)*framebyt;
        filepos=round(timbegin*sfchannel);
        
        
        if timdebug
            disp (['cut#/trial#/label: ' int2str(loop) ' ' int2str(mytrial) ' ' item_id]);
            disp (['Times: ' num2str(timbegin) ' ' num2str(timend)]);
            disp (['Input file byte offset: ' int2str(filepos)]);
            %       disp (['starts at % of infile ' num2str(100*(filepos/daqinfo.ObjInfo.SamplesndigAcquired))]);
        end
        %private.NIDAQ.NISession.Rate;
        dectemp=0; % I don't have the decimation stuff
        sfchannel=sftemp/(dectemp+1);
        
        sfbase=sfchannel*nchanin;
        sf=sfchannel./idown;
        samplerate=sf;
        datlen=round(timlength*sfchannel);
        fileend=round(timend*sfchannel);
        
        
        
        DAQDat=load(tmpFile,'DAQData');
        
        %data=DAQDat.DAQData;
        %clear DAQData
        data=mymatin(tmpFile,'DAQData');
       
        try,
            data=data(filepos:filepos+datlen,chanlist);
        catch
            warning(['!!!!truncating : ' num2str(((filepos+datlen)-length(data))/samplerate) ' secs. File likely to be corrupted!'])
            disp(filepos)
            
            if (filepos<1)
                warning('!!!index negative, probably synch pulses are problematic, file likely to be corrupted!');
                continue;
            else,
                data=data(filepos:length(data),chanlist);
                datlen=length(data);
            end;


            
            
        end
        
        if ncof
            datlen=round(datlen/idown);	%actually tried above to ensure it would be an integer
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
        
        voltdebug=0;
        if voltdebug
            disp(['channel max. amplitude: ',num2str(chanmax(loop,:))]);
            %         disp(chanmax(loop,:));
            disp(['channel min. amplitude: ',num2str(chanmin(loop,:))]);
            %         disp(chanmin(loop,:));
            disp(['channel average amplitude: ',num2str(chanmean(loop,:))]);
            %         disp(chanmean(loop,:));
        end
        
        disp([ tmpFile ' -> ' outFileName]);
        save([outFileName, '.mat'],'data','samplerate','comment','descriptor','unit','item_id',saveop); 
        
    end;
    
end


