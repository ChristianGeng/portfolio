function addcommentfromfile(matfile,commentfile,triallist);
% ADDCOMMENTFROMFILE Add text from file to comment variable in mat file
% function addcommentfromfile(matfile,commentfile,triallist);
% addcommentfromfile: Version 8.5.08
%
%   Syntax
%       triallist is optional. If present trial numbers are added to
%       matfile name, with leading zeros depending on maximum element in
%       list. If triallist is not present only the file with the exact file
%      name in matfile is processed

functionname='addcommentfromfile: Version 8.5.08';

mytext=readtxtf(commentfile);
if isnumeric(mytext)
    disp('problem with text file');
    return;
end;


mytext=framecomment(mytext,['From file : ' commentfile]);


ndig=0;
mylist=1;
if nargin>2
    mylist=triallist;
    ndig=length(int2str(max(mylist)));
end;

nlist=length(mylist);

for ii=1:nlist
    mysuff='';
    if ndig
        mysuff=int2str0(mylist(ii),ndig);
    end;
    myname=[matfile mysuff];

    if exist([myname '.mat'])
        comment=mymatin(myname,'comment','<No comment>');
        comment=[mytext crlf comment];
        comment=framecomment(comment,functionname);
        save(myname,'comment','-append');
    else
        disp(['Skipping file ' myname]);
    end;

end;
