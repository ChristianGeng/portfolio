function do_comppos_a

%('t_back','t_mid','t_tip','ref','jaw','nose','upper_lip','lower_lip','head_left','head_right','occ1','occ2');

%commonpath='S:\2006\mca3\mca3_cz_normal\';
commonpath='';
%basepath=[commonpath 'ampsfiltds\beststartl\rawpos\'];
%basepath=[commonpath 'ampsfiltdsadja\beststartl\rawpos\'];
%basepath=[commonpath 'ampsfiltadja\recursevelpredl\rawpos\'];
basepath=[commonpath 'ampsfiltadja3\velrep\rawpos\'];

altpath='';
%altpath=[commonpath 'ampsfiltdsadja\beststartl\rawpos\'];
%altpath=[commonpath 'ampsfiltadja\velpred\'];
%altpath=[commonpath 'ampsfiltadja\recursevelpredl\rawpos\'];
%altpath=[commonpath 'ampsfiltadja2\recursevelpredl\rawpos\'];
%altpath=[commonpath 'ampsfiltadja3\velrep\rawpos\'];

dodiary=0;
statpic=[1 5 6];        %mean, 2.5 and 97.5%ile
if dodiary
diary comppos_stats_adja3velrep2nose.txt
diary off
end;



hfstats=figure;
keyboard;
statspos=get(hfstats,'position');
%triallist=([2:61])';        %skip rest position      
triallist=([1:10])';        %skip rest position      
autoflag=0;
%colist=[1 2 3];
colist=[1 2 3 6];
colist2=[7 8];
compsensor=6;       %nose
%compsensor=[];
for kanallistb=[1:10]
%for kanallistb=[2 9 10]

%    [rmsstat,tangstat,eucstat,dtstat,trialn,posstat,oristat]=comppos_f(basepath,altpath,triallist,kanallistb,autoflag,colist);
%with comparison
[rmsstat,tangstat,eucstat,dtstat,trialn,costat]=comppos_fm(basepath,altpath,triallist,[kanallistb compsensor],autoflag,colist,colist2);


%pause;
close all
if length(triallist)>1
if dodiary diary on; end;
disp('=========');
disp(['Sensor ' int2str(kanallistb)])
disp('=========');
disp(['n_data max/min/mean ' int2str([max(trialn) min(trialn)]) ' ' num2str(mean(trialn))]);
%plot(trialn);

%pause
hfstats=figure('position',statspos);
showstat(rmsstat,statpic,'rms',1);
%pause
showstat(tangstat,statpic,'tangential velocity',2);
%pause
showstat(eucstat,statpic,'euclidean distance',3);
showstat(dtstat,statpic,'parameter 7',4);
keyboard;
%pause
%close all
if dodiary diary off; end;
end;
end;

function showstat(x,statpic,mytitle,isubp);
sdfac=2;
%myprctile=[2.5 97.5];
myprctile=[5 95];
%prctile(eucbuf(:,1),myprctile)

disp(mytitle);
xx=x(:,statpic);
%figure;
subplot(2,2,isubp)
plot(xx);
title(mytitle);
xq=nanmean(xx);
%sd=nanstd(xx)*sdfac;
%lolim=xq-sd;
%hilim=xq+sd;
xprct=prctile(xx,myprctile);
lolim=xprct(1,:);
hilim=xprct(2,:);
disp(['lolim mean hilim (columns) of stats ' int2str(statpic) ' (rows)']);
allvals=([lolim;xq;hilim])';
disp(allvals);
disp(['Suggested range : ' num2str([min(allvals(:,1)) max(allvals(:,3))])]);
%keyboard;
xsd=nanmean(x(:,2));
sdprct=prctile(x(:,2),myprctile);
disp('lolim mean hilim of trial sds');
disp([sdprct(1) xsd sdprct(2)]);
