function addvariable2mat(matfile,variablename,variablevalue,triallist);
% ADDVARIABLE2MAT Add variable to mat file
% function addvariable2file(matfile,variablename,variablevalue,triallist);
% addvariable2mat: Version 6.11.05
%
%   Syntax
%       triallist is optional. If present trial numbers are added to
%       matfile name, with leading zeros depending on maximum element in
%       list. If triallist is not present only the file with the exact file
%      name in matfile is processed

functionname='addvariable2mat: Version 6.11.05';


ndig=0;
listmode=0;
mylist=1;
if nargin>3
    mylist=triallist;
    ndig=length(int2str(max(mylist)));
    if size(variablevalue,1)==length(triallist)
        listmode=1;
        disp('Treating variablevalue as list');
    end;
    
end;

nlist=length(mylist);

for ii=1:nlist
    mysuff='';
    if ndig
        mysuff=int2str0(mylist(ii),ndig);
    end;
    myname=[matfile mysuff];

    if exist([myname '.mat'])
        myval=variablevalue;
        if listmode myval=variablevalue(ii,:); end;
        try
        eval([variablename '=myval;']); 
        catch
            disp(myname)
            disp('Problem evaluating variable');
            return;
        end;
        comment=mymatin(myname,'comment');
        comment=['Variable added: ' variablename crlf comment];
        comment=framecomment(comment,functionname);
        save(myname,variablename,'comment','-append');
    else
        disp(['Skipping file ' myname]);
    end;

end;
