%function getsynchWaveNIDAQ_mktToNDIMaster(daqFile,smpte_chn_NI,NDIsessionroot,smpte_chn_WAVE,session,sessfile, skiptrials,audiooffset)
function getsynchWaveNIDAQ_mktToNDIMaster(NIDAQSmpteFile,recpathNIDAQ,NDIWaveSmpteFile,NDIsessionRoot,session,sessfile)
%
% Trial number might be incorrect
% so far this is  a version for just one large DAQ file
%  smpte_chn_NI: channel on the NI daq file

namestr='';

diaryname=[recpathNIDAQ rmextension(mfilename) '.log'];
diary(diaryname);

functionname=[rmextension(mfilename), ': Version 20-Oct-2011'];
disp(functionname);

sesscfg=NDIWaveParseSessionFile(sessfile);
private.sesscfg=sesscfg;


load(NIDAQSmpteFile);
load(NDIWaveSmpteFile);

cutname=[NIDAQSmpteFile '_syncCh',num2str(smpte_chn_NI)];
disp(['using cutfile ' cutname]);

NDIFirstFrames=cat(1,NDIWavRAW.smpteFirstFrame);
NDILastFrames=cat(1,NDIWavRAW.smpteLastFrame);

NIFirstFrames=cat(1,NIDAQSmpteRaw.smpteFirstFrame);
NILastFrames=cat(1,NIDAQSmpteRaw.smpteLastFrame);

[descriptor,unit,valuelabel]=cutstrucn;

ndig=4;

totalcuts=0;
maxCuts=20000;
data=nan(maxCuts,4);
data(:,3)=0;


% The part of the code in the outer loop matches the trials 
% This is a between trial problem resulting in the correct trial number 
% 

misslistindex=0;

for ll= 1:length(NDIWavRAW)
% for ll=432:434 
    
    % JJ=find(hhmmssff2num(NILastFrames(ll,1:4))-hhmmssff2num(NILastFrames(:,1:4))>0);

    % KK: 
    % Fuer welche NI-Trials ist der erste NDI Synch-Sample des momentanen Trials SPAETER als der erste
    % NIDAQ sample aller Trials?
    % Das sollte beim ersten NDI-Trial fuer das erste Sample der Fall sein,
    % beim zweiten NDI-Trial fuer die ersten beiden NI-Trials usw.
    %
    KK=find(hhmmssff2num(NDIFirstFrames(ll,1:4))-hhmmssff2num(NIFirstFrames(:,1:4))>0);
    
    % JJ: 
    % Fuer welche NI-Trials ist der letzte Sample spaeter als der letzte
    % NDI Sample des momentanen NDI-Trials?
    % Das sollte erst mal alle sein, dann entsprechend weniger!
    % Am Ende ist es jetzt ein >=, damit man am Ende bei Codegleichheit
    % noch was extrahieren kann. Moeglicherweise sollte man aehnliches bei
    % der Berechnung von KK auch tun! To be seen. 
    JJ=find(hhmmssff2num(NILastFrames(:,1:4)) - hhmmssff2num(NDILastFrames(ll,1:4)) >=0);
    
    % II: 
    % Die Intersection zwischen den beiden sollte eigentlich nur EINEN
    % EINZIGEN TRIAL ergeben!
    % Wenn mehr, dann ist was faul. 
    
    II=intersect(JJ,KK);

    
    if ~isempty(II)
        IIold=II;
        disp(['found ' num2str(length(II)) ' trial(s).'])
        totalcuts=totalcuts+1;
        disp([NDIsessionRoot session '/rawdata/' NDIWavRAW(ll).name '  <->  ' recpathNIDAQ  NIDAQSmpteRaw(II).name])
        
        % extracting 
        ssFile=[NDIsessionRoot session '/rawdata/' NDIWavRAW(ll).name ];
        [dataSYNCH,samplerate,NBITS]=wavread([ssFile]);
        [smpteNDIWAVE smpteNDIWAVE_str,errN] = SMPTE_dec(dataSYNCH(:,2),samplerate,25,0);
        smpteNDIWAVEDur=smpteNDIWAVE(end,end)-smpteNDIWAVE(1,end);
        
        
        %% NIDAQ
        
        NIDAQ=load([recpathNIDAQ NIDAQSmpteRaw(II).name]);
        % [smpte_NI smpte_str_NI,errN_NI] = SMPTE_dec(NIDAQ.DAQData(:,smpte_chn_NI),NIDAQ.srate,25,0);
        soundout=soundsc_cg(NIDAQ.DAQData(:,smpte_chn_NI),NIDAQ.srate);
        [smpte_NI smpte_str_NI,errN_NI] = SMPTE_dec(soundout,NIDAQ.srate,25,0);
        clear c, clear iNIDAQ, clear iWAVE;      
        [c,iNIDAQ,iWAVE]=intersect(smpte_NI(:,1:4),smpteNDIWAVE(:,1:4),'rows');
        
        try,
            TStartNIDAQ=smpte_NI(iNIDAQ([1]),5)-smpteNDIWAVE(iWAVE([1]),5);
            disp(['Offset into NI frame: ' num2str(round(TStartNIDAQ*1000)) 'ms.'])
           
            % Endpoint of NI Sample - Use the duration of already synched wav-File to calculate NIDAQ-EOF:
            wavduration=length(dataSYNCH)/samplerate;
            TEndNIDAQ=TStartNIDAQ+wavduration;
            data(totalcuts,1)=TStartNIDAQ;
            data(totalcuts,2)=TEndNIDAQ;
            data(totalcuts,4)=II(end);
            
            myregexp=['(\d{' num2str(3) ',' num2str(ndig) '}.wav)'];
            %[startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(NDIWavRAW(ll).name, myregexp);
            [matchStr] = regexp(NDIWavRAW(ll).name, myregexp,'match');
	    [dum1,tmplabstr]=fileparts(char(matchStr));
            
            label(totalcuts,:)=tmplabstr;
            % label=int2str0vec(tmplabel');
            samplerate=NIDAQ.srate;
            private.NIDAQ=NIDAQ.private; % does not work for octave
	    measurementType=char(NIDAQ.private.channels.MeasurementType);
	    channelNames=char(NIDAQ.private.channels.Name);
	    %descrTmp=char(private.NIDAQ.channels.Name);
	    %unit=char(private.NIDAQ.channels.MeasurementType);
	    %sftemp=private.NIDAQ.NISession.Rate;



            % NIDAQInfo=NIDAQ.private;
            data(totalcuts+1:end,:)=[];
            disp(['start/end/duration of NI frame(s): ' num2str(TStartNIDAQ), '/', num2str(TEndNIDAQ) '/' num2str(wavduration)]);
            
            %eval (['save ' cutname ' data label descriptor unit comment
	    %valuelabel samplerate private']);

	    

	    
	    if ismatlab
	      save([cutname,'.mat'],'-v7','data','label','descriptor','unit','comment','valuelabel','samplerate','sesscfg','private');
	    elseif isoctave
       	      save([cutname,'.mat'],'-v7','data','label','descriptor','unit','comment','valuelabel','samplerate','sesscfg','channelNames','measurementType');
	    end

        catch
            warning(lasterr)
            disp('problem in SMPTE code?')
            disp(['NDI first/last: ' num2str(NDIFirstFrames(ll,1:4)) ' - ' num2str(NDILastFrames(ll,1:4))])
            keyboard
        end
        clear TStartNIDAQ; TEndNIDAQ;  clear wavduration;
    else, 
        msg=['No intersection found for trial No. ' num2str(ll)  ' in list, trial not processed'];
        warning(msg);
        misslistindex=misslistindex+1;
        misslist{misslistindex,1}=ll;
        misslist{misslistindex,2}=msg;
%         keyboard
    end
end


data(totalcuts+1:end,:)=[];
I=find(data(:,4)==0);
data(I,:)=[];
label(I,:)=[];

% eval (['save ' cutname ' data label descriptor unit comment valuelabel samplerate private']);
% save([cutname,'.mat'],'-v7','data','label','descriptor','unit','comment','valuelabel','samplerate','sesscfg');

if ismatlab
  save([cutname,'.mat'],'-v7','data','label','descriptor','unit','comment','valuelabel','samplerate','sesscfg','private');
elseif isoctave
  save([cutname,'.mat'],'-v7','data','label','descriptor','unit','comment','valuelabel','samplerate','sesscfg','channelNames','measurementType');
end


diary off

return
