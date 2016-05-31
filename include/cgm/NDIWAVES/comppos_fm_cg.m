function [rmsstat,tangstat,eucstat,dtstat,trialn,costat]=comppos_f(basepath,altpath,triallist,kanallistb,autoflag,colist1,colist2)
% COMPPOS_FM Compare coordinates and additional parameters like rms between sensors or processing versions
% function [rmsstat,tangstat,eucstat,dtstat,trialn,costat]=comppos_fm(basepath,altpath,triallist,kanallistb,autoflag,colist1,colist2)
% comppos_fm: Version 09.05.08
%
%   Description
%       Input arguments:
%       basepath, altpath: Common part of file name (without 4 digit trial
%           number, but with final backslash if name only consists of digits). Altpath is optional
%       triallist: List of trials
%           or list of trials (col 1) and cut start and end in seconds (cols 2 and 3)
%       kanallistb: List of channels (sensors) to display
%           When both basepath and altpath are used (e.g to compare
%           different processing versions) then it is often easiest to just
%           have one channel in this list
%       autoflag: If true do not pause between trials
%       colist1: List of coordinates to display (up to 4)
%       colist2: Optional. Additional parameters to display (up to 2). If not
%       specified, the normal input file arrangement will result in rms and
%       the supplementary parameter being displayed
%       Note on colist1 and colist2:
%           If the input data has orientations in spherical coordinates
%           this is converted to unit vector representation. The program
%           then behaves as if the input data were arranged:
%               posx, posy, posz, orix, oriy, oriz, rms, supplementary parameter
%           So entries in colist1 and colist2 refer to this set of 8
%           parameters
%       Output arguments:
%       Various statistics are returned for the first sensor in the list.
%       Rows correspond to trials
%       For rmsstat, tangstat, eucstat and dtstat the columns are  mean, std, max, min, 2.5%tile, 97.5%tile
%       trialn contains (for each trial) the total data in col. 1 and the total non-NaN (i.e valid) data in col. 2
%       For costat the columns are the 6 coordinates (3 position + 3 orientation)
%       rmsstat contains rms values or whatever parameter is specified as
%       first entry in colist2
%       dtstat contains values of the supplementary parameter or whatever parameter is specified as
%       second entry in colist2
%       tangstat contains tangential velocity values for the first channel
%       in the list
%       eucstat contains the euclidean distance between the first and
%       second channel in the list (when only one channel is specified and
%       altpath is used then this will be the distance between this channel
%       in the two different input files. Channels from the altpath file
%       have 12 added to the channel number in the display legend)
%
%   Updates
%       5.08 trialn now returns total and valid data per trial



warning('off','all');

functionname='comppos_fm: Version 9.5.08';

myprctile=[2.5 97.5];   %percentiles for statistics
nlist=size(triallist,1);
ndig=4;         %could be made variable?

ncoord=6;       %assume fixed (3 position + 3 orientation

tsub=0;
if size(triallist,2)==3 tsub=1; end;
%stats for first channel in list
% columns are  mean, std, max, min, 2.5%tile, 97.5%tile

rmsstat=ones(nlist,6)*NaN;
tangstat=ones(nlist,6)*NaN;
eucstat=ones(nlist,6)*NaN;
dtstat=ones(nlist,6)*NaN;
trialn=ones(nlist,2)*NaN;

%mean for first channel in list (posx/y/z, and orix/y/z)
costat=ones(nlist,ncoord)*NaN;


%same for both figs, i.e one figure has rms, tang. vel., euc. dist and the
%additional parameter (e.g distance between different solutions)
%the other figure can show up to 4 of the 6 coordinates

sprow=2;
spcol=2;

maxco=sprow*spcol;

%get from descriptor
%colabel=str2mat('x','y','z','phi','theta','rms','dt');

%normally loaded from input file
sf=200;

colist=colist1;
nco=length(colist);

if nco>maxco
    disp('too many coordinates to display');
    return;
end;

rmsp=7;
extrap=8;
if nargin>6
    rmsp=colist2(1);
    if length(colist2)>1 extrap=colist2(2); end;
end;

maxkanal=12;        %assume fixed
%kanallistb=[1 6];
lastfpos=[];
hf1=figure;
hf2=figure;
lasttrial=0;

for ilist=1:nlist
    trialdata=triallist(ilist,:);
    if length(trialdata)>1
        disp(['Trial data: ' int2str([ilist trialdata(1)]) ' ' num2str(trialdata(2:3))]);
    else
        disp(['Trial data: ' int2str([ilist trialdata(1)])]);
    end;

    mytrial=trialdata(1);
    if mytrial~=lasttrial
        disp('reading 1');
        file1=[basepath  int2str0(mytrial,ndig)];

        [pbig1,descriptor,unit,dimension,sensorlist]=loadpos_sph2cartm(file1);

        if ~isempty(pbig1)
            %set up true time axis
            sf=mymatin(file1,'samplerate',200);
            disp(sf)
            tvecall=((1:size(pbig1,1))-1)*(1/sf);
            sensorlist=sensorlist(kanallistb,:);
        end;

    end;
    if ~isempty(pbig1)

        if tsub
            segdata=round(trialdata(2:3)*sf)+1;
            pp1=pbig1(segdata(:,1):segdata(:,2),:,:);
            tvec=tvecall(segdata(:,1),segdata(:,2));
        else
            pp1=pbig1;
            tvec=tvecall;
        end;

        kanallist=kanallistb;
        pp2=[];
        if ~isempty(altpath)
            if mytrial~=lasttrial
                disp('reading 2');
                file2=[altpath  int2str0(mytrial,ndig)];
                [pbig2,descriptor2,unit2,dimension2,sensorlist2]=loadpos_sph2cartm(file2);

                %should check units and dimension match first file
                sf2=mymatin(file2,'samplerate',200);

                sensorlist=char(sensorlist,sensorlist2(kanallistb,:));

                %allow for different sample rates by simple resampling
                if sf2~=sf
                    %                    ?????
                    tvec2=((1:size(pbig2,1))-1)*(1/sf2);
                    %interpolate
                    pbig2=interp1(tvec2,pbig2,tvecall);
                    pbig2=reshape(pbig2,size(pbig1));
                    %                    keyboard;
                end;
            end;
            if tsub
                pp2=pbig2(segdata(:,1):segdata(:,2),:,:);
            else
                pp2=pbig2;
            end;
            pp1=cat(3,pp1,pp2);
            maxkanal=size(pbig1,3);
            kanallist=[kanallist kanallistb+maxkanal];
        end;
        nkanal=length(kanallist);
        lasttrial=mytrial;
        figure(hf1)
        %        if ~isempty(lastfpos) set(hf1,'position',lastfpos(1,:)); end;
        %        disp(mytrial);

        %means of position and orientation for first channel in list from
        %basepath
        costat(ilist,:)=nanmean(pp1(:,1:ncoord,kanallist(1)));


        for ico=1:nco
            pptmp=squeeze(pp1(:,colist(ico),kanallist));
            if ilist==1
                if ico==1 hl=ones(length(kanallist),nco)*NaN; end;
                hax(ico)=subplot(sprow,spcol,ico);
                hl(:,ico)=plot(tvec,pptmp);
                %               keyboard;
                if ico==1
                    %                    keyboard;
                    [LEGH,OBJH,OUTH,OUTM]=legend(hl(:,ico),strcat(int2str(kanallist'),' : ',sensorlist));
                    
		    if ismatlab, 
		      hxxx=findobj(OBJH,'type','text');
		      set(hxxx,'interpreter','none'); 
		    end; % TODO:FIX
                end;
                title(descriptor(colist(ico),:),'interpreter','none');
                xlabel('Time (s)');
                ylabel(unit(colist(ico),:));
            else
                doplot(hl(:,ico),pptmp,tvec);
            end;

            drawnow;
        end;
        figure(hf2);
        %        if ~isempty(lastfpos) set(hf2,'position',lastfpos(2,:)); end;

        eucbuft=zeros(size(pp1,1),nkanal);
        for ikanal=1:nkanal
            posdat=pp1(:,1:3,kanallist(ikanal));
            euctmp=eucdistn(posdat(1:end-1,:),posdat(2:end,:))*sf;
            eucbuft(:,ikanal)=[euctmp;euctmp(end)];  %make same length as other time functions
        end;

        if ilist==1
            spi=1;
            hax2(spi)=subplot(sprow,spcol,spi);
            hltang=plot(tvec,eucbuft);
            title('Tangential velocity');
            xlabel('Time (s)');
            ylabel([unit(1,:) '/s']);
        else
            doplot(hltang,eucbuft,tvec);
        end;

        drawnow;

        if sum(~isnan(eucbuft(:,1)))>1
	    tangstat(ilist,:)=[nanmean(eucbuft(:,1)) nanstd(eucbuft(:,1)) max(eucbuft(:,1)) min(eucbuft(:,1)) prctile(eucbuft(:,1),myprctile)];
        end;


        rmsname=descriptor(rmsp,:);
        rmsbuf=squeeze(pp1(:,rmsp,kanallist));       %rms
        if ilist==1
            spi=2;
            hax2(spi)=subplot(sprow,spcol,spi);
            hlrms=plot(tvec,rmsbuf);
            title(rmsname);
            xlabel('Time (s)');
            ylabel(unit(rmsp,:));
        else
            doplot(hlrms,rmsbuf,tvec);
        end;

        if sum(~isnan(rmsbuf(:,1)))>1
            %keyboard;
            rmsstat(ilist,:)=[nanmean(rmsbuf(:,1)) nanstd(rmsbuf(:,1)) max(rmsbuf(:,1)) min(rmsbuf(:,1)) prctile(rmsbuf(:,1),myprctile)];
        end;

        trialn(ilist,:)=[size(rmsbuf,1) sum(~isnan(rmsbuf(:,1)))];
        drawnow;


        dtbuf=squeeze(pp1(:,extrap,kanallist));
        if ilist==1
            spi=3;
            hax2(spi)=subplot(sprow,spcol,spi);
            hldt=plot(tvec,dtbuf);
            title(descriptor(extrap,:));
            xlabel('Time (s)');
            ylabel(unit(extrap,:));
        else
            doplot(hldt,dtbuf,tvec);
        end;

        if sum(~isnan(dtbuf(:,1)))>1
            dtstat(ilist,:)=[nanmean(dtbuf(:,1)) nanstd(dtbuf(:,1)) max(dtbuf(:,1)) min(dtbuf(:,1)) prctile(dtbuf(:,1),myprctile)];
        end;

        drawnow;


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
                hleuc=plot(tvec,eucbuf);
                hlegeuc=legend(hleuc,pairleg);

                title('Euclidean distance');
                xlabel('Time (s)');
                ylabel(unit(1,:));
            else
                doplot(hleuc,eucbuf,tvec);
            end;

            drawnow;

            if sum(~isnan(eucbuf(:,1)))>1
                eucstat(ilist,:)=[nanmean(eucbuf(:,1)) nanstd(eucbuf(:,1)) max(eucbuf(:,1)) min(eucbuf(:,1)) prctile(eucbuf(:,1),myprctile)];
            end;


        end;

        pos1=get(hf1,'position');
        pos1(1)=10;
        pos2=get(hf2,'position');
        pos2(1)=10+pos1(3)+10;
        set(hf1,'position',pos1);
        set(hf2,'position',pos2);

        set([hf1 hf2],'name',['Trial ' int2str(mytrial)]);
        drawnow;

        if ~autoflag keyboard; end;
        %        lastfpos=[get(hf1,'position');get(hf2,'position')];
        %        delete([hf1 hf2]);
    end;        %pbig1 not empty
end;                %trial list
function doplot(hl,pptmp,tvec);
nl=length(hl);

for ii=1:nl set(hl(ii),'xdata',tvec,'ydata',pptmp(:,ii));end;

