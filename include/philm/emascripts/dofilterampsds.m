mypart='cv1\';
inpath=[mypart 'amps\'];
outpath=[mypart 'ampsfiltds\amps\'];
idownfac=8;
usercomment='Downsampled version for analyzing amps vs posamps';
usersensornames=str2mat('t_back','t_mid','t_tip','ref','jaw','nose','head_left','head_right','upper_lip','lower_lip','<unused1>','<unused2>');
filterspecs=cell(1,2);
filterspecs{1,1}='fir_05_15';
filterspecs{1,2}=1:12;

triallist=1:252;    %cv1

filteramps(inpath,outpath,triallist,filterspecs,idownfac,usersensornames,usercomment)
