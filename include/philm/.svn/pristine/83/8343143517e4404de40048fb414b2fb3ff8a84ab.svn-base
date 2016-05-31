function ampvsposamp(basepath,outfile,trialbuf,sufbuf,sensorsused,rmsthreshb,velthreshb,compsens,eucthresh)
% AMPVSPOSAMP Calculate amps vs posamps to prepare amp adjust
% function ampvsposamp(basepath,outfile,trialbuf,sufbuf,sensorsused,rmsthreshb,velthreshb,compsens,eucthresh)
% ampvsposamp: Version 5.10.05
%
%   Description
%       basepath: with final backslash. must contain subdirectories amps,
%       rawpos and rawpos\posamps
%       outfile: mat file with analysis results. Normally use variables
%       b1 and b2 as input to ADJAMPS
%       trialbuf: m*2 list of first and last trials to process
%       sufbuf: suffix for outfile corresponding to each entry (line) in
%       trialbuf
%       sensorsused is the list of sensors to process
%       the sensor number is then used as an index into rmsthreshb etc
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
%       ADJAMPS


nsensor=12;
ntran=6;
ampfac=2500;        %to work roughly in units of digits
%    ampfac=1;        %to work roughly in units of digits

plotdec=10;     %decimation rate for plots of amps vs. residuals



if length(rmsthreshb)==1 rmsthreshb=repmat(rmsthreshb,[nsensor 1]); end;
if length(velthreshb)==1 velthreshb=repmat(velthreshb,[nsensor 1]); end;
if length(compsens)==1 compsens=repmat(compsens,[nsensor 1]); end;


npass=size(trialbuf,1);

%why 800?
%nsampbuf=repmat(800,[npass 1]);

%try and get this from input file
sf=200;



for ipass=1:npass

hfs=ones(nsensor)*NaN;
    triallist=trialbuf(ipass,1):trialbuf(ipass,2);
    mysuff=deblank(sufbuf(ipass,:));



    ntrial=length(triallist);

    trialp=ones(ntrial,2);
    %work out length of each trial so storage can be allocated
    disp('determining trial lengths');
    for iti=1:ntrial
        tt=triallist(iti);
        tts=int2str0(tt,4);
        a=loadamp([basepath 'amps\' tts]);
        nsamp=size(a,1);
        trialp(iti,2)=trialp(iti,1)+nsamp-1;
        if iti<ntrial trialp(iti+1,1)=trialp(iti,2)+1; end;
    end;
    disp(trialp)
    %keyboard;
    buflen=trialp(end,2);







    b1=ones(nsensor,ntran)*NaN;
    b2=ones(nsensor,ntran)*NaN;

%stats in order mean, sd, meanabs (not all useful in all cases)
    residual_old=ones(nsensor,ntran,3)*NaN;
    residual_new=ones(nsensor,ntran,3)*NaN;
    residual_nomean=ones(nsensor,ntran,3)*NaN;
    ampstats=ones(nsensor,ntran,3)*NaN;
    ampchangestats=ones(nsensor,ntran,3)*NaN;

    corrcoef_residvsamp=ones(nsensor,ntran)*NaN;
    

    regn=ones(nsensor,ntran)*NaN;

    se1=ones(nsensor,ntran)*NaN;
    se2=ones(nsensor,ntran)*NaN;

    histvec=[0 5 10 15 20 25 30];
    nhist=length(histvec);
    histbuf1=ones(nsensor,ntran,nhist)*NaN;
    histbuf2=ones(nsensor,ntran,nhist)*NaN;



    for ii=sensorsused
        rmsthresh=rmsthreshb(ii);
        velthresh=velthreshb(ii);
hfs(ii)=figure;
        %for ii=[1]
        for jj=1:ntran
            disp([ii jj]);
            %for trials of different lengths
            subplot(2,3,jj);
            
            aa=ones(buflen,1)*NaN;
            pa=aa;
            if jj==1 ppv=aa; end;

            %         aa=zeros(nsamp,ntrial);pa=zeros(nsamp,ntrial);
            for iti=1:ntrial
                tt=triallist(iti);
                tts=int2str0(tt,4);
                ampfile=[basepath 'amps\' tts];
                a=loadamp(ampfile);
                if ~isempty(a)
                    sf=mymatin(ampfile,'samplerate',200);
                    %                p=loadamp([basepath 'rawpos\posamps\' tts '.amp']);
                    p=loadamp([basepath 'rawpos\posamps\' tts]);

                    %set up list of dodgy samples
                    if jj==1
                        %                    px=loadpos([basepath 'rawpos\' tts '.pos']);
                        px=loadpos([basepath 'rawpos\' tts]);
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

                        if any(vtmp) disp(['Trial ' int2str(tt) '. Bad samples (overall, rms, vel. euc. ' int2str(sum([vtmp vtmprms euctmp euccomp]))]); end;


                        ppv(trialp(iti,1):trialp(iti,2))=vtmp;
                    end;


                    aa(trialp(iti,1):trialp(iti,2))=a(:,jj,ii)*ampfac;
                    pa(trialp(iti,1):trialp(iti,2))=p(:,jj,ii)*ampfac;
                end;    %a not empty
            end;

            disp('data read');

            if jj==1
                %set neighbouring samples to bad samples to bad
                vx=[ppv(2:end);0] | [ppv(3:end);0;0] | [0;ppv(1:end-1)] | [0;0;ppv(1:end-2)];
                ppv=ppv | vx;




                nbad=sum(ppv);
                nsamp=length(aa);
                disp(['Total/unreliable samples : ' int2str([nsamp nbad])]);
            end;

            aa(ppv)=[];
            pa(ppv)=[];

            nuse=length(aa);
            disp(['n for regression: ' int2str(nuse)]);
            regn(ii,jj)=nuse;
            %    aa=aa(:);pa=pa(:);
            [b,stats]=robustfit(aa,pa);
            %            disp(b');
            %            disp(stats.se');
            disp(['b1: ' num2str(b(1)) ' se ' num2str(stats.se(1))]);
            disp(['b2: ' num2str(b(2)) ' se ' num2str(stats.se(2))]);

            resid0=aa-pa;
            plot(aa(1:plotdec:end),resid0(1:plotdec:end),'.');     %plot residuals (check sign!!!)
            
%            [bres,statsres]=robustfit(aa,resid0);
%            yhatres=(aa*bres(2))+bres(1);

coff=corrcoef(aa,resid0);
coff=coff(1,2);

corrcoef_residvsamp(ii,jj)=coff;
            
residual_old(ii,jj,:)=[nanmean(resid0) nanstd(resid0) nanmean(abs(resid0))];
residtmp=resid0-nanmean(resid0);
%more or less superfluous, gives an indication of how much additional
%improvement the regression gives
residual_nomean(ii,jj,:)=[0 nanstd(residtmp) nanmean(abs(residtmp))];



            title(['Sens/Trans/Pass ' int2str([ii jj ipass])]);

            
            
            drawnow;
%                        keyboard;
            b1(ii,jj)=b(1);
            b2(ii,jj)=b(2);
            se1(ii,jj)=stats.se(1);
            se2(ii,jj)=stats.se(2);

            ampstats(ii,jj,:)=[nanmean(aa) nanstd(aa) nanmean(abs(aa))];
            
            
%            ad0(ii,jj)=nanmean((pa-aa).^2);
            yhat=(aa*b(2))+b(1);

            ampchange=aa-yhat;
            resid1=yhat-pa;
            ampchangestats(ii,jj,:)=[nanmean(ampchange) nanstd(ampchange) nanmean(abs(ampchange))];
            
residual_new(ii,jj,:)=[nanmean(resid1) nanstd(resid1) nanmean(abs(resid1))];
            


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
            disp(['r amp vs. residuals               : ' num2str(corrcoef_residvsamp(ii,jj))]);
             
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
    save([outfile mysuff],'b1','b2','se1','se2','residual_old','residual_nomean','residual_new','ampstats','ampchangestats','corrcoef_residvsamp','histbuf1','histbuf2','regn','ampfac','histvec');
    drawnow

end;        %npass
