function extractNIDAQsmpte( daqPath,smpte_chn_NI)
% extractNIDAQsmpte: Extract the SMPTE code from National Instruments Files
%   and saves it to daqPath under filename smpte_raw.mat
% 
% Uses SMPTE_dec.m by Javier Jaimovich (2011) which is distributed via the
% svn repo.
% 
% Inputs:
% daqPath: Common part of DAQ signal
% smpte_chn_NI: Which channel contains the SMPTE code? 
% 
% 07-Jun-2012: account for cese sensitivity starting with Matlab R20012a
% (function fileparts).
% 
% SEE ALSO SMPTE_dec
% 
% Version $21-Jun-2012$, CG
% 
% Changelog: 
% $21-Jun-2012$: experimental median filter (not used by default) 


doMedFilt=0;

NIDAQSmpteRaw=dir([daqPath,'*.mat'])
[pathStr,fName,ext] = fileparts(daqPath);

diary([pathStr pathchar 'smpte_raw.log']);

errN_NI=NaN; % when SMPTE does not work for first trial  

misslIdx=0;
missNIDAQ={''}

for fnum=1:length(NIDAQSmpteRaw)
    infile=[pathStr pathchar NIDAQSmpteRaw(fnum).name];
    NIDAQ=load(infile);
    
    try
        soundout=soundsc_cg(NIDAQ.DAQData(:,smpte_chn_NI),NIDAQ.srate);
         if doMedFilt
             soundout=medfilt1(soundout);
         end
        [smpte_NI smpte_str_NI,errN_NI] = SMPTE_dec(soundout,NIDAQ.srate,25,0);
        
         NIDAQSmpteRaw(fnum).smpteduration=smpte_NI(end,end)-smpte_NI(1,end);
         NIDAQSmpteRaw(fnum).smpteFirstFrame=smpte_NI(1,:);
         NIDAQSmpteRaw(fnum).smpteLastFrame=smpte_NI(end,:);
         NIDAQSmpteRaw(fnum).percenterr=errN_NI;
         NIDAQSmpteRaw(fnum).infile=infile;
         tMess=sprintf('problem with SMPTE CODE, per. missing:  %3.4f\n',errN_NI);
         assert(errN_NI==0,tMess);
         
         
    catch, 
         NIDAQSmpteRaw(fnum).smpteduration=NaN;
         NIDAQSmpteRaw(fnum).smpteFirstFrame=repmat(NaN,1,5);
         NIDAQSmpteRaw(fnum).smpteLastFrame=repmat(NaN,1,5);
         NIDAQSmpteRaw(fnum).percenterr=errN_NI;
         NIDAQSmpteRaw(fnum).infile=infile;
         misslIdx=misslIdx+1;
         missNIDAQ{misslIdx,1}=fnum;
         missNIDAQ{misslIdx,2}=infile;
         missNIDAQ{misslIdx,1}=lasterr;
         
         warning(lasterr)
         warning(['Problematic file: ' infile])
         warning(['percentage of frames with errors: ' num2str(errN_NI)]);
    end
    
    
    NIDAQSmpteRaw(fnum).daqPath=daqPath;
    NIDAQSmpteRaw(fnum).smpte_chn_NI=smpte_chn_NI;
    
     disp(['processed ' infile ', dur. '  num2str(NIDAQSmpteRaw(fnum).smpteduration)])
    
end

disp('Type RETURN to continue')
% keyboard

outfile=[pathStr pathchar 'smpte_raw.mat']
comment='daqPath: Infile used';
save(outfile,'NIDAQSmpteRaw','smpte_chn_NI','daqPath','comment','missNIDAQ');
diary off
