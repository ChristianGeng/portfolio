function velocityrepair(inpath1,amppath,outpath,triallist,chanlist,filterspec,veldifflim)
% VELOCITYREPAIR Repair signal with predicted velocity; smooth output
% function velocityrepair(inpath,amppath,outpath,triallist,chanlist,filterspec,veldifflim)
% velocityrepair: Version 08.04.2013
%
%   Description
%       set dodgy velocity regions to nan, then repair using velocity
%       predicted from differentiated amplitudes.
%       Any NaNs already in input are also repaired in this way (e.g from
%       outliers2nan)
%       Finally, the data can be filtered (probably smoothed)
%       and then the rms parameter is recalculated for the new data
%
%   Syntax
%       inpath: The path to the input position data (with final pathchar, assuming filenames are simply the 4 digits of the trial number)
%       amppath: path (with final pathchar) to the amplitude data (needed for calculating predicted velocity and recalculating rms)
%       outpath: path for the output position data (with final pathchar)
%           !!this must be created beforehand by the user, as well as the
%           subdirectory posamps!!
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
%       For AG501 input rms cannot currently be re-calculated after
%       filtering
%
%   See Also
%       CALCAMPS tapadm function for getting amp data for calculated position
%       MERGEBYMEANSQU merge two inputs
%       OUTLIERS2NAN set missing data based on tangetial velocity, rms or
%       euclidean distance criterion
%
%   Updates
%       4.2013 Handle AG501 data (currently simply means that rms and
%       posamps are not recalculated)

functionname='velocityrepair: Version 08.04.2013';


%rmsfac=1;
rmsfac=2500;
%orifac=1;       %ev pi/180 for degrees to rad
orifac=pi/180;

maxchan=24;

%nan regions will be extended this number of samples
%and then any non-nan stretches less than this length will also be set to
%nan
holelim=3;

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

maxfchan=0;
for ifi=1:nfrow
    tmpname=filterspec{ifi,1};
    fchan=filterspec{ifi,2};
    mycoffs=mymatin(tmpname,'data');
    mycomment=mymatin(tmpname,'comment');
    myn=length(mycoffs);
    nc=length(fchan);
    for ific=1:nc
        mychan=fchan(ific);
        if mychan>maxfchan maxfchan=mychan; end;
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
%trim unused or unavailable channels
if maxfchan>0
    filtercomment=filtercomment(1:maxfchan,:);
end;

newcomment=[newcomment 'Filter specs for each channel:' crlf strm2rv(char(filtercomment),crlf) crlf];

hf=figure;

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
        
        %use this as an indicator of an AG501 systen
        try
            ntrans=private.loadpos.ntrans;
        catch
            ntrans=6;
        end;
        
        %for AG501 posamps cannot be recalculated
        if ntrans==6
            %assume posamps file is available
            
            copyfile([inpath1 'posamps' pathchar ts '.mat'],[outpath 'posamps' pathchar ts '.mat']);
        else
            disp('Treating as AG501 data');
        end;
        
    end;
    
    
    
    pp1=loadpos(inname);
    
    if ~isempty(pp1)
        
        repaired_data=cell(maxchan,1);
        repaired_samples=cell(maxchan,1);
        comment=framecomment(comment,'Comment from input file');
        newcommentx=newcomment;
        if ntrans~=6
            newcommentx=['Assuming not an AG500 system, so rms and posamps not re-calculated (ntrans = ' int2str(ntrans) ')' crlf newcommentx];
        end;
        
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
            
            
            if ~isnan(veldifflim(ich))
                ax=aa(:,:,ich);
                adx=diff(ax);
                
                
                
                
                
                %also need coefficients for orientation components
                coliste=1:3; %coordinates for tangential velocity calculation
                coffc=cell(nco,1);
                
                %use no-nan data to compute prediction coefficients
                %filter position data first? Means replacing any nans in input
                ndat=size(d1,1);
                
                pxd=diff(d1)*sf;
                
                pxdpred=getpred(pxd,adx);
                
                
                eucin=(sqrt(sum((pxd(:,coliste).^2)')))';
                eucpred=(sqrt(sum((pxdpred(:,coliste).^2)')))';
                eucdiff=abs(eucin-eucpred);
                %                figure
                subplot(2,1,1);
                plot([eucin eucpred]);
                title(int2str([itrial ich]));
                %                figure;
                subplot(2,1,2);
                plot(eucdiff);
                drawnow;
                vned=eucdiff>veldifflim(ich);
                %also set next sample to nan
                vned=vned | [0;vned(1:end-1)];
                
                %and copy last value to match length of non-differentiated
                %data
                vned=[vned;vned(end)];
                
                %further criterion: position difference between input and
                %filtered ????
                
                vnall=vn1 | vned;
                
                if any(vnall)
                    %keyboard;
                    
                    %in combination with the search for 'holes', this extends the nan regions
                    nvnall=length(vnall);
                    vvn=find(vnall);
                    vvn=[vvn;vvn+holelim;vvn-holelim];
                    vvn(vvn<1)=[];
                    vvn(vvn>nvnall)=[];
                    vvn=unique(vvn);
                    vnall=zeros(nvnall,1);
                    vnall(vvn)=1;
                    
                    
                    vstart=find(diff(vnall)==1);
                    vstart=vstart+1;
                    if vnall(1) vstart=[1;vstart]; end;
                    vend=find(diff(vnall)==-1);
                    if vnall(ndat) vend=[vend;ndat]; end;
                    %check start and end lists match
                    nhole=length(vstart);
                    %                    disp('hole indices');
                    %                    disp([vstart vend]);
                    
                    %merge small islands between holes
                    for ihi=1:nhole-1
                        if vstart(ihi+1)-vend(ihi) < holelim
                            vstart(ihi+1)=NaN;
                            vend(ihi)=NaN;
                        end;
                    end;
                    vstart=vstart(~isnan(vstart));
                    vend=vend(~isnan(vend));
                    
                    disp('after merging holes');
                    disp([vstart vend]);
                    
                    nhole=length(vstart);
                    
                    nanlist=[];
                    for ihi=1:nhole nanlist=[nanlist vstart(ihi):vend(ihi)]; end;
                    repaired_samples{ich}=nanlist;
                    repaired_data{ich}=pp1(nanlist,:,ich);
                    
                    %recompute the prediction
                    dtmp=d1;
                    dtmp(nanlist,:)=NaN;
                    pxd=diff(dtmp)*sf;
                    
                    pxdpred=getpred(pxd,adx);
                    
                    
                    for ipi=1:nco
                        
                        for ihi=1:nhole
                            %                            disp([ipi ihi]);
                            hdone=0;
                            %special case for start
                            if ihi==1
                                if vstart(1)==1
                                    disp('skipping initial hole')
                                    hdone=1;
                                    %                                    keyboard;
                                end;
                            end;
                            %special case for end
                            if ihi==nhole
                                if vend(nhole)==ndat
                                    ipi1=vstart(ihi);
                                    ipi2=vend(ihi);
                                    mydat=cumsum(pxdpred((ipi1-1):ipi2-1,ipi)/sf);
                                    p1=d1(ipi1-1,ipi)+mydat;
                                    newdat=p1;
                                    dout(ipi1:ipi2,ipi)=newdat;
                                    %                               disp('repairing final hole')
                                    hdone=1;
                                end;
                            end;
                            
                            if ~hdone
                                %normal case
                                ipi1=vstart(ihi);
                                ipi2=vend(ihi);
                                mydat=cumsum(pxdpred((ipi1-1):ipi2,ipi)/sf);
                                p1=d1(ipi1-1,ipi)+mydat;
                                p2=p1-(p1(end)-d1(ipi2+1,ipi));
                                p1(end)=[];
                                p2(end)=[];
                                w1=linspace(1,0,length(p1));
                                w2=linspace(0,1,length(p1));
                                newdat=p1.*w1' + p2.*w2';
                                dout(ipi1:ipi2,ipi)=newdat;
                                %                                disp('repairing')
                                %                        keyboard;
                            end;
                        end;            %nhole
                    end;            %nco
                end;            %any nans
            end;                %veldifflim not nan
            
            
            
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
%skip calcamps if AG501
            if ntrans==6
                pax=calcamps(pout(:,1:5,ich));
                
                %parameter 7 no longer relevant, so store posampdt (may be overwritten
                %later anyway but e.g eucdist2pos
                [pout(:,6,ich),pout(:,7,ich)]=posampana(aa(:,:,ich),pax,rmsfac);
                %            disp('new rms calculated');
            end;
            %                        keyboard;
            %            close all
            
            
        end;        %channel list
        
        %always output as mat file, but some variables will be missing if
        %input was not mat
        data=single(pout);
        if isfield('velocityrepair',private)
            private.velocityrepair.velocityrepair=private.velocityrepair;
        end;
        private.velocityrepair.repaired_samples=repaired_samples;
        private.velocityrepair.repaired_data=repaired_data;
        
        
        if matin
            save(outname,'data','comment','private','-append',saveop);
            %no posamps for AG501
            if ntrans==6
                data=single(pax);
                save([outpath 'posamps' pathchar ts ],'data','comment','-append',saveop);
            end;
        else
            save(outname,'data','comment','private',saveop);
        end;
        
        
        
        %    savepos([outpath pathc ts '.pos'],pout);
    end;            %input not empty
end;                %trial list

%save mergebymeansqu_nans nancntbuf nanvec
function pxdpred=getpred(pxd,adx);

vnnx=~isnan(pxd(:,1));
pxdpred=pxd*NaN;
ndatd=size(pxd,1);
nco=size(pxd,2);
for ipi=1:nco
    coffc{ipi}=robustfit(adx(vnnx,:),pxd(vnnx,ipi));
    %keyboard;
    yhat=[ones(ndatd,1) adx]*coffc{ipi};
    pxdpred(:,ipi)=yhat;
end;

