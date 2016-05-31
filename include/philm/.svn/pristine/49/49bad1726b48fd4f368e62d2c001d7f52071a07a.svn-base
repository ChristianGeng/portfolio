function c_pc(seglist,segtime,ibeat,ishift)
% C_PC Signals for P-centers?
% function c_pc(seglist,seglength,ibeat,ishift)

nrep=5;

dd=mt_gcufd;
s1=dd(seglist(1),:);
s2=dd(seglist(2),:);

mt_next(seglist(1));

d1=mt_gdata('AUDIO',s1(1:2));

mt_next(seglist(2));

d2=mt_gdata('AUDIO',s2(1:2));



isibase=60/ibeat;


sf=mt_gsigv('AUDIO','samplerate');
segsamp=round(segtime*sf);

d1=d1(1:segsamp);
d2=d2(1:segsamp);


isi1=isibase-segtime-ishift;
isi2=isibase-segtime+ishift;

if (isi1<0) | (isi2<0) 
   
   disp('shift too large'); 
   disp(['maximum possible shift is ' num2str(isibase-segtime)]);
   return;
   
end;




dd=[];

isi1=round(isi1*sf);
isi2=round(isi2*sf);

isi1=zeros(isi1,1);
isi2=zeros(isi2,1);




%keyboard;

for ii=1:10
   dd=[dd;d1;isi1;d2;isi2];
end;

soundsc(dd,sf);

