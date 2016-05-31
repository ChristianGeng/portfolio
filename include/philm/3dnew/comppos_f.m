function [rmsstat,tangstat,eucstat,dtstat,trialn,posstat,oristat]=comppos_f(basepath,altpath,triallist,kanallistb,autoflag,colist)
% COMPPOS_F Compare positions, also rms, tangvel, dt, between sensors or processing versions
% function [rmsstat,tangstat,eucstat,dtstat,trialn,posstat,oristat]=comppos_f(basepath,altpath,triallist,kanallistb,autoflag,colist)
% comppos_f: Version 5.10.05
%
%   Description
%       basepath, altpath: Common part of file name (without 4 digit trial
%       number, but with final backslash if name only consists of digits). Altpath is optional
%       statistics returned for first sensor in list:
%           mean, std, max, min, 2.5%tile, 97.5%tile
%           number of non-NaN data in trialn
%       triallist can be a list of trials
%       or list of trials (col 1) and cut start and end (cols 2 and 3)


%[dataout,descriptor,unit,dimension,sensorlist]=loadpos_sph2cartm(posfile);

radfac=pi/180;       %convert orientations to radians ???temporary???

myprctile=[2.5 97.5];   %percentiles for statistics
nlist=size(triallist,1);

tsub=0;
if size(triallist,2)==3 tsub=1; end;
%stats for first channel in list
rmsstat=ones(nlist,6)*NaN;
tangstat=ones(nlist,6)*NaN;
eucstat=ones(nlist,6)*NaN;
dtstat=ones(nlist,6)*NaN;
trialn=ones(nlist,1)*NaN;

%mean for first channel in list
posstat=ones(nlist,3)*NaN;
oristat=ones(nlist,2)*NaN;


%same for both figs
sprow=2;
spcol=2;

colabel=str2mat('x','y','z','phi','theta','rms','dt');

sf=200;
%colist=[1 2 3];       %not more than 4
nco=length(colist);
maxkanal=12;        %assume fixed
%kanallistb=[1 6];
lastfpos=[];
hf1=figure;
hf2=figure;
lasttrial=0;

for ilist=1:nlist
    trialdata=triallist(ilist,:);
%    disp(['Trial data: ' int2str([ilist trialdata(1)]) ' ' num2str(trialdata(2:3))]);
    disp(['Trial data: ' int2str([ilist trialdata(1)])]);
    mytrial=trialdata(1);
    if mytrial~=lasttrial
        disp('reading 1');
%        pbig1=loadpos([basepath '\rawpos\' int2str0(mytrial,4) '.pos']);
    file1=[basepath  int2str0(mytrial,4)];
pbig1=loadpos(file1);

%should allow for different sample rates in main and alternative input
%set up true time axis

sf=mymatin(file1,'samplerate',200);

    end;
    if ~isempty(pbig1)

        if tsub
            segdata=round(trialdata(2:3)*sf)+1;
            pp1=pbig1(segdata(:,1):segdata(:,2),:,:);
        else
            pp1=pbig1;
        end;


        %pp2=loadpos(['rawposadj\' int2str0(mytrial,4) '.pos']);
        %dt1=mymatin(['rawposorg\posampdt\posampdt_' int2str0(mytrial,4)],'data');
        %dt2=mymatin(['rawposadj\posampdt\posampdt_' int2str0(mytrial,4)],'data');

        kanallist=kanallistb;
        pp2=[];
        if ~isempty(altpath)
            if mytrial~=lasttrial
        disp('reading 2');
%                pbig2=loadpos([altpath '\rawpos\' int2str0(mytrial,4) '.pos']);
                pbig2=loadpos([altpath  int2str0(mytrial,4)]);
            end;
            if tsub
                pp2=pbig2(segdata(:,1):segdata(:,2),:,:);
            else
                pp2=pbig2;
            end;
            pp1=cat(3,pp1,pp2);
            kanallist=[kanallist kanallistb+maxkanal];
        end;
        nkanal=length(kanallist);
        lasttrial=mytrial;
        figure(hf1)
        %        if ~isempty(lastfpos) set(hf1,'position',lastfpos(1,:)); end;
        %        disp(mytrial);

        %means of position and orientation for first channel in list
        posstat(ilist,:)=nanmean(pp1(:,1:3,kanallist(1)));
        
        [tmpox,tmpoy,tmpoz]=sph2cart(pp1(:,4,kanallist(1))*radfac,pp1(:,5,kanallist(1))*radfac,1);
        tmpo=nanmean([tmpox tmpoy tmpoz]);
        [tmpphi,tmptheta,dodo]=cart2sph(tmpo(1),tmpo(2),tmpo(3));
        oristat(ilist,:)=[tmpphi tmptheta]/radfac;
        
%temporary!!!
%        pp1(:,1:3,kanallist(1))=[tmpox tmpoy tmpoz];
        for ico=1:nco
            pptmp=squeeze(pp1(:,colist(ico),kanallist));
            if ilist==1
        if ico==1 hl=ones(length(kanallist),nco)*NaN; end;
                hax(ico)=subplot(sprow,spcol,ico);
                hl(:,ico)=plot(pptmp);
%               keyboard;
                if ico==1
                    legend(hl(:,ico),int2str(kanallist'));
                end;
                title(colabel(ico,:));
            else
                doplot(hl(:,ico),pptmp);
           end;

            drawnow;
            %if ~isempty(pp2)
            %    hold on
            %hl2=plot(squeeze(pp2(:,colist(ico),kanallist)));
            %end;
        end;
        figure(hf2);
        %        if ~isempty(lastfpos) set(hf2,'position',lastfpos(2,:)); end;

        eucbuf=zeros(size(pp1,1)-1,nkanal);
        for ikanal=1:nkanal
            posdat=pp1(:,1:3,kanallist(ikanal));
            euctmp=eucdistn(posdat(1:end-1,:),posdat(2:end,:))*sf;
            eucbuf(:,ikanal)=euctmp;
        end;

        if ilist==1
            spi=1;
            hax2(spi)=subplot(sprow,spcol,spi);
            hltang=plot(eucbuf);
            title('Tangential velocity');
        else
            doplot(hltang,eucbuf);
        end;

        drawnow;

        tangstat(ilist,:)=[nanmean(eucbuf(:,1)) nanstd(eucbuf(:,1)) max(eucbuf(:,1)) min(eucbuf(:,1)) prctile(eucbuf(:,1),myprctile)];

        rmsbuf=squeeze(pp1(:,6,kanallist));       %rms
        if ilist==1
            spi=2;
            hax2(spi)=subplot(sprow,spcol,spi);
            hlrms=plot(rmsbuf);
            title('rms');
        else
            doplot(hlrms,rmsbuf);
        end;

        rmsstat(ilist,:)=[nanmean(rmsbuf(:,1)) nanstd(rmsbuf(:,1)) max(rmsbuf(:,1)) min(rmsbuf(:,1)) prctile(rmsbuf(:,1),myprctile)];

        trialn(ilist)=sum(~isnan(rmsbuf(:,1)));
        drawnow;

        dtbuf=squeeze(pp1(:,7,kanallist));       %ampposampdt
        if ilist==1
            spi=3;
            hax2(spi)=subplot(sprow,spcol,spi);
            hldt=plot(dtbuf);
            title('amp vs. posamp dt');
        else
            doplot(hldt,dtbuf);
        end;

        dtstat(ilist,:)=[nanmean(dtbuf(:,1)) nanstd(dtbuf(:,1)) max(dtbuf(:,1)) min(dtbuf(:,1)) prctile(dtbuf(:,1),myprctile)];
        drawnow;

        %if ~isempty(pp2)
        %    hold on
        %    plot(squeeze(pp2(:,6,kanallist)));       %rms
        %end;

        %could do for successive pairs in the channel list ?????
        npair=length(kanallist)-1;
        pairleg=cell(npair,1);
        if npair
            eucbuf=[];
            for ipair=1:npair
                ch1=kanallist(ipair);
                ch2=kanallist(ipair+1);
                euctmp=eucdistn(pp1(:,1:3,ch1),pp1(:,1:3,ch2));
                eucbuf=[eucbuf euctmp];     %not very efficient
                pairleg{ipair}=[int2str(ch1) '-' int2str(ch2)];
            end;
            if ilist==1
                spi=4;
                hax(spi)=subplot(sprow,spcol,spi);
                hleuc=plot(eucbuf);
                hlegeuc=legend(hleuc,pairleg);

                title('Euclidean distance');
            else
                doplot(hleuc,eucbuf);
            end;

            drawnow;

            eucstat(ilist,:)=[nanmean(eucbuf(:,1)) nanstd(eucbuf(:,1)) max(eucbuf(:,1)) min(eucbuf(:,1)) prctile(eucbuf(:,1),myprctile)];


        end;

        %if ~isempty(pp2)
        %hold on
        %euctmp=eucdistn(pp2(:,1:3,kanallist(1)),pp2(:,1:3,kanallist(2)));

        %plot(euctmp);
        %end;
        if ilist==1
            disp('adjust window position if desired');
            keyboard;
        end;

        if ~autoflag pause; end;
        %        lastfpos=[get(hf1,'position');get(hf2,'position')];
        %        delete([hf1 hf2]);
    end;
end;
function doplot(hl,pptmp);
nl=length(hl);

for ii=1:nl set(hl(ii),'ydata',pptmp(:,ii));end;

