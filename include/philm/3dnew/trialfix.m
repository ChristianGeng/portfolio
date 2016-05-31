function trialfix(inpath,trialnum,timspec,mysensor,workpath,compsensor)
% TRIALFIX  Try and fix dodgy data
% function trialfix(inpath,trialnum,timspec,mysensor,workpath,compsensor)
% trialfix: Version 16.5.05

philcom(0)
[abint,abnoint,abscalar,abnoscalar]=abartdef;

sf=200; %variable??
rmsfac=2500;        %for amposampdt calculations
nsensor=12;
ntrans=6;
ndig=4;
ts=int2str0(trialnum,ndig);
mysamp=round(timspec*sf);
mysamp(1)=mysamp(1)+1;

%preset for bad data detection

rmsthr=10;
dtthr=1;
eucthrlo=0;
eucthrhi=100;




%copy selected portion of trial to temporary subdirectories

atmp=loadamp([inpath '\amps\' ts '.amp']);

maxsamp=size(atmp,1);
if mysamp(2)>maxsamp
    mysamp(2)=maxsamp;
    timspec(2)=mysamp(2)/sf;
    disp(['Clipping end to ' num2str(timspec(2)) ' s.'])
end;

amporgt=atmp;       %retain complete trial data

atmp=atmp(mysamp(1):mysamp(2),:,:);
amporg=zeros(size(atmp));
amporg(:,:,mysensor)=atmp(:,:,mysensor);    %makes sure calcpos only processes the chosen sensor
saveamp([workpath '\amps\' ts '.amp'],amporg);
saveamp([workpath '\ampsorg\' ts '.amp'],amporg);

posorg=loadpos([inpath '\rawpos\' ts '.pos']);
posorgt=posorg;
posorg=posorg(mysamp(1):mysamp(2),:,:);
savepos([workpath '\rawpos\' ts '.pos'],posorg);
savepos([workpath '\rawposorg\' ts '.pos'],posorg);

posamporg=loadamp([inpath '\rawpos\posamps\' ts '.amp']);
posamporgt=posamporg;
posamporg=posamporg(mysamp(1):mysamp(2),:,:);
saveamp([workpath '\rawposorg\posamps\' ts '.amp'],posamporg);
saveamp([workpath '\rawpos\posamps\' ts '.amp'],posamporg);


%variables containing target sensor only
posorgx=posorg(:,:,mysensor);
amporgx=amporg(:,:,mysensor);
posamporgx=posamporg(:,:,mysensor);

%subdivisions of pos data
carorgx=posorgx(:,1:3);     %cartesian data
oriorgx=posorgx(:,4:5);        %orientation data
rmsorgx=posorgx(:,6);
dtorgx=posorgx(:,7);

badvec=logical(zeros(length(rmsorgx),1));

dimlistcar='xyz';

%plot cartesian data
hfp=figure;
for ii=1:3
    haxp(ii)=subplot(3,1,ii);
    hlpo(ii)=plot(carorgx(:,ii),'g');
    hold on
    hlpn(ii)=plot(carorgx(:,ii),'m');
    title(['Pos ' dimlistcar(ii)]);
    if ii==1
        hlegp=legend([hlpo(ii) hlpn(ii)],str2mat('org','new'));
    end;
end;

%plot amplitude and posamp data
hfa=figure;
for ii=1:6
    haxa(ii)=subplot(6,1,ii);
    hlao(ii)=plot(amporgx(:,ii),'r');
    hold on
    hlan(ii)=plot(amporgx(:,ii),'c');
    hlpao(ii)=plot(posamporgx(:,ii),'g');
    hlpan(ii)=plot(posamporgx(:,ii),'m');
    title(['Amp ' int2str(ii)]);
    if ii==1
        hlega=legend([hlao(ii) hlan(ii) hlpao(ii) hlpan(ii)],str2mat('amporg','ampnew','posamporg','posampnew'));
    end;

end;

%figure for rms, dt, eucdistance

eucdistorgx=eucdistn(carorgx,posorg(:,1:3,compsensor));

hfc=figure;
ii=1;
haxc(ii)=subplot(3,1,ii);
hlrmso=plot(rmsorgx,'g');
hold on;
hlrmsn=plot(rmsorgx,'m');

title('RMS');

hlegrms=legend([hlrmso hlrmsn],str2mat('org','new'));

ii=2;
haxc(ii)=subplot(3,1,ii);
hldto=plot(dtorgx,'g');
hold on
hldtn=plot(dtorgx,'m');
title('DT');

ii=3;
haxc(ii)=subplot(3,1,ii);
hleuco=plot(eucdistorgx,'g');
hold on
hleucn=plot(eucdistorgx,'m');
title(['Euclidean Distance from sensor  ' int2str(compsensor)]);



mycmd=char(0);

ampnew=amporg;
ampnewx=ampnew(:,:,mysensor);
posnew=posorg;
posampnew=posamporg;


[posnewx,posampnewx,carnewx,orinewx,rmsnewx,dtnewx,eucdistnewx]=splitandshow(posnew,posampnew,mysensor,hlpn,hlpan,hlrmsn,hldtn,hleucn,compsensor);



while mycmd~='q'

    mycmd=abartstr('Command','h');
    if mycmd=='h'
        disp(['h=help' crlf 'q=quit' crlf 'c=Calcpos' crlf 'l=linear prediction' crlf 'b=bad data' crlf 'o=use result as new original' crlf 'p=amp prediction (complete trial)']);
    end;


    %===========================================
    % run calcpos

    if mycmd=='c'

        disp('run calcpos')
        keyboard;
        %run calcpos

        %calculate amposampdt
        [dtx,dtsd,dtmax]=compamposampdt([workpath '\amps'],[workpath '\rawpos'],trialnum,rmsfac);

        posnew=loadpos([workpath '\rawpos\' ts '.pos']);
        posampnew=loadamp([workpath '\rawpos\posamps\' ts '.amp']);

        [posnewx,posampnewx,carnewx,orinewx,rmsnewx,dtnewx,eucdistnewx]=splitandshow(posnew,posampnew,mysensor,hlpn,hlpan,hlrmsn,hldtn,hleucn,compsensor);


        disp('calcpos finished')
        keyboard;

    end;

    if mycmd=='l'

        %should be more input arguments to showlinpredmr
        disp('Make sure linear prediction settings are correct');
        keyboard

        tmp=showlinpredmr(ampnew,posnew);

        %only replace bad data
        posnew(badvec,:,mysensor)=tmp(badvec,:,mysensor);
        badvec(:)=0;            %reset, or recalculate??

        posnewx=posnew(:,:,mysensor);
        posampnewx=calcamps(posnewx(:,1:3),posnewx(:,[4 5]));

        %to test matlab routine is equivalent to calcpos
        %ppp=calcamps(pp(:,1:3,mysensor),pp(:,[4 5],mysensor));

        posampnew(:,:,mysensor)=posampnewx;

        %calculate rms and amposampdt
        [allrms,allposampdt]=posampana(ampnew,posampnew,rmsfac);

        rmsnewx=allrms(:,mysensor);
        dtnewx=allposampdt(:,mysensor);

        posnewx(:,6)=rmsnewx;
        posnewx(:,7)=dtnewx;
        posnew(:,:,mysensor)=posnewx;

        [posnewx,posampnewx,carnewx,orinewx,rmsnewx,dtnewx,eucdistnewx]=splitandshow(posnew,posampnew,mysensor,hlpn,hlpan,hlrmsn,hldtn,hleucn,compsensor);

        %        [posnewx,posampnewx,carnewx,orinewx,rmsnewx,dtnewx]=splitandshow(posnew,posampnew,mysensor,hlpn,hlpan,hlrmsn,hldtn);


        disp('linear prediction finished')
        keyboard;
        %if ok write to pos and posampfile
        %otherwise read current pos and posamp file, and redisplay

        myans=abartstr('Store ? ','n');

        if lower(myans)=='y'
            savepos([workpath '\rawpos\' ts '.pos'],posnew);
            saveamp([workpath '\rawpos\posamps\' ts '.amp'],posampnew);

        else
            posnew=loadpos([workpath '\rawpos\' ts '.pos']);
            posampnew=loadamp([workpath '\rawpos\posamps\' ts '.amp']);

            [posnewx,posampnewx,carnewx,orinewx,rmsnewx,dtnewx,eucdistnewx]=splitandshow(posnew,posampnew,mysensor,hlpn,hlpan,hlrmsn,hldtn,hleucn,compsensor);
            %       [posnewx,posampnewx,carnewx,orinewx,rmsnewx,dtnewx]=splitandshow(posnew,posampnew,mysensor,hlpn,hlpan,hlrmsn,hldtn);
        end;


    end;            %linear prediction

    if mycmd=='o'
        posorg=posnew;
        posamporg=posampnew;
        [posorgx,posamporgx,carorgx,oriorgx,rmsorgx,dtorgx,eucdistorgx]=splitandshow(posorg,posamporg,mysensor,hlpo,hlpao,hlrmso,hldto,hleuco,compsensor);

    end;



    if mycmd=='b'       %mark bad data
        disp('Setting for bad data');
        rmsthr=abart('RMS threshold',rmsthr,0,30000,abnoint,abscalar);
        dtthr=abart('dT threshold',dtthr,0,30000,abnoint,abscalar);
        eucthrlo=abart('Lower Euclidean distance threshold',eucthrlo,0,30000,abnoint,abscalar);
        eucthrhi=abart('Upper Euclidean distance threshold',eucthrhi,0,30000,abnoint,abscalar);

        v1=rmsnewx>rmsthr;
        v2=dtnewx>dtthr;
        v3=eucdistnewx<eucthrlo;
        v4=eucdistnewx>eucthrhi;

        badvec=v1|v2|v3|v4;
        posnew(badvec,1,mysensor)=NaN;

        %how to show location??
    end;

    %amp vs. posamp regression for complete trial
    %uses bad data settings
    if mycmd=='p'

        v1=posorgt(:,6,mysensor)>rmsthr;
        v2=posorgt(:,7,mysensor)>dtthr;

        eucdistt=eucdistn(posorgt(:,1:3,mysensor),posorgt(:,1:3,compsensor));
        v3=eucdistt<eucthrlo;
        v4=eucdistt>eucthrhi;

        badvect=v1|v2|v3|v4;

        atmp=amporgt(~badvect,:,mysensor);
        patmp=posamporgt(~badvect,:,mysensor);
        keyboard;
        ntran=6;
        b1=zeros(1,ntran);
        b2=zeros(1,ntran);
        for ii=1:ntran
            b=robustfit(atmp(:,ii),patmp(:,ii));
            b1(ii)=b(1);
            b2(ii)=b(2);
        end;
        disp(b1);
        disp(b2);
        keyboard;
        myans=abartstr('Compute new amps ? ','n');
        if lower(myans)=='y'
            for ii=1:ntran
                ampnewx(:,ii)=b1(ii)+(b2(ii)*ampnew(:,ii,mysensor));
                set(hlan(ii),'ydata',ampnewx(:,ii));
            end;
            ampnew(:,:,mysensor)=ampnewx;

            saveamp([workpath '\amps\' ts '.amp'],ampnew);
        end;


    end;






%for adjusting amplitudes
% bb=zeros(6,2);
% for kk=1:6 bb(kk,:)=robustfit(aorg(:,kk),paorg(:,kk)); end;



end;        %end of command loop

disp('type return to exit');
keyboard;
delete([hfa hfp hfc]);



function [posnewx,posampnewx,carnewx,orinewx,rmsnewx,dtnewx,eucdistnewx]=splitandshow(posnew,posampnew,mysensor,hlpn,hlpan,hlrmsn,hldtn,hleucn,compsensor);
posnewx=posnew(:,:,mysensor);
posampnewx=posampnew(:,:,mysensor);




%subdivisions of pos data
carnewx=posnewx(:,1:3);     %cartesian data
orinewx=posnewx(:,4:5);        %orientation data
rmsnewx=posnewx(:,6);
dtnewx=posnewx(:,7);
eucdistnewx=eucdistn(carnewx,posnew(:,1:3,compsensor));

%plot new data
for ii=1:3 set(hlpn(ii),'ydata',carnewx(:,ii)); end;
for ii=1:6 set(hlpan(ii),'ydata',posampnewx(:,ii)); end;
set(hlrmsn,'ydata',rmsnewx);
set(hldtn,'ydata',dtnewx);
set(hleucn,'ydata',eucdistnewx);
