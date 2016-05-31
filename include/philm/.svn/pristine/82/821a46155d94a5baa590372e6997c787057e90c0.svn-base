%do_filtersensorinplace
%uses changematvar to adjust filtering of individual sensors
%Note: only intended to be used after data has been processed by
%rigidbody_ana: Assumes orientations stored as orix, oriy, oriz

clear variables

disp('Filters sensors in place');
disp('Make a copy of existing data first if you want to be safe!');
disp('Test first with fixflag=0');
disp('Abort with ctrl C if unsure');
disp('Otherwise type return to continue');


fixflag=1;

%triallist=1:244;
triallist=7:244;
%matfile='mat\German_S3_ema_head_0';
matfile='mat\German_S3_ema_head_0';


%insert comment from filter file here
briefcomment='Additional smoothing of tongue-tip: kaiserd(20,30,60,200); filter for articulators';
variablesout={'data'};

%Sensor 9 is tongue tip
%would be better to extract this from the dimension specification, and
%insert in calcpec as an evaluated variable

calcspec='mycoffs=mymatin(''fir_20_30'',''data'');for ii=1:6 data(:,ii,9)=decifir(mycoffs,data(:,ii,9)); end;';

keyboard;

changematvar(matfile,calcspec,variablesout,briefcomment,fixflag,triallist);
