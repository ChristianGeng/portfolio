logfile='xuexp\xu97exp_stimlist_ran_log_s2_adj';

[cutdata,cutlabel,agtrialnum,mttrialnum,trialnumS]=parselogfile(logfile);

cmtfile=['xu97exp_1_comment.txt'];
tmpcmt=readtxtf(cmtfile);

synchfile='rawaudio\tonesose07_xuexp_1_sync';

comment=mymatin(synchfile,'comment');
data=mymatin(synchfile,'data');

nrec=size(data,1);
label=cell(nrec,1);

for ii=1:nrec
%mttrialnum may have gaps in trial numbers but cutdata/label run
%consecutively from 1 to max(mttrialnum)
    itrial=mttrialnum(ii);
    data(ii,4)=itrial;
    label{ii}=deblank(cutlabel(itrial,:));
end;

keyboard;
comment=[tmpcmt crlf comment];

label=char(label);

save(synchfile,'data','label','comment','-append');
