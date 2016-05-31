function velocitypredpos(inpath1,amppath,outpath,triallist,chanlist,filterspec,veldifflim)
% VELOCITYPREDPOS Compute position estimate directly from differentiated amplitudes; smooth output
% function velocitypredpos(inpath,amppath,outpath,triallist,chanlist,filterspec,veldifflim)
% velocitypredpos: Version 20.6.07
%
%   Description
%       Based on velocityrepair, but computes estimated position for
%       complete trials, rather than just repairing dodgy regions.
%       set dodgy velocity regions to nan, then repair using velocity
%       predicted from differentiated amplitudes.
%       Any NaNs already in input are also repaired in this way (e.g from
%       outliers2nan)
%       Finally, the data can be filtered (probably smoothed)
%       and then the rms parameter is recalculated for the new data
%
%   Syntax
%       inpath: The path to the input position data (without backslash)
%       amppath: path to the amplitude data (needed for calculating predicted velocity and recalculating rms)
%       outpath: path for the output position data
%       triallist/chanlist: Vector of trials/channels to process
%       filterspec: m*2 cell array. In first column name of mat file with
%       filter coefficients for FIR filter
%       In second column, vector of channels to which the filter is to be
%       applied
%       veldifflim: Vector of thresholds for difference between measured tangential
%       velocity and predicted tangential velocity. If length==1 same
%       threshold used for all channels
%       Also outputs a mat file with a list of samples fixed
%
%   Notes
%       Orientations assumed to be in degrees
%       Factor 2500 hardcoded for rms calculations
%
%   See Also
%       CALCAMPS tapadm function for getting amp data for calculated position
%       MERGEBYMEANSQU merge two inputs
%       OUTLIERS2NAN set missing data based on tangetial velocity, rms or
%       euclidean distance criterion
%       VELOCITYREPAIR

functionname='velocitypredpos: Version 20.6.07';


%rmsfac=1;
rmsfac=2500;
%orifac=1;       %ev pi/180 for degrees to rad
orifac=pi/180;

maxchan=12;

subprow=3;
subpcol=4;

myver=version;

saveop='';
if myver(1)>='7' saveop='-v6'; end;


if length(veldifflim)==1 veldifflim=repmat(veldifflim,[maxchan 1]); end;
if size(veldifflim,2)==1 veldifflim=veldifflim'; end;

%euclim=50;



cofbuf=cell(maxchan,1);
filtername=cell(maxchan,1);
filtercomment=cell(maxchan,1);
filtern=zeros(maxchan,1);

nfrow=size(filterspec,1);

for ifi=1:nfrow
    tmpname=filterspec{ifi,1};
    fchan=filterspec{ifi,2};
    mycoffs=mymatin(tmpname,'data');
    mycomment=mymatin(tmpname,'comment');
    myn=length(mycoffs);
    nc=length(fchan);
    for ific=1:nc
        mychan=fchan(ific);
        cofbuf{mychan}=mycoffs;
        filtername{mychan}=tmpname;
        filtercomment{mychan}=mycomment;
        filtern(mychan)=myn;
    end;
end;

newcomment=['Input , Amps, Output : ' inpath1 ' ' amppath ' ' outpath crlf ...
        'First/last/n trials: ' int2str([triallist(1) triallist(end) length(triallist)]) crlf ...
        'Sensor list: ' int2str(chanlist) crlf ...
        'Velocity difference thresholds: ' int2str(veldifflim) crlf];

myblanks=(blanks(maxchan))';
filtercomment=strcat(int2str((1:maxchan)'),' File: ',filtername,' " ',filtercomment,' ", ncof = ',int2str(filtern));
newcomment=[newcomment 'Filter specs for each channel:' crlf strm2rv(char(filtercomment),crlf) crlf];

figure;
for itrial=triallist
    disp(itrial);
    ts=int2str0(itrial,4);
    
    inname=[inpath1 ts];
    outname=[outpath ts];
    matin=0;
    comment='';
    if exist([inname '.mat'])
        matin=1;
        copyfile([inname '.mat'],[outname '.mat']);
        comment=mymatin(inname,'comment');
        sf=mymatin(inname,'samplerate',200);
        private=mymatin(inname,'private');        
    end;
    
    
    
    pp1=loadpos(inname);
    if ~isempty(pp1)
        
        repaired_data=cell(maxchan,1);
        repaired_samples=cell(maxchan,1);
        comment=framecomment(comment,'Comment from input file');
        comment=[newcomment comment];
        comment=framecomment(comment,functionname);
        
        
        aa=loadamp([amppath ts]);
        
        
        %        pout=ones(size(pp1))*NaN;
        pout=pp1;
        
        for ich=chanlist
            %use loadpos_sph2cartm?????
            pos1=pp1(:,1:3,ich);
            ori1=pp1(:,4:5,ich)*orifac;
            ms1=pp1(:,6,ich).^2;
            [ox1,oy1,oz1]=sph2cart(ori1(:,1),ori1(:,2),1);
            
            d1=[pos1 ox1 oy1 oz1];
            dout=d1;
            nco=size(d1,2);
            
            vn1=isnan(d1(:,1));         %nans in input
            nancntin=sum(vn1);
            if nancntin disp(['Channel ' int2str(ich) ' : NaNs in input ' int2str(nancntin)]); end;
            
            
            ax=aa(:,:,ich);
            
            [pxdpred,eucdiff]=getpredvel(ax,d1,sf);
            
            
            vned=eucdiff>veldifflim(ich);
            %also set next sample to nan
            vned=vned | [0;vned(1:end-1)];
            
            %and small gaps????
            
            %and copy last value to match length of non-differentiated
            %data
            vned=[vned;vned(end)];
            
            %further criterion: position difference between input and
            %filtered ????
            
            %maybe recompute coefficients using final set of no-nan data
            
            vnall=vn1 | vned;
            
            d1(vnall,:)=NaN;
            
            pxdpred0=pxdpred;
            [pxdpred,eucdiffx]=getpredvel(ax,d1,sf);
            
            %            figure;
            subplot(subprow,subpcol,ich); 
            plot([eucdiff eucdiffx]);
            drawnow;            
            for ipi=1:nco
                
                mydat=cumsum(pxdpred(:,ipi)/sf);
                mydat=[0;mydat];
                
                myipi=(1:length(mydat))';
                mydiff=d1(:,ipi)-mydat;
                vok=find(not(vnall));
                
                %basically, integrating the velocity should reconstruct the position except
                %for a constant term (difference in means), but also allow for linear trend
                %i.e slow drift (low frequency noise)
                %also, exclude the unreliable data when making this estimate
                
                cofftrend=robustfit(myipi(vok),mydiff(vok));
                %                keyboard;
                yhattrend=[ones(length(mydat),1) myipi]*cofftrend;
                
                
                %looks like robustfit may fail when the input data is very wild
                %insuch cases match means as an alternative
                if any(isnan(cofftrend))
                    mydat=mydat-mean(mydat(vok))+mean(dout(vok,ipi));
                else
                    
                    
                    
                    mydat=mydat+yhattrend;
                    
                end;
                
                %simple version: just adjust means, no exclusion of dodgy data
                %                mydat=mydat-mean(mydat)+mean(dout(:,ipi));
                %                keyboard;
                
                dout(:,ipi)=mydat;
            end;            %nco
            
            
            
            if filtern(ich)
                disp('filtering')
                
                for ipi=1:nco
                    b=cofbuf{ich};
                    dout(:,ipi)=decifir(b,dout(:,ipi));
                end;
                
                %                keyboard;
            end;
            %         keyboard;
            
            
            pout(:,1:3,ich)=dout(:,1:3);
            oriout=ones(size(pout,1),2)*NaN;
            [oriout(:,1),oriout(:,2),dodo]=cart2sph(dout(:,4),dout(:,5),dout(:,6));
            
            pout(:,4:5,ich)=oriout/orifac;      %convert back to degrees if necessary
            pax=calcamps(pout(:,1:5,ich));
            
            %parameter 7 no longer relevant, so store posampdt (may be overwritten
            %later anyway but e.g eucdist2pos
            [pout(:,6,ich),pout(:,7,ich)]=posampana(aa(:,:,ich),pax,rmsfac);
            %            disp('new rms calculated');
            %                        keyboard;
            %            close all
            
            
        end;        %channel list
        
        %always output as mat file, but some variables will be missing if
        %input was not mat
        data=single(pout);
        %        if isfield('velocityrepair',private)
        %            private.velocityrepair.velocityrepair=private.velocityrepair;
        %        end;
        %        private.velocityrepair.repaired_samples=repaired_samples;
        %        private.velocityrepair.repaired_data=repaired_data;
        
        
        if matin
            save(outname,'data','comment','private','-append',saveop);
        else
            save(outname,'data','comment','private',saveop);
        end;
        
        
        
        %    savepos([outpath pathc ts '.pos'],pout);
    end;            %input not empty
end;                %trial list

%save mergebymeansqu_nans nancntbuf nanvec
function [pxdpred,eucdiff]=getpredvel(ax,d1,sf);

nco=size(d1,2);

adx=diff(ax);





%also need coefficients for orientation components
coliste=1:3; %coordinates for tangential velocity calculation
coffc=cell(nco,1);

%use no-nan data to compute prediction coefficients
%filter position data first? Means replacing any nans in input

pxd=diff(d1)*sf;
vnnx=~isnan(pxd(:,1));
pxdpred=pxd*NaN;
ndatd=size(pxd,1);
ndat=size(d1,1);
for ipi=1:nco
    warning off backtrace
    coffc{ipi}=robustfit(adx(vnnx,:),pxd(vnnx,ipi));
    warning on backtrace
    %    keyboard;
    yhat=[ones(ndatd,1) adx]*coffc{ipi}; 
    pxdpred(:,ipi)=yhat; 
end;



eucin=(sqrt(sum((pxd(:,coliste).^2)')))';
eucpred=(sqrt(sum((pxdpred(:,coliste).^2)')))';
eucdiff=abs(eucin-eucpred);
%figure
%plot([eucin eucpred]);
%drawnow;

