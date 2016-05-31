function [data,descriptor]=parsepraat(praattxtfile)
% PARSEPRAAT Read praat text file of table of real
% function [data,descriptor]=parsepraat(praattxtfile)

ss=file2str(praattxtfile);

vv=strmatch('numberOfColumns',ss);
tmps=ss(vv,:);
[dodo,tmps]=strtok(tmps,'=');
[tmps,dodo]=strtok(tmps,'=');
ncol=str2num(tmps);
vv=strmatch('numberOfRows',ss);
tmps=ss(vv,:);
[dodo,tmps]=strtok(tmps,'=');
[tmps,dodo]=strtok(tmps,'=');
nrow=str2num(tmps);

data=zeros(nrow,ncol);
vv=strmatch('columnLabels',ss);
tmps=deblank(ss(vv+1,:));

tmps=strrep(tmps,'"','');
mydelim=char(9);
descriptor=rv2strm(tmps,mydelim);


vv=strmatch('row [1]',ss);


%keyboard;

for irow=1:nrow
   iline=vv+irow-1;
   tmps=ss(iline,:);
   tmps=strrep(tmps,'"','');
   ipi=findstr(':',tmps);
   tmps=tmps((ipi+1):end);
   myvec=str2num(tmps);
   data(irow,:)=myvec;
end;
