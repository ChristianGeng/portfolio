function predposfromamps(amppath,pospath,outfile,trialbuf,sufbuf,sensorsused,rmsthreshb,velthreshb,compsens,eucthresh,parameter7b,pcorder,trimsamp)
% PREDPOSFROMAMPS Prediction of positions from all amplitudes; principal component regression option
% function predposfromamps(basepath,outfile,trialbuf,sufbuf,sensorsused,rmsthreshb,velthreshb,compsens,eucthresh,parameter7b,trimsamp)
% presposfromamps: Version 20.8.07
%
%   Description
%       amppath:    Common part of amp file names without 4-digit trial number
%       pospath:    Common part of pos file names. The directory with the pos
%                   files must contain subdirectory posamps
%       outfile:    mat file with analysis results. Normally use coefficients
%                   in variable bc as input to CALCPOSFROMAMPS
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
%       pcorder: If not empty or missing then principal
%       component regression is activated with the specified number of PCs
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
%           simply based on all 6 transmitter signals without interaction
%           terms
%       trimsamp: Must be 2-element vector. Number of samples to skip at
%       start and end of each trial (intended to roughly skip parts of
%       trial where nothing much is happening). Thus set to [0 0] (or omit) if not
%       needed. Note: Program will currently crash if trial is too short to
%       be trimmed!!
%
%   Updates
%       predposfromamps is based on ampvsposampa7pc. The following are
%       notes from the latter function.
%       8.06 "parameter7" added. This is the parameter in the position file
%       with currently no fixed usage. Normally used by EUCDIST2POS to
%       store difference between alternative solutions
%       7.07: Major update: Change back to regress rather than robustfit
%       (and prepare to use principal component regression)
%       robustfit probably tended to ignore unusual but valid data, giving
%       the possibility of actually much worse residuals on small parts of the data
%       after correction.
%       This means that elimination of genuine outliers becomes more important again!
%       Histogram calculation was tidied up to make sporadic cases of worse
%       output than input easier to catch. Backed up by graphics of old
%       residual vs. estimated corrected residual
%       25.7.07: Start new version with principal component regression as
%       option. Also trimming of portion of trial to use
%
%   See Also
%       AMPVSPOSAMPA7PC

functionname='predposfromamps: Version 20.8.07';

nsensor=12;
ntran=6;
nco=6;              %number of sensor coordinates: 3 * Pos, 3 * Ori (uses unit vector representation)
ampfac=2500;        %to work roughly in units of digits

plotdec=10;     %decimation rate for plots of amps vs. residuals

%should be taken from descriptor of input file (assume loadpos_sph2cartm is
%used)
%rmsp=6;
%p7p=7;
rmsp=nco+1;
p7p=nco+2;

if length(rmsthreshb)==1 rmsthreshb=repmat(rmsthreshb,[nsensor 1]); end;
if length(velthreshb)==1 velthreshb=repmat(velthreshb,[nsensor 1]); end;
if length(parameter7b)==1 parameter7b=repmat(parameter7b,[nsensor 1]); end;
if length(compsens)==1 compsens=repmat(compsens,[nsensor 1]); end;


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
sf=200;


trigo=trimuse(1)+1;
triend=trimuse(2);

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
        nsamp=0;
        if ~isempty(a)
            %possible problem if trial very short
            a=a(trigo:(end-triend),:,:);
            nsamp=size(a,1);
        end;
        trialp(iti,2)=trialp(iti,1)+nsamp-1;
        if iti<ntrial trialp(iti+1,1)=trialp(iti,2)+1; end;
    end;
    disp(trialp)
    %keyboard;
    buflen=trialp(end,2);
    
    
    
    
    
    bc=cell(nsensor,nco);
    statsc=bc;
    
    pc=cell(nsensor,1);
    
    %store various results of regression?

    corrcoef_posvsamp=cell(nsensor,nco);
    corrcoef_posvspred=cell(nsensor,nco);
    
    
    regn=ones(nsensor,nco)*NaN;
    
    
    
    %as all the amp data is stored it would be better to reorganize the loops
    
    for ii=sensorsused
        rmsthresh=rmsthreshb(ii);
        velthresh=velthreshb(ii);
        parameter7=parameter7b(ii);
        hfs(ii)=figure;
        %for ii=[1]
        for jj=1:nco
            disp([ii jj]);
            %for trials of different lengths
            subplot(2,3,jj);
            
            aa=ones(buflen,ntran)*NaN;
            pa=ones(buflen,nco)*NaN;
            if jj==1 ppv=ones(buflen,1)*NaN; end;
            
            %         aa=zeros(nsamp,ntrial);pa=zeros(nsamp,ntrial);
            for iti=1:ntrial
                %                disp(iti)
                tt=triallist(iti);
                tts=int2str0(tt,4);
                ampfile=[amppath tts];
                a=loadamp(ampfile);
                if ~isempty(a)
                    a=a(trigo:(end-triend),:,:);
                    
                    sf=mymatin(ampfile,'samplerate',200);
                    

                    [px,pdescriptor,punit,pdimension,psensorlist]=loadpos_sph2cartm([pospath tts]);                    
%                    px=loadpos([pospath tts]);
                        px=px(trigo:(end-triend),:,:);
                    %set up list of dodgy samples
                    if jj==1
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

                    %Just store current cooardinate????
                    pa(trialp(iti,1):trialp(iti,2),:)=px(:,1:nco,ii);
                end;    %a not empty
            end;
            
            disp('data read');
            
            keyboard;
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
            
            predmat=x2fx(aa,x2fx_mode);            
            
            sigma=3;np=4;covflag=1;
            %use nscore ~=0 to trigger PC approach
            PC.pcorder=nscore;
            if nscore
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
            end;
            
            nuse=size(aa,1);
            disp(['n for regression: ' int2str(nuse)]);
            regn(ii,jj)=nuse;
            
            oldfigh=gcf;
            
            hftmp=figure;

            %%%%%%%%%%%%%%%%%%%%%should reorganize up to here, so data is
            %%%%%%%%%%%%%%%%%%%%%only loaded once

            pax=pa(:,jj);
            
            
            
            
            %assume first column of predictor matrix is constant
            %assuming no more than 6 further predictors
            for iri=2:size(predmat,2)
                haxtmp=subplot(2,3,iri-1);
                
                plot(predmat(:,iri),pax,'.');
                title(['Sens/Coord./Pass/Predictor ' int2str([ii jj ipass iri])]);
                drawnow
            end;
                    keyboard;
%            pause(5);
%            delete(hftmp);
            figure(oldfigh);
            
            [b,BINT,R,RINT,stats] = REGRESS(pax,predmat);
            
            bc{ii,jj}=b;
            
            pc{ii}=PC;
            
            %if PC approach??
            coff=corrcoef([pax aa]);        %correlation of position coordinate with all amps
            coff=coff(1,:);
            corrcoef_posvsamp{ii,jj}=coff;
            coff=corrcoef([pax predmat(:,2:end)]);        %correlation of position with all predictors (assuming first term constant)
            coff=coff(1,:);
            corrcoef_posvspred{ii,jj}=coff;

%compute some stats on the residuals of the prediction??
            yhat=predmat*b;
            
            predres=yhat-pax;
            
            
            
            
%plot predicton residuals?
            plot(pax,predres,'.');
            xlabel('Measured coordinate');
            ylabel('Prediction residuals');
            title(['Sens/Coord./Pass ' int2str([ii jj ipass])]);
%            axis equal
            grid on
            
            drawnow;
            disp(['R square : ' num2str(stats(1))]);
            disp(['meanabs and sd of prediction residuals : ' num2str([mean(abs(predres)) std(predres)])]);            
            %will only be different for PC method
            disp(['r Position vs. amps                : ' num2str(corrcoef_posvsamp{ii,jj})]);
            disp(['r Position vs. preds               : ' num2str(corrcoef_posvspred{ii,jj})]);
            
            
                                keyboard
        end;
    end;
    
    
    save([outfile mysuff],'bc','statsc','corrcoef_posvsamp','corrcoef_posvspred','regn','ampfac','pc','x2fx_mode');
    %   drawnow
    
end;        %npass
