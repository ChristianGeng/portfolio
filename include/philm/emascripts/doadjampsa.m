% do_tapad_ds.m MATLAB-Script to perform position calculation.
%
%           see  tapad_ph_rs

warning('off','MATLAB:dispatcher:InexactMatch'); % switch off warnigs concerning case-sensitive OS  
clear variables; myinfix='';

%--------------------------------------------------------------------
%myinfix='ds';		% uncoment if processing downsampled data


adjnum=1;



sensorlist=[1:10];


triallist=[1:229];




ntran=6;

if adjnum==1
inpath=['ampsfilt' myinfix '/amps'];
outpath=['ampsfilt' myinfix 'adja/amps'];
coffile='ampvsposampstats_adja_dsbeststartl_';
trialbuf{1}=triallist;

sufbuf=str2mat('all');

end;





mkdir(outpath);
 

npass=length(trialbuf);

ampfac=2500;        %scaling of constant term

for ipass=1:npass
disp(ipass);
mysuff=deblank(sufbuf(ipass,:));
    bc=mymatin([coffile mysuff],'bc');

%disp(b1);
%disp(b2);
for isensor=sensorlist
    for itrans=1:ntran
        bb=bc{isensor,itrans};
        bb(1)=bb(1)/ampfac;
        bc{isensor,itrans}=bb;
    end;
end;



triallist=trialbuf{ipass};


adjampsa(inpath,outpath,triallist,sensorlist,bc)
end;
