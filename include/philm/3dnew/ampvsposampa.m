function ampvsposamp(amppath,pospath,outfile,trialbuf,sufbuf,sensorsused,rmsthreshb,velthreshb,compsens,eucthresh)
% AMPVSPOSAMPA Prediction of residuals from all amplitudes
% function ampvsposampa(basepath,outfile,trialbuf,sufbuf,sensorsused,rmsthreshb,velthreshb,compsens,eucthresh)
% ampvsposampa: Version 5.1.06
%
%   Description
%       amppath:    Common part of amp file names without 4-digit trial number
%       pospath:    Common part of pos file names. The directory with the pos
%                   files must contain subdirectory posamps
%       outfile:    mat file with analysis results. Normally use coefficients
%                   in variable bc as input to ADJAMPSA
%       trialbuf:   cell array, each cell containing list of trials to use
%                   for each pass
%       sufbuf:     string matrix with suffix for outfile corresponding to each entry in trialbuf
%       sensorsused:    list of sensors to process
%                       the sensor number is then used as an index into rmsthreshb etc
%       The purpose of rmsthreshb, velthreshb and eucthreshb is to remove
%       unreliable data from the regression analysis
%       rmsthreshb is the rms threshold for bad data
%       velthreshb the velocity threshold (currently assumes samplerate of
%       200Hz)
%       If no euclidean difference threshold from a comparison sensor is to be
%       used then the corresponding entry in compsens should be set to NaN
%       The thresholds (low, high) are given in eucthreshb (nsensor*2)
%       If the length of rmsthreshb, velthreshb or eucthresb == 1 then the
%       same value is used for every sensor
%
%   See Also
%       ADJAMPS AMPVSPOSAMP

functionname='ampvsposampa: Version 5.1.05';

nsensor=12;
ntran=6;
ampfac=2500;        %to work roughly in units of digits
%    ampfac=1;        %to work roughly in units of digits

plotdec=10;     %decimation rate for plots of amps vs. residuals



if length(rmsthreshb)==1 rmsthreshb=repmat(rmsthreshb,[nsensor 1]); end;
if length(velthreshb)==1 velthreshb=repmat(velthreshb,[nsensor 1]); end;
if length(compsens)==1 compsens=repmat(compsens,[nsensor 1]); end;


npass=length(trialbuf);


%normally from input file
sf=200;

ipi=findstr(pathchar,pospath);
ipi=ipi(end);
posamppath=[pospath(1:ipi) 'posamps' pathchar];
if length(pospath)>ipi posamppath=[posamppath pospath((ipi+1):end)]; end;


for ipass=1:npass

hfs=ones(nsensor)*NaN;
    triallist=trialbuf{ipass};
    mysuff=deblank(sufbuf(ipass,:));



    ntrial=length(triallist);

    trialp=ones(ntrial,2);
    %work out length of each trial so storage can be allocated
    disp('determining trial lengths');
    for iti=1:ntrial
        tt=triallist(iti);
        tts=int2str0(tt,4);
        a=loadamp([amppath tts]);
        nsamp=size(a,1);
        trialp(iti,2)=trialp(iti,1)+nsamp-1;
        if iti<ntrial trialp(iti+1,1)=trialp(iti,2)+1; end;
    end;
    disp(trialp)
    %keyboard;
    buflen=trialp(end,2);





bc=cell(nsensor,ntran);
statsc=bc;
    b1=ones(nsensor,ntran)*NaN;
    b2=ones(nsensor,ntran)*NaN;

%stats in order mean, sd, meanabs (not all useful in all cases)
    residual_old=ones(nsensor,ntran,3)*NaN;
    residual_new=ones(nsensor,ntran,3)*NaN;
    residual_nomean=ones(nsensor,ntran,3)*NaN;
    ampstats=ones(nsensor,ntran,3)*NaN;
    ampchangestats=ones(nsensor,ntran,3)*NaN;

    corrcoef_residvsamp=cell(nsensor,ntran);
    

    regn=ones(nsensor,ntran)*NaN;

    se1=ones(nsensor,ntran)*NaN;
    se2=ones(nsensor,ntran)*NaN;

    histvec=[0 5 10 15 20 25 30];
    nhist=length(histvec);
    histbuf1=ones(nsensor,ntran,nhist)*NaN;
    histbuf2=ones(nsensor,ntran,nhist)*NaN;


%as all the amp data is stored it would be better to reorganize the loops
    
    for ii=sensorsused
        rmsthresh=rmsthreshb(ii);
        velthresh=velthreshb(ii);
hfs(ii)=figure;
        %for ii=[1]
        for jj=1:ntran
            disp([ii jj]);
            %for trials of different lengths
            subplot(2,3,jj);
            
            aa=ones(buflen,ntran)*NaN;
            pa=aa;
            if jj==1 ppv=ones(buflen,1)*NaN; end;

            %         aa=zeros(nsamp,ntrial);pa=zeros(nsamp,ntrial);
            for iti=1:ntrial
%                disp(iti)
                tt=triallist(iti);
                tts=int2str0(tt,4);
                ampfile=[amppath tts];
                a=loadamp(ampfile);
                if ~isempty(a)
                    sf=mymatin(ampfile,'samplerate',200);
                    %                p=loadamp([basepath 'rawpos\posamps\' tts '.amp']);
                    p=loadamp([posamppath tts]);

                    %set up list of dodgy samples
                    if jj==1
                        %                    px=loadpos([basepath 'rawpos\' tts '.pos']);
                        px=loadpos([pospath tts]);
                        vtmprms=(px(:,6,ii)>rmsthresh) | isnan(px(:,1,ii));
                        postmp=px(:,1:3,ii);
                        euctmp=eucdistn(postmp(1:end-1,:),postmp(2:end,:));
                        euctmp=euctmp*sf;
                        euctmp=euctmp>velthresh;
                        euctmp=[euctmp;euctmp(end)];

                        %further possible criteria for exclusion
                        %high value of amp vs. posamp velocity difference
                        %unexpected distance from sensor assumed to be stable

                        euccomp=zeros(size(vtmprms));
                        if ~isnan(compsens(ii))
                            compdata=px(:,1:3,compsens(ii));
                            euccomp=eucdistn(postmp,compdata);
                            euccomp=euccomp<eucthresh(ii,1) | euccomp>eucthresh(ii,2);
                        end;
                        vtmp=vtmprms | euctmp | euccomp;

                        if any(vtmp) 
%                        disp(eucthresh(ii,:));
                            disp(['Trial ' int2str(tt) '. Bad samples (overall, rms, vel. euc. ' int2str(sum([vtmp vtmprms euctmp euccomp]))]); 
                        end;


                        ppv(trialp(iti,1):trialp(iti,2))=vtmp;
                    end;


                    aa(trialp(iti,1):trialp(iti,2),:)=a(:,:,ii)*ampfac;
                    pa(trialp(iti,1):trialp(iti,2),:)=p(:,:,ii)*ampfac;
                end;    %a not empty
            end;

            disp('data read');

%keyboard;
            if jj==1
                %set neighbouring samples to bad samples to bad
                vx=[ppv(2:end);0] | [ppv(3:end);0;0] | [0;ppv(1:end-1)] | [0;0;ppv(1:end-2)];
                ppv=ppv | vx;




                nbad=sum(ppv);
                nsamp=length(aa);
                disp(['Total/unreliable samples : ' int2str([nsamp nbad])]);
            end;

            aa(ppv,:)=[];
            pa(ppv,:)=[];

            nuse=size(aa,1);
            disp(['n for regression: ' int2str(nuse)]);
            regn(ii,jj)=nuse;
            %    aa=aa(:);pa=pa(:);

            resid0=pa(:,jj)-aa(:,jj);
            [b,stats]=robustfit(aa,resid0);
            bc{ii,jj}=b;
            coff=corrcoef([resid0 aa]);        %correlation of residual with all amps
            coff=coff(1,:);
            corrcoef_residvsamp{ii,jj}=coff;
            %            disp(b');
            %            disp(stats.se');
%            disp(['b1: ' num2str(b(1)) ' se ' num2str(stats.se(1))]);
%            disp(['b2: ' num2str(b(2)) ' se ' num2str(stats.se(2))]);

%            plot(aa(1:plotdec:end,:),repmat(resid0(1:plotdec:end),[1 ntran]),'.');     %plot residuals (check sign!!!)
            
            yhatres=[ones(length(resid0),1) aa]*b;

            
residual_old(ii,jj,:)=[nanmean(resid0) nanstd(resid0) nanmean(abs(resid0))];
residtmp=resid0-nanmean(resid0);
%more or less superfluous, gives an indication of how much additional
%improvement the regression gives
residual_nomean(ii,jj,:)=[0 nanstd(residtmp) nanmean(abs(residtmp))];




            title(['Sens/Trans/Pass ' int2str([ii jj ipass])]);

            
            
            drawnow;
%                        keyboard;

            ampstats(ii,jj,:)=[nanmean(aa(:,jj)) nanstd(aa(:,jj)) nanmean(abs(aa(:,jj)))];
            
            
%            ad0(ii,jj)=nanmean((pa-aa).^2);
%            yhat=(aa*b(2))+b(1);

            ampchange=yhatres;
            resid1=resid0-yhatres;
            ampchangestats(ii,jj,:)=[nanmean(ampchange) nanstd(ampchange) nanmean(abs(ampchange))];
            
residual_new(ii,jj,:)=[nanmean(resid1) nanstd(resid1) nanmean(abs(resid1))];
            

plot(resid0,resid1,'.');
xlabel('Old residuals');
ylabel('Estimated new residuals');


%adp(ii,jj)=nanmean((pa-yhat).^2);
%            adchange(ii,jj)=ad0(ii,jj)-adp(ii,jj);
%            adchangep(ii,jj)=100-(adp(ii,jj)/ad0(ii,jj))*100;
%            adchangea(ii,jj)=nanmean(abs(aa-yhat));
%            adchangex(ii,jj)=nanmean(aa-yhat);
%            adchangesd(ii,jj)=nanstd(aa-yhat);
            %            disp([ad0(ii,jj) adp(ii,jj)]);

            disp(['Residuals in  (mean, sd, meanabs) : ' num2str(residual_old(ii,jj,:))]);
            disp(['Residuals no_x(mean, sd, meanabs) : ' num2str(residual_nomean(ii,jj,:))]);
            disp(['Residuals out (mean, sd, meanabs) : ' num2str(residual_new(ii,jj,:))]);
            disp(['r amp vs. residuals               : ' num2str(corrcoef_residvsamp{ii,jj})]);
             
            disp(['Amps          (mean, sd, meanabs) : ' num2str(ampstats(ii,jj,:))]);
            disp(['Amp change    (mean, sd, meanabs) : ' num2str(ampchangestats(ii,jj,:))]);
            
            hxx1=histc(abs(resid0),histvec);
            %convert histogram to percent
            hxx1=round((hxx1/length(pa))*100);
            histbuf1(ii,jj,:)=hxx1;
            hxx2=histc(abs(resid1),histvec);
            hxx2=round((hxx2/length(pa))*100);
            histbuf2(ii,jj,:)=hxx2;

            disp(['Histograms of residuals (old then new) for bins ' int2str(histvec)]);
            disp([hxx1';hxx2']);


%                    keyboard
        end;
    end;


    close(hfs(ishandle(hfs)));
    
    figure
    errorbar(b1,se1);
    title(['Pass ' int2str(ipass) '. Coefficent 1']);
    drawnow

    figure
    errorbar(b2,se2);
    title(['Pass ' int2str(ipass) '. Coefficent 2']);
    save([outfile mysuff],'bc','statsc','residual_old','residual_nomean','residual_new','ampstats','ampchangestats','corrcoef_residvsamp','histbuf1','histbuf2','regn','ampfac','histvec');
    drawnow

end;        %npass
