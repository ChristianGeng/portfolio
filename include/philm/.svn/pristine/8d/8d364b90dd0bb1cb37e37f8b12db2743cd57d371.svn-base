function addlabcmt2sync_f(synchfile,logfile,cmtfile)
% ADDLABCMT2SYNC_F Set up trial numbers and labels in sync file
% function addlabcmt2sync_f(synchfile,logfile,cmtfile)
% addlabcmt2sync_f: Version 17.11.05
%
%   Description
%       This version for ag500 recordings.
%       Uses the log file from matlab prompt program to generate
%       labels and trial numbers for synch file (usually from scanning Sony
%       BIN file with getlsbc_ii).
%       Records in the log file must match lines in the data variable of synch
%       file 1 to 1.
%       logfile must be specified without extension (must be .txt.) and
%       must have been processed by adjlogfilev (even if no changes to
%       trial numbers were necessary)
%
%   See Also
%       GETLSBC_II extract synch impulse from sony bin files
%       PARSELOGFILE
%       ADJLOGFILEV

%Note: for simple cases where no modification of trial number is necessary
%one could use addvariable2mat and addcommentfromfile to put label and
%comment information in a sync file

functionname='addlabcmt2sync_f: Version 17.11.05';

[cutdata,cutlabel,agtrialnum,mttrialnum,trialnumS]=parselogfile(logfile);

addcommentfromfile(synchfile,cmtfile);

tmpcmt=['Log file : ' logfile crlf];


comment=mymatin(synchfile,'comment');
data=mymatin(synchfile,'data');

nrec=size(data,1);
label=cell(nrec,1);

if size(mttrialnum,1)~=size(data,1)
    disp('lengths of mttrialnum and data do not match');
    keyboard;
end;


for ii=1:nrec
%mttrialnum may have gaps in trial numbers but cutdata/label run
%consecutively from 1 to max(mttrialnum)
    itrial=mttrialnum(ii);
    data(ii,4)=itrial;
    label{ii}=deblank(cutlabel(itrial,:));
end;

keyboard;
comment=[tmpcmt comment];
comment=framecomment(comment,functionname);

label=char(label);

save(synchfile,'data','label','comment','-append');
