
coffile='ampvsposampstats_thr_cv1_rep_';

sensorlist=1:10;   %11/12 not used
ntran=6;

inpath='ampsfilt\amps';
outpath='ampsadj\amps';

 
trialbuf=[1 124;125 252];
sufbuf=str2mat('1','2');


npass=size(trialbuf,1);
ampfac=2500;        %scaling of constant term

for ipass=1:npass
disp(ipass);
mysuff=deblank(sufbuf(ipass,:));
    b1=mymatin([coffile mysuff],'b1');
    b2=mymatin([coffile mysuff],'b2');

disp(b1);
disp(b2);

b1=b1/ampfac;

triallist=trialbuf(ipass,1):trialbuf(ipass,2);


adjamps(inpath,outpath,triallist,sensorlist,b1,b2)
end;
