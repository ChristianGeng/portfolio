clear variables
myinfix='ds';
%myinfix='';

adjnum=1;


sensorlist=[1:6 8:12];

ntran=6;

if adjnum==1
inpath=['ampsfilt' myinfix '\amps'];
outpath=['ampsfilt' myinfix 'adja\amps'];
coffile='ampvsposampstats_adjapc_dsbeststartl_';
%trialbuf{1}=[1:538];

%sufbuf=str2mat('all');
trialbuf{1}=[1:217];
trialbuf{2}=[218:538];

sufbuf=str2mat('1','2');

end;


mkdir(outpath);
 

npass=length(trialbuf);


for ipass=1:npass

disp(ipass);
mysuff=deblank(sufbuf(ipass,:));
coffuse=[coffile mysuff];

triallist=trialbuf{ipass};


adjampsapc(inpath,outpath,triallist,sensorlist,coffuse)


end;
