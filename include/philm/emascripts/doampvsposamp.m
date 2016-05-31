%do ampvsposamp

nsensor=12;

basepath='S:\2005\mca2\cv1\ampsfiltds\';
outfile='ampvsposampstats_thr_cv1_rep_';

sensorsused=1:10;

trialbuf=[3 124;127 252];
sufbuf=str2mat('1','2');

rmsthreshb=[20 15 30 20 15 5 10 15 25 10];
velthreshb=[200 200 250 50 100 50 50 50 75 200];  %in mm/s

compsens=ones(nsensor,1)*NaN;
compthresh=ones(nsensor,2)*NaN;


compsens([1:3 5:10])=4;       %ref

eucthresh(1,:)=[50 75];
eucthresh(2,:)=[25 55];
eucthresh(3,:)=[10 40];

eucthresh(5,:)=[15 32];

eucthresh(6,:)=[77 80];
eucthresh(7,:)=[142 145];
eucthresh(8,:)=[150 155.5];
eucthresh(9,:)=[8 17];
eucthresh(10,:)=[15 40];



ampvsposamp(basepath,outfile,trialbuf,sufbuf,sensorsused,rmsthreshb,velthreshb,compsens,eucthresh)
