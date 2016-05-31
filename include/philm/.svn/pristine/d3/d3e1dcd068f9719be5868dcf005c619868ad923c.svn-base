%do_mergebymeansqu

%path(path,'d:\phil\matlab\tapadm');
%usersensornames=str2mat('t_back','t_mid','t_tip','jaw','ref','nose','head_left','head_right','lower_lip','upper_lip','mouthcorner_left','mouthcorner_right');

basepath='S:\2005\paris0905\bk1\';
inpath1=[basepath 'ampsadj\forward\rawpos'];
inpath2=[basepath 'ampsadj\reverse\rawpos'];
amppath=[basepath 'ampsadj\amps'];
outpath=[basepath 'ampsadj\merge\rawpos'];

chanlist=1:12;

%filter specs should be same as for filteramps

filterspecs=cell(2,2);
filterspecs{1,1}='fir_20_30';
filterspecs{1,2}=[1:4 9:12];
filterspecs{2,1}='fir_05_15';
filterspecs{2,2}=[5 6 7 8];

triallist=1:328;    %bk corpus, speaker am



mergebymeansqu(inpath1,inpath2,amppath,outpath,triallist,chanlist,filterspecs);
