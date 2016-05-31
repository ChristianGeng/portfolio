function mergestudy(cutfile1,cutfile2,recname1,recname2)
% MERGESTUDY Add trials from study 2 to study1
% function mergestudy(cutfile1,cutfile2,recname1,recname2)
% MERGESTUDY: Version 10.10.2002

functionname='MERGESTUDY: Version 10.10.2002';

cutdata1=mymatin(cutfile1,'data');
cutlabel1=mymatin(cutfile1,'label');
cutcomment1=mymatin(cutfile1,'comment');

cutdata2=mymatin(cutfile2,'data');
cutlabel2=mymatin(cutfile2,'label');

addlist=unique(cutdata2(:,4));
n_new=length(addlist);

newbase=max(cutdata1(:,4));		%last trial in study 1

%number of digits in trial number; may not work correctly for all cases
%may need to adjust with zeros in recname1 or recname2 in unusual cases

ndigin=length(int2str(max(addlist)));
ndigout=length(int2str(newbase+n_new));

for ii=1:n_new
   innum=addlist(ii);
   inname=[recname2 int2str0(innum,ndigin)];
   newnum=newbase+ii;		%note, new trials numbered sequentially, even if addlist has gaps
   disp([innum newnum]);
   outname=[recname1 int2str0(newnum,ndigout)];
   [status,msg]=copyfile([inname '.mat'],[outname '.mat']);
   if ~status
      disp('Error copying file');
      disp(msg);
      return
   end;
   comment=mymatin(inname,'comment');
   comment=['Original name : ' inname crlf comment];
   comment=framecomment(comment,functionname);
   save(outname,'comment','-append');
   
   %copy the cuts for this trial
   
   vv=find(cutdata2(:,4)==innum);
   tmp=cutdata2(vv,:);
   tmp(:,4)=newnum;
   
   cutdata1=[cutdata1;tmp];
   cutlabel1=str2mat(cutlabel1,cutlabel2(vv,:));
end;

cutcomment1=['Trial numbers starting at ' int2str(newbase+1) ' have been added from ' cutfile2 crlf cutcomment1];
cutcomment1=framecomment(cutcomment1,functionname);

data=cutdata1;
label=cutlabel1;
comment=cutcomment1;

save(cutfile1,'data','label','comment','-append');
