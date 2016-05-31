function predictsensorfromothers(pospath,outfile,trialbuf,sufbuf,sensor2predict,sensorsused,pcorder,rmsthreshb,velthreshb,compsens,eucthresh,parameter7b)
% predictsensorfromothers Prediction of sensor coordinates from other sensors
% function predictsensorfromothers(pospath,outfile,trialbuf,sufbuf,sensor2predict,sensorsused,pcorder,rmsthreshb,velthreshb,compsens,eucthresh,parameter7b)
% predictsensorfromothers: Version 8.2.07
%
%   Syntax
%       pospath:    Common part of pos file names.
%       outfile:    mat file with analysis results. This is used by
%           calcsensorfromothers to actually calculate the estimated positions
%       trialbuf:   cell array, each cell containing list of trials to use
%                   for each pass
%       sufbuf:     string matrix with suffix for outfile corresponding to each entry in trialbuf
%       sensor2predict: The sensor to be predicted; currently only one
%           sensor at a time can be predicted
%       sensorsused:    list of sensors to use in the prediction
%       pcorder: The prediction is done in two ways: First by using all the
%           coordinates of the sensors in sensorsused, and also by first doing
%           a principal component analysis of the data for these sensors. The
%           number of PCs given in pcorder is then used for the prediction. A
%           plot of the cumuluative sum of the eigenvalues is displayed to help
%           decide how many to use.
%       The sensor number (in sensor2predict and sensorsused) is used as an index into rmsthreshb etc
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
%       8.06 "parameter7" added. This is the parameter in the position file
%       with currently no fixed usage. Normally used by EUCDIST2POS to
%       store difference between alternative solutions
%
%   Description
%       predictsensorfromothers and calcsensorfromothers form a pair of
%       functions that must be used together (like ampvsposampa7pc and
%       adjampsapc).
%       This function is mainly intended to be used where the tapad
%       solution for sensor2predict appears unstable. It could, for example, provide a
%       robust starting position for tapad in recursive mode. It could also
%       be used to get a rough idea of where the correct solution is
%       likely to be.
%
%   See Also
%       CALCSENSORFROMOTHERS ADJAMPSAPC AMPVSPOSAMPA7PC

functionname='predictsensorfromothers: Version 8.2.07';

nsensor=12;

plotdec=10;     %decimation rate for plots of amps vs. residuals

%should be taken from descriptor of input file
% note different from original ampvsposampa7 as loadpos_sph2cartm used for
% input
rmsp=7;
p7p=8;

if length(rmsthreshb)==1 rmsthreshb=repmat(rmsthreshb,[nsensor 1]); end;
if length(velthreshb)==1 velthreshb=repmat(velthreshb,[nsensor 1]); end;
if length(parameter7b)==1 parameter7b=repmat(parameter7b,[nsensor 1]); end;
if length(compsens)==1 compsens=repmat(compsens,[nsensor 1]); end;


npass=length(trialbuf);


%normally from input file
sf=200;



for ipass=1:npass

    triallist=trialbuf{ipass};
    mysuff=deblank(sufbuf(ipass,:));



    ntrial=length(triallist);

    trialp=ones(ntrial,2);
    %work out length of each trial so storage can be allocated
    disp('determining trial lengths');
    for iti=1:ntrial
        tt=triallist(iti);
        tts=int2str0(tt,4);

        %rather than actually loading use whos
        %could also check trial is actually present and update list at end
        %of loop
        W=whos('-file',[pospath tts],'data');
        mysize=W.size;
        %        [a,descriptor,unit,dimension,sensorlist]=loadpos_sph2cartm([pospath tts]);

        nsamp=mysize(1);
        trialp(iti,2)=trialp(iti,1)+nsamp-1;
        if iti<ntrial trialp(iti+1,1)=trialp(iti,2)+1; end;
    end;
    disp(trialp)
    %keyboard;
    buflen=trialp(end,2);

    %maybe allow for selection of coordinates used, e.g position only
    nco=6;
    npar=nco+2;     %should also check with whos
    predictor_coordinates=1:nco;

    npreds=length(sensorsused);
    npredc=length(predictor_coordinates);
    ndig=4;


    %not ideal if large number of samples but not many sensors used
    bigbuf=repmat(NaN,[buflen npar nsensor]);


    bc=cell(2,nco);         %store results of both rawdata and PC approach (1=raw, 2 = PC)
    statsc=bc;


    %load all data, scan for bad data

    for iti=1:ntrial
        %                disp(iti)
        tt=triallist(iti);
        tts=int2str0(tt,ndig);
        posfile=[pospath tts];
        [data,descriptor,unit,dimension,sensorlist]=loadpos_sph2cartm(posfile);

        bigbuf(trialp(iti,1):trialp(iti,2),:,:)=data;
        if iti==1 sf=mymatin(posfile,'samplerate',200); end;        %check always the same??
    end;

    disp('data read');
    disp('Checking for bad data');

    checklist=[sensor2predict sensorsused];

    badlist=zeros(buflen,1);

    for ii=checklist
        disp(['Checking Sensor ' int2str(ii)]);

        rmsthresh=rmsthreshb(ii);
        velthresh=velthreshb(ii);
        parameter7=parameter7b(ii);

        vrms=(bigbuf(:,rmsp,ii)>rmsthresh) | isnan(bigbuf(:,1,ii));
        vp7=bigbuf(:,p7p,ii)>parameter7;
        postmp=bigbuf(:,1:3,ii);
        tangvel=eucdistn(postmp(1:end-1,:),postmp(2:end,:));
        tangvel=tangvel*sf;
        vtv=tangvel>velthresh;
        vtv=[vtv;vtv(end)];

        veucd=zeros(buflen,1);
        if ~isnan(compsens(ii))
            compdata=bigbuf(:,1:3,compsens(ii));
            euccomp=eucdistn(postmp,compdata);
            veucd=euccomp<eucthresh(ii,1) | euccomp>eucthresh(ii,2);
        end;
        vtmp=vrms | vp7 | vtv | veucd;

        if any(vtmp)
            %                        disp(eucthresh(ii,:));
            disp(['Bad samples (rms, vel., euc., p7, overall : ' int2str(sum([vrms vtv veucd vp7 vtmp]))]);
        end;


        badlist=badlist | vtmp;
    end;        %checklist

    %set neighbouring samples to bad samples to bad
    %    vx=[badlist(2:end);0] | [badlist(3:end);0;0] | [0;badlist(1:end-1)] | [0;0;badlist(1:end-2)];
    vx=[badlist(2:end);0]  | [0;badlist(1:end-1)] ;
    badlist=badlist | vx;




    nbad=sum(badlist);
    disp(['Total/unreliable samples : ' int2str([buflen nbad])]);
    %end;

    bigbuf(badlist,:,:)=[];

    nuse=size(bigbuf,1);
    disp(['n for regression: ' int2str(nuse)]);

    targetb=bigbuf(:,1:nco,sensor2predict);
    predictorb=bigbuf(:,predictor_coordinates,sensorsused);


    keyboard;

    datin=reshape(predictorb,[nuse npredc*npreds]);
    %if both positions and orientations are used then covariance method should
    %probably not be used
    %so if a choice of predictor coordinates is possible then covflag could
    %also be configurable
    covflag=0;
    sigma=2.5;
    np=100;
    nscore=pcorder;

    PC.pcorder=nscore;

    %skip if zero????
    disp('Computing principal components');
    [xbar,sdev,com,eigval,eigvec,outind,eli,rmserror]=elli(datin,sigma,np,nscore,covflag);

    PC.xbar=xbar;
    PC.sdev=sdev;
    PC.com=com;
    PC.eigval=eigval;
    PC.eigvec=eigvec;
    PC.rmserror=rmserror;
    PC.covflag=covflag;


    plot(cumsum(eigval));
    title('Cumulative variance explained');
    keyboard;
    close
    pcscores=mymatin('pcscore','pcscore');

    for ico=1:nco
        disp(['Prediction for coordinate ' int2str(ico)]);

        codata=targetb(:,ico);
        disp('1: using raw data');
        imethod=1;
        %keyboard;
        [b,stats]=robustfit(datin,codata);
        bc{imethod,ico}=b;
        statsc{imethod,ico}=stats;



        yhat=[ones(nuse,1) datin]*b;

        prederror=codata-yhat;

        disp(['meanabs and sd of prediction error : ' num2str([mean(abs(prederror)) std(prederror)])]);
        figure;
        plot(codata,yhat,'.');
        title([int2str(ico) ' raw data regression']);
        xlabel('Measured');ylabel('Predicted');
        disp('2: using PCs');
        imethod=2;
        [b,stats]=robustfit(pcscores,codata);

        bc{imethod,ico}=b;
        statsc{imethod,ico}=stats;




        yhat=[ones(nuse,1) pcscores]*b;

        prederror=codata-yhat;

        disp(['meanabs and sd of prediction error : ' num2str([mean(abs(prederror)) std(prederror)])]);

        figure;
        plot(codata,yhat,'.');
        title([int2str(ico) ' PC regression']);
        xlabel('Measured');ylabel('Predicted');

    end;            %loop thru coordinates

    %store
    outname=[outfile '_s' int2str0(sensor2predict,2) '_' mysuff];
    save(outname,'bc','statsc','sensor2predict','sensorsused','PC','predictor_coordinates');


end;    %loop thru passes
