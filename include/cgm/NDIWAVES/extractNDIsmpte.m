function extractNDIsmpte( NDIsessionroot,session,smpte_chn_WAVE)
% extractNDIsmpte: Extract and save raw SMPTE information from NDI session
%   Raw smpte code ist saved to smpteRaw.mat in subdir rawdata
%
% updated $07-Jan-2012$ CGeng
%


NDIWavDirStrRaw = [NDIsessionroot session '/rawdata/MySession_' session '_*.wav' ]
NDIWavRAW=dir(NDIWavDirStrRaw);

misslistIdx=0;
missl={};

for fnum=1:length(NDIWavRAW)
    
    infile=[NDIsessionroot session '/rawdata/' char(NDIWavRAW(fnum).name)];
    disp(['processing ' infile]);
    [dataSYNCH,samplerate,NBITS]=wavread(infile);
    
    try,
        [smpteNDIWAVE smpteNDIWAVE_str,errN] = SMPTE_dec(dataSYNCH(:,2),samplerate,25,0);
        tMess=sprintf('problem found in SMPTE CODE, Perc. error = %3.4f\n',errN);
        assert(errN==0,tMess);
    catch,
        misslistIdx=misslistIdx+1;
        missl{misslistIdx,1}=fnum;
        missl{misslistIdx,2}=infile;
        missl{misslistIdx,3}=lasterr;
        smpteNDIWAVE=ones(2,5).*NaN;
        warning('problem extracting SMPTE!!')
        warning(lasterr);
    end
    
    
    NDIWavRAW(fnum).smpteduration=smpteNDIWAVE(end,end)-smpteNDIWAVE(1,end);
    NDIWavRAW(fnum).smpteFirstFrame=smpteNDIWAVE(1,:);
    NDIWavRAW(fnum).smpteLastFrame=smpteNDIWAVE(end,:);
    NDIWavRAW(fnum).percenterr=errN;
    NDIWavRAW(fnum).infile=infile;
%     NDIWavRAW(fnum)
    disp(['SMPTE dur.: '  num2str(NDIWavRAW(fnum).smpteduration)])
    disp(sprintf('%s\n', 'done ...'))
end


% sort by date - does this always work?
[dum,I]=sort(datenum(cat(1,NDIWavRAW.date)));
NDIWavRAW=NDIWavRAW(I)

outfile=[NDIsessionroot session '/rawdata/smpteRaw.mat']
save(outfile,'NDIWavRAW','missl')
end

