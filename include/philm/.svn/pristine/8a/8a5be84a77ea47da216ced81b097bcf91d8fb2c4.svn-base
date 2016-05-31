function gogoall;
%mtnew (cutfile,recpath,reftrial,signallist,cmdfile,mysession)

myname='tmj_bp1';
mysuff='_head_0';       %audio only 3 digits in trial name

cutfile=[myname '_cut'];
recpath=['mat\' myname];
reftrial='001';




audioname='_audio_.AUDIO';

dd=mymatin([recpath mysuff reftrial],'descriptor');
dimdim=mymatin([recpath mysuff reftrial],'dimension');
dd=flatdescriptor(dd,dimdim)
%external and internal dimension names
%should be correct for datamode ref or head; 

%dimtran{1,1}='_px'; dimtran{1,2}='_lat';
%dimtran{2,1}='_py'; dimtran{2,2}='_a_p';
%dimtran{3,1}='_pz'; dimtran{3,2}='_lon';

dimtran{1,1}='_posx'; dimtran{1,2}='_lat';
dimtran{2,1}='_posy'; dimtran{2,2}='_a_p';
dimtran{3,1}='_posz'; dimtran{3,2}='_lon';

dimtran{4,1}='_orix'; dimtran{4,2}='_ox';
dimtran{5,1}='_oriy'; dimtran{5,2}='_oy';
dimtran{6,1}='_oriz'; dimtran{6,2}='_oz';

dimtran{7,1}='_rms'; dimtran{7,2}='_rms';
%dimtran{8,1}='_ndiverge'; dimtran{8,2}='_ndi';
%dimtran{9,1}='_residue'; dimtran{9,2}='_res';

%keyboard

%hl=makesiglist(dd,mysuff,'head_l','hl',dimtran);
%hr=makesiglist(dd,mysuff,'head_lateral_r','hr',dimtran);
ref=makesiglist(dd,mysuff,'ref','ref',dimtran);
nose=makesiglist(dd,mysuff,'nose','nas',dimtran);

tip=makesiglist(dd,mysuff,'t_tip','tt',dimtran);
mid=makesiglist(dd,mysuff,'t_mid','tm',dimtran);
back=makesiglist(dd,mysuff,'t_back','tb',dimtran);
jaw=makesiglist(dd,mysuff,'jaw','jaw',dimtran);
ul=makesiglist(dd,mysuff,'upper_lip','ul',dimtran);
ll=makesiglist(dd,mysuff,'lower_lip','ll',dimtran);

%mouthcorner_left omitted

keyboard
siglist=str2mat(audioname,tip,mid,back,ul,ll,jaw);
comfile='mycmdsall.m';
mysession=1;

mtnew(cutfile,recpath,reftrial,siglist,comfile,mysession)

