%do ampvsposamp

clear variables
nsensor=12;
commonpath='';

adjnum=1;
pcorder=3;

if adjnum==1
amppath=[commonpath 'ampsfiltds\amps\'];
pospath=[commonpath 'ampsfiltds\beststartl\rawpos\'];
outfile='ampvsposampstats_adjapc_dsbeststartl_';
end;

%triallist=[3:538];       %skipping rest/head at beginning
%restlist=[110 218 325 431];

%divide into 2 chunks. Only because tongue tip seemed more stable after
%break

trialbuf{1}=setxor([3:217],[110]);
trialbuf{2}=setxor([219:538],[325 431]);
sufbuf=str2mat('1','2');


trimsamp=[6 6];     %skip about 250 ms at start and end of each trial (!!assumes downsampled to 25Hz)



%usersensornames=str2mat('t_tip','ref','t_back','t_mid','jaw','nose','velumplastic','head_left','head_right','upper_lip','lower_lip','velumdirect');

sensorsused=[1:6 8:12];




compsens=ones(nsensor,1)*NaN;
eucthresh=ones(nsensor,2)*NaN;

compsens(sensorsused)=6;       %nose
compsens([6])=NaN;

if adjnum==1;
%lg1    
%               1     2     3     4     5     6     7     8     9    10 
rmsthreshb=[   24    10    16    16    4     5    NaN    4     4    4    6   12];
velthreshb=[  250    25   200   200   80    25    NaN    18   18   95   155   100];  %in mm/s
parameter7b=[ NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN];  %units?????

lolimb=    [   93    85    110   85    108   NaN   NaN    170     175   81    104   103];
hilimb=    [   110   89    125   107   119   NaN   NaN    173     177    91    119   109];
end;



eucthresh=[lolimb' hilimb'];




ampvsposampa7pc(amppath,pospath,outfile,trialbuf,sufbuf,sensorsused,rmsthreshb,velthreshb,compsens,eucthresh,parameter7b,pcorder,trimsamp)
