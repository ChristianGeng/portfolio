function wav2mt(matname,quickcomment);
% WAV2MT convert all WAV files in directory to MT style recording
% function wav2mt(matname,quickcomment);
% WAV2MT: Version 23.10.2000

functionname=['<Start of Comment: WAV2MT>' crlf];

namestr=[functionname datestr(now) crlf];
if nargin>1 namestr=[namestr quickcomment crlf];end;
d=dir('*.wav');

nfile=length(d);

cutdata=zeros(nfile,4);
cutlabel=cell(nfile,1);

nn=d(1).name;
[data,samplerate1,nbits]=wavread(nn);


nchan=size(data,2);

descriptor=rpts([nchan 1],'AUDIO');
unit=rpts([nchan 1],'normalized');

if nchan>1
   descriptor=[descriptor rpts([nchan 1],'_CH') int2str((1:nchan)')];
end;

nchan1=nchan;

ndig=length(int2str(nfile));

idone=0;
for ii=1:nfile
   
   nn=d(ii).name;
   disp([int2str(ii) ' ' nn]);
   
   
[data,samplerate,nbits,opt]=wavread(nn);

dataok=1;
if samplerate~=samplerate1
   disp('Samplerates do not match');
   dataok=0;
   keyboard;
end;

nchan=size(data,2);
if nchan~=nchan1
   disp('No. of channels does not match');
   dataok=0;
   keyboard;
end;

if dataok
   idone=idone+1;
nn=strrep(nn,'.wav','');
item_id=nn;

cutlabel{idone}=nn;

cutdata(idone,4)=ii;
cutdata(idone,2)=size(data,1)/samplerate;

%keyboard;

disp(opt);

comment=namestr;
save([matname '_' int2str0(ii,ndig)],'data','samplerate','descriptor','unit','item_id','comment');

end;	%data ok
end;



[descriptor,unit,cut_type_value,cut_type_label]=cutstruc;

data=cutdata(1:idone,:);
label=char(cutlabel{1:idone});

trial_number_value=data(:,4);
trial_number_label=label;
comment=namestr;

save([matname '_cut'],'data','label','descriptor','unit','cut_type_value','cut_type_label','trial_number_value','trial_number_label','comment');


