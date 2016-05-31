%revised 23.1.06. Different filter for tongue tip
% also same filters for downsample and normal

dodown=1;
mysuff='';
idownfac=1;
usercomment='Filter complete data for input to amp adjustment';

if dodown
mysuff='ds';
idownfac=8;
usercomment='Filter and downsample data';
end;



mypart='cv1\';
%mypart='lab1\';
%mypart='r1\';
inpath=[mypart 'amps\'];
outpath=[mypart 'ampsfilt' mysuff '\amps\'];
usersensornames=str2mat('t_back','t_mid','t_tip','ref','jaw','nose','head_left','head_right','upper_lip','lower_lip','<unused1>','<unused2>');
filterspecs=cell(3,2);
filterspecs{1,1}='fir_60_70';
filterspecs{1,2}=[3];
filterspecs{2,1}='fir_20_30';
filterspecs{2,2}=[1 2 5 9 10];
filterspecs{3,1}='fir_05_15';
filterspecs{3,2}=[4 6 7 8];

triallist=1:252;    %cv1
%triallist=1:121;    %lab1
%triallist=1:93;    %r1

filteramps(inpath,outpath,triallist,filterspecs,idownfac,usersensornames,usercomment)
