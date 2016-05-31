%triallist=3:90;
%triallist=1:252;     %mca2 cv1
triallist=3:29;     %ed1nick2
%triallist=44;
%basepath='g:\ag500data\ed1nick1\';
%basepath='ampsadj';
basepath='ampsnoadj';
altpath='azpos';
%altpath='';

autoflag=0;

maxtrial=max(triallist);

%stats for first channel in list
rmsstat=ones(maxtrial,4)*NaN;
tangstat=ones(maxtrial,4)*NaN;
eucstat=ones(maxtrial,4)*NaN;

sf=200;
colist=[1 2 3];       %not more than 3
nco=length(colist);
maxkanal=12;        %assume fixed
kanallistb=[8];
lastfpos=[];
for mytrial=triallist
    disp(['Trial ' int2str(mytrial)]);
    
    pp1=loadpos([basepath '\rawpos\' int2str0(mytrial,4) '.pos']);
    if ~isempty(pp1)
        %pp2=loadpos(['rawposadj\' int2str0(mytrial,4) '.pos']);
        %dt1=mymatin(['rawposorg\posampdt\posampdt_' int2str0(mytrial,4)],'data');
        %dt2=mymatin(['rawposadj\posampdt\posampdt_' int2str0(mytrial,4)],'data');

        kanallist=kanallistb;
        pp2=[];
        if ~isempty(altpath)
            pp2=loadpos([altpath '\rawpos\' int2str0(mytrial,4) '.pos']);
            pp1=cat(3,pp1,pp2);
            kanallist=[kanallist kanallistb+maxkanal];
        end;
        nkanal=length(kanallist);

        figure
        if ~isempty(lastfpos) set(gcf,'position',lastfpos); end;
        disp(mytrial);
        for ico=1:nco
            hax(ico)=subplot(2,3,ico);
            hl=plot(squeeze(pp1(:,colist(ico),kanallist)));
            if ico==1
                legend(hl,int2str(kanallist'));
            end;
            title(int2str(colist(ico)));
drawnow;
            %if ~isempty(pp2)
            %    hold on
            %hl2=plot(squeeze(pp2(:,colist(ico),kanallist)));
            %end;
        end;
        hax(4)=subplot(2,3,4);
        eucbuf=zeros(size(pp1,1)-1,nkanal);
        for ikanal=1:nkanal
            posdat=pp1(:,1:3,kanallist(ikanal));
            euctmp=eucdistn(posdat(1:end-1,:),posdat(2:end,:))*sf;
            eucbuf(:,ikanal)=euctmp;
        end;

        plot(eucbuf);
        title('Tangential velocity');
drawnow;

        tangstat(mytrial,:)=[mean(eucbuf(:,1)) std(eucbuf(:,1)) max(eucbuf(:,1)) min(eucbuf(:,1))];

        %if ~isempty(pp2)
        %eucbuf2=zeros(size(pp2,1)-1,nkanal);
        %for ikanal=1:nkanal
        %    posdat=pp2(:,1:3,kanallist(ikanal));
        %    euctmp=eucdistn(posdat(1:end-1,:),posdat(2:end,:))*sf;
        %    eucbuf2(:,ikanal)=euctmp;
        %end;

        %hold on
        %plot(eucbuf2);
        %end;

        hax(5)=subplot(2,3,5);
        rmsbuf=squeeze(pp1(:,6,kanallist));       %rms
        plot(rmsbuf);
        title('rms');
        rmsstat(mytrial,:)=[mean(rmsbuf(:,1)) std(rmsbuf(:,1)) max(rmsbuf(:,1)) min(rmsbuf(:,1))];
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
            hax(6)=subplot(2,3,6);
            for ipair=1:npair
                ch1=kanallist(ipair);
                ch2=kanallist(ipair+1);
                euctmp=eucdistn(pp1(:,1:3,ch1),pp1(:,1:3,ch2));
                eucbuf=[eucbuf euctmp];     %not very efficient
                pairleg{ipair}=[int2str(ch1) '-' int2str(ch2)];
            end;
            hleuc=plot(eucbuf);
            hlegeuc=legend(hleuc,pairleg);

            title('Euclidean distance');
drawnow;

            eucstat(mytrial,:)=[mean(eucbuf(:,1)) std(eucbuf(:,1)) max(eucbuf(:,1)) min(eucbuf(:,1))];


        end;

        %if ~isempty(pp2)
        %hold on
        %euctmp=eucdistn(pp2(:,1:3,kanallist(1)),pp2(:,1:3,kanallist(2)));

        %plot(euctmp);
        %end;
if mytrial==triallist(1)
    disp('adjust window position if desired');
    keyboard;
end;

        if ~autoflag pause; end;
        lastfpos=get(gcf,'position');
        delete(gcf);
    end;
end;
