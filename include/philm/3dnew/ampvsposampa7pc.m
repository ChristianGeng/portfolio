function ampvsposampa7pc(amppath,pospath,outfile,trialbuf,sufbuf,sensorsused,rmsthreshb,velthreshb,compsens,eucthresh,parameter7b,pcorder,trimsamp)
% AMPVSPOSAMPA7PC Prediction of residuals from all amplitudes; principal component regression option
% function ampvsposampa7pc(amppath,pospath,outfile,trialbuf,sufbuf,sensorsused,rmsthreshb,velthreshb,compsens,eucthresh,parameter7b,pcorder,trimsamp)
% ampvsposampa7pc: Version 05.04.2013
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
%			unreliable data from the regression analysis
%       rmsthreshb is the rms threshold for bad data
%       velthreshb the velocity threshold (mm/s)
%       If no euclidean difference threshold from a comparison sensor is to be
%			used then the corresponding entry in compsens should be set to NaN
%       The thresholds (low, high) are given in eucthreshb (nsensor*2)
%       If the length of rmsthreshb, velthreshb or eucthresb == 1 then the
%			same value is used for every sensor
%       pcorder: If not empty or missing then principal
%			component regression is activated with the specified number of PCs
%           Note that currently when principal component regression is
%           used, then the interaction terms are automatically included in
%           the regression model (see documentation of X2FX (stats
%           toolbox).
%           Suggested choice for pcorder is 3 (which gives 3
%           interaction terms), but it may be worth doing a trial run first
%           to look at the amount of variance explained for different
%           orders. (The eigenvalues are stored in the output file in PC.eigval.)
%           Currently pcorder is the same for all sensors.
%           When PC regression is not used then the regression is
%           simply based on all 6 (for AG500; 9 for AG501) transmitter signals without interaction
%           terms
%       trimsamp: Must be 2-element vector. Number of samples to skip at
%			start and end of each trial (intended to roughly skip parts of
%			trial where nothing much is happening). Thus set to [0 0] (or omit) if not
%			needed. Note: Program will currently crash if trial is too short to
%			be trimmed!! So be careful if using both full and downsampled
%			data.
%
%   Updates
%       8.06
%			"parameter7" added. This is the parameter in the position file
%			with currently no fixed usage. Normally used by EUCDIST2POS to
%			store difference between alternative solutions
%       7.07
%			Major update: Change back to regress rather than robustfit
%			(and prepare to use principal component regression)
%			robustfit probably tended to ignore unusual but valid data, giving
%			the possibility of actually much worse residuals on small parts of the data
%			after correction.
%			This means that elimination of genuine outliers becomes more important again!
%			Histogram calculation was tidied up to make sporadic cases of worse
%			output than input easier to catch. Backed up by graphics of old
%			residual vs. estimated corrected residual
%       25.7.07
%			Start new version with principal component regression as
%			option. Also trimming of portion of trial to use
%		24.3.09
%			store all plots of old vs. new residuals as figure files (one
%			per sensor and pass). Figures are deleted at end of each pass.
%			Also log in diary file (one for each pass).
%			Intended to make program more suitable for running on matlab
%			without graphics.
%       30.03.2013
%           Prepare for AG501
%
%   See Also
%       ADJAMPSAPC

functionname='ampvsposampa7pc: Version 05.04.2013';

%03.2013, number of sensors and transmitters now determined from input
%files
nsensor=[];
%nsensor=12;
%ntran=6;
ntran=[];
ampfac=2500;        %to work roughly in units of digits
%    ampfac=1;        %to work roughly in units of digits

plotdec=10;     %decimation rate for plots of amps vs. residuals


figname='figs';
if ~exist(figname,'dir') mkdir(figname); end;
tmps=strrep(outfile,pathchar,'_');
figname=[figname pathchar tmps];


%should be taken from descriptor of input file
rmsp=6;
p7p=7;


%might be better to make x2fx mode an additional option
x2fx_mode='linear';
nscore=0;

if nargin>11
    if ~isempty(pcorder)
        
        %maybe expand to vector to allow for sensor-specific approach in
        %future??
        nscore=pcorder;
        
        x2fx_mode='interaction';
    end;
end;

trimuse=[0 0];
if nargin > 12 trimuse=trimsamp; end;


npass=length(trialbuf);


%normally from input file
%assume will be returned by loadamp, regardless of input format
%sf=200;

ipi=findstr(pathchar,pospath);
ipi=ipi(end);
posamppath=[pospath(1:ipi) 'posamps' pathchar];
if length(pospath)>ipi posamppath=[posamppath pospath((ipi+1):end)]; end;

trigo=trimuse(1)+1;
triend=trimuse(2);

for ipass=1:npass
    
    triallist=trialbuf{ipass};
    mysuff=deblank(sufbuf(ipass,:));
    
%    diary([outfile mysuff '_log.txt']);
    
    ntrial=length(triallist);
    
    trialp=ones(ntrial,2);
    %work out length of each trial so storage can be allocated
    disp('determining trial lengths');
    for iti=1:ntrial
        tt=triallist(iti);
        tts=int2str0(tt,4);
        a=loadamp([amppath tts]);
        
        if isempty(nsensor)
            nsensor=size(a,3);
            ntran=size(a,2);
            if length(rmsthreshb)==1 rmsthreshb=repmat(rmsthreshb,[nsensor 1]); end;
            if length(velthreshb)==1 velthreshb=repmat(velthreshb,[nsensor 1]); end;
            if length(parameter7b)==1 parameter7b=repmat(parameter7b,[nsensor 1]); end;
            if length(compsens)==1 compsens=repmat(compsens,[nsensor 1]); end;
        else
            if size(a,3)~=nsensor
                disp('Inconsistent number of sensors in input files');
                return;
            end;
            if size(a,2)~=ntran
                disp('Inconsistent number of transmitters in input files');
                return;
            end;
            
        end;
        
        
        nsamp=0;
        if ~isempty(a)
            %possible problem if trial very short
            a=a(trigo:(end-triend),:,:);
            nsamp=size(a,1);
        end;
        trialp(iti,2)=trialp(iti,1)+nsamp-1;
        if iti<ntrial trialp(iti+1,1)=trialp(iti,2)+1; end;
    end;            %loop for trial lengths

    
    disp(trialp)
    %keyboard;
    buflen=trialp(end,2);
    
    
    hfs=ones(nsensor)*NaN;
    
    
    
    bc=cell(nsensor,ntran);
    statsc=bc;
    
    pc=cell(nsensor,1);
    
    %    b1=ones(nsensor,ntran)*NaN;
    %    b2=ones(nsensor,ntran)*NaN;
    
    %stats in order mean, sd, meanabs (not all useful in all cases)
    residual_old=ones(nsensor,ntran,3)*NaN;
    residual_new=ones(nsensor,ntran,3)*NaN;
    residual_nomean=ones(nsensor,ntran,3)*NaN;
    ampstats=ones(nsensor,ntran,3)*NaN;
    ampchangestats=ones(nsensor,ntran,3)*NaN;
    
    corrcoef_residvsamp=cell(nsensor,ntran);
    corrcoef_residvspred=cell(nsensor,ntran);
    
    
    regn=ones(nsensor,ntran)*NaN;
    
    se1=ones(nsensor,ntran)*NaN;
    se2=ones(nsensor,ntran)*NaN;
    
    histvec=[0 5 10 15 20 25 30 inf];
    nhist=length(histvec);
    histbuf1=ones(nsensor,ntran,nhist)*NaN;
    histbuf2=ones(nsensor,ntran,nhist)*NaN;
    
    
    %as all the amp data is stored it would be better to reorganize the loops
    
    for ii=sensorsused
        rmsthresh=rmsthreshb(ii);
        velthresh=velthreshb(ii);
        parameter7=parameter7b(ii);
        hfs(ii)=figure;
        %for ii=[1]
        for jj=1:ntran
            disp([ii jj]);
            %for trials of different lengths
            
            aa=ones(buflen,ntran)*NaN;
            pa=aa;
            if jj==1 ppv=ones(buflen,1)*NaN; end;
            
            %         aa=zeros(nsamp,ntrial);pa=zeros(nsamp,ntrial);
            for iti=1:ntrial
                %                disp(iti)
                tt=triallist(iti);
                tts=int2str0(tt,4);
                ampfile=[amppath tts];
                [a,SA]=loadamp(ampfile);
                if ~isempty(a)
                    a=a(trigo:(end-triend),:,:);
                    
                    sf=SA.samplerate;       %should work correctly even if raw amp file
                    %                p=loadamp([basepath 'rawpos\posamps\' tts '.amp']);
                    p=loadamp([posamppath tts]);
                    p=p(trigo:(end-triend),:,:);
                    
                    %set up list of dodgy samples
                    if jj==1
                        %                    px=loadpos([basepath 'rawpos\' tts '.pos']);
                        px=loadpos([pospath tts]);
                        px=px(trigo:(end-triend),:,:);
                        vtmprms=(px(:,rmsp,ii)>rmsthresh) | isnan(px(:,1,ii));
                        p7tmp=px(:,p7p,ii)>parameter7;
                        postmp=px(:,1:3,ii);
                        euctmp=eucdistn(postmp(1:end-1,:),postmp(2:end,:));
                        euctmp=euctmp*sf;
                        euctmp=euctmp>velthresh;
                        euctmp=[euctmp;euctmp(end)];
                        
                        %further possible criteria for exclusion
                        %high value of amp vs. posamp velocity difference
                        %cf parameter7
                        euccomp=zeros(size(vtmprms));
                        if ~isnan(compsens(ii))
%                            disp('eucthresh');
%                            disp(eucthresh(ii,:));
                            compdata=px(:,1:3,compsens(ii));
                            euccomp=eucdistn(postmp,compdata);
                            euccomp=euccomp<eucthresh(ii,1) | euccomp>eucthresh(ii,2);
                        end;
                        vtmp=vtmprms | euctmp | euccomp | p7tmp;
                        
                        if any(vtmp)
                            %                        disp(eucthresh(ii,:));
                            disp(['Trial ' int2str(tt) '. Bad samples (rms, vel. euc. p7 overall : ' int2str(sum([vtmprms euctmp euccomp p7tmp vtmp]))]);
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
            
            
            %use nscore ~=0 to trigger PC approach
            PC.pcorder=nscore;
            if nscore
            sigma=3;np=4;covflag=1;
                %disp('computing PCs');
                [xbar,sdev,com,eigval,eigvec,outind,eli,rmserror]=elli(aa,sigma,np,nscore,covflag);
                %            keyboard;
                PC.xbar=xbar;
                PC.sdev=sdev;
                PC.com=com;
                PC.eigval=eigval;
                PC.eigvec=eigvec;
                PC.rmserror=rmserror;
                PC.covflag=covflag;
                
                
                load pcscore;
                varexp=(sum(eigval(1:nscore))/sum(eigval))*100;
                disp(['Variance explained by ' int2str(nscore) ' components: ' int2str(round(varexp))]);
                predmat=x2fx(pcscore,x2fx_mode);
            else
                predmat=x2fx(aa,x2fx_mode);
                
            end;
            
            nuse=size(aa,1);
            disp(['n for regression: ' int2str(nuse)]);
            regn(ii,jj)=nuse;
            %    aa=aa(:);pa=pa(:);
            
            resid0=pa(:,jj)-aa(:,jj);
            %            [b,stats]=robustfit(aa,resid0);
            
            %            oldfigh=gcf;
            resid0d=resid0(1:plotdec:end);
            hftmp=figure;
            %assume first column of predictor matrix is constant
            %assuming no more than 6 further predictors
            for iri=2:size(predmat,2)
                haxtmp=subplot(2,3,iri-1);
                
                plot(predmat(1:plotdec:end,iri),resid0d,'.');
                title(['Sens/Trans/Pass/Predictor ' int2str([ii jj ipass iri])]);
                drawnow
            end;
            %        keyboard;
            %			saveas(hftmp,[outfile mysuff '_S' int2str(ii) '_T' int2str(jj) '_pred.fig'],'fig');
            %            pause(5);
            
            [b,BINT,R,RINT,stats] = regress(resid0,predmat);
            
            bc{ii,jj}=b;
            
            pc{ii}=PC;
            
            %if PC approach??
            coff=corrcoef([resid0 aa]);        %correlation of residual with all amps
            coff=coff(1,:);
            corrcoef_residvsamp{ii,jj}=coff;
            coff=corrcoef([resid0 predmat(:,2:end)]);        %correlation of residual with all predictors (assuming first term constant)
            coff=coff(1,:);
            corrcoef_residvspred{ii,jj}=coff;
            %            disp(b');
            %            disp(stats.se');
            %            disp(['b1: ' num2str(b(1)) ' se ' num2str(stats.se(1))]);
            %            disp(['b2: ' num2str(b(2)) ' se ' num2str(stats.se(2))]);
            
            %            plot(aa(1:plotdec:end,:),repmat(resid0(1:plotdec:end),[1 ntran]),'.');     %plot residuals (check sign!!!)
            
            %            yhatres=[ones(length(resid0),1) aa]*b;
            %            yhatres=[ones(length(resid0),1) pcscore]*b;
            yhatres=predmat*b;
            
            
            residual_old(ii,jj,:)=[nanmean(resid0) nanstd(resid0) nanmean(abs(resid0))];
            residtmp=resid0-nanmean(resid0);
            %more or less superfluous, gives an indication of how much additional
            %improvement the regression gives
            residual_nomean(ii,jj,:)=[0 nanstd(residtmp) nanmean(abs(residtmp))];
            
            
            
            %            title(['Sens/Trans/Pass ' int2str([ii jj ipass])]);
            
            
            
            %            drawnow;
            %                        keyboard;
            
            ampstats(ii,jj,:)=[nanmean(aa(:,jj)) nanstd(aa(:,jj)) nanmean(abs(aa(:,jj)))];
            
            
            %            ad0(ii,jj)=nanmean((pa-aa).^2);
            %            yhat=(aa*b(2))+b(1);
            
            ampchange=yhatres;
            resid1=resid0-yhatres;
            
            delete(hftmp);
            drawnow;
            figure(hfs(ii));
            drawnow;
            subplotr=2;
            subplotc=3;
            if ntran>6 subplotr=3; end; %assume this covers all cases
            subplot(subplotr,subplotc,jj);
            
            plot(resid0d,resid1(1:plotdec:end),'.');
            xlabel('Old residuals');
            ylabel('Estimated new residuals');
            title(['Sens/Trans/Pass ' int2str([ii jj ipass])]);
            axis equal
            grid on
            
            drawnow;
            
            
            ampchangestats(ii,jj,:)=[nanmean(ampchange) nanstd(ampchange) nanmean(abs(ampchange))];
            
            residual_new(ii,jj,:)=[nanmean(resid1) nanstd(resid1) nanmean(abs(resid1))];
            
            
            
            %adp(ii,jj)=nanmean((pa-yhat).^2);
            %            adchange(ii,jj)=ad0(ii,jj)-adp(ii,jj);
            %            adchangep(ii,jj)=100-(adp(ii,jj)/ad0(ii,jj))*100;
            %            adchangea(ii,jj)=nanmean(abs(aa-yhat));
            %            adchangex(ii,jj)=nanmean(aa-yhat);
            %            adchangesd(ii,jj)=nanstd(aa-yhat);
            %            disp([ad0(ii,jj) adp(ii,jj)]);
            
            disp(['Residuals in  (mean, sd, meanabs)   : ' num2str(residual_old(ii,jj,:))]);
            disp(['Residuals no_x(mean, sd, meanabs)   : ' num2str(residual_nomean(ii,jj,:))]);
            disp(['Residuals out (mean, sd, meanabs)   : ' num2str(residual_new(ii,jj,:))]);
            %will only be different for PC method
            disp(['r Residuals vs. amps                : ' num2str(corrcoef_residvsamp{ii,jj})]);
            disp(['r Residuals vs. preds               : ' num2str(corrcoef_residvspred{ii,jj})]);
            
            disp(['Amps          (mean, sd, meanabs) : ' num2str(ampstats(ii,jj,:))]);
            disp(['Amp change    (mean, sd, meanabs) : ' num2str(ampchangestats(ii,jj,:))]);
            
            hxx1=histc(abs(resid0),histvec);
            %convert histogram to per 1000
            hxx1=round((hxx1/length(pa))*1000);
            histbuf1(ii,jj,:)=hxx1;
            hxx2=histc(abs(resid1),histvec);
            hxx2=round((hxx2/length(pa))*1000);
            histbuf2(ii,jj,:)=hxx2;
            
            hxx1(end)=[];
            hxx2(end)=[];
            disp('Histograms (per 1000) of residuals (old then new) for bins with upper edges:');
            disp(histvec(2:end));
            disp(underl(int2str(histvec(2:end))));
            disp([hxx1';hxx2']);
            
            
            %                    keyboard
        end;					%transmitter loop
        saveas(hfs(ii),[figname mysuff '_S' int2str(ii) '_oldnewres.fig'],'fig');
    
%save on each pass through sensor loop (gives some information in case of crashes)
        save([outfile mysuff],'bc','statsc','residual_old','residual_nomean','residual_new','ampstats','ampchangestats','corrcoef_residvsamp','corrcoef_residvspred','histbuf1','histbuf2','regn','ampfac','histvec','pc','x2fx_mode');

        close(hfs(ii));
    end;						%sensor loop
%    close all;
    
    
    %    close(hfs(ishandle(hfs)));
    
    %   figure
    %   errorbar(b1,se1);
    %   title(['Pass ' int2str(ipass) '. Coefficent 1']);
    %   drawnow
    
    %   figure
    %   errorbar(b2,se2);
    %   title(['Pass ' int2str(ipass) '. Coefficent 2']);
    %   drawnow
%    diary off

    diary(['ampvsposamp_histoverview_' int2str(ipass) '.txt']);
                disp('Histograms (per 1000) of residuals (old then new) for bins with upper edges:');
            disp(histvec(2:end));
            disp(underl(int2str(histvec(2:end))));

    for ii=sensorsused
        for jj=1:ntran
            hxx1=squeeze(histbuf1(ii,jj,:));
            hxx1=hxx1';
            hxx1(end)=[];   %why?
            hxx2=squeeze(histbuf2(ii,jj,:));
            hxx2=hxx2';
            hxx2(end)=[];   %why?
            disp([ii jj]);
            disp([hist1;hist2]);
        end;
    end;
    diary off
    
end;        %npass
