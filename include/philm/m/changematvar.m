function changematvar(matfile,calcspec,variablesout,briefcomment,fixflag,triallist);
% CHANGEMATVAR Change variables in mat files
% function changematvar(matfile,calcspec,variablesout,briefcomment,fixflag,triallist);
% changematvar: Version 13.02.07
%
%   Syntax
%       triallist: Optional. If present trial numbers are added to
%           matfile name, with leading zeros depending on maximum element in
%           list. If triallist is not present only the file with the exact file
%           name in matfile is processed
%       calcspec: The calculation to be performed, i.e string to be passed
%           to eval
%           Note that the calculation should not normally change the size of any
%           variables. If this happens, the user is given a warning.
%               Note in particular that if the number of rows in data is
%               changed then it may be necessary to change the number of
%               rows in 'label', and if the number of columns in data is
%               changed it may be necessary to change the number of rows in
%               'descriptor' and 'unit'
%       variablesout: List of the variables (as cell array) to be saved to the
%           mat file. 
%       briefcomment: Text to add to existing comment variable, e.g to
%           explain purpose of calculation, reason for modifying existing data
%           etc. If calcspec is implemented by a call to a special-purpose
%           function the briefcomment could for example include the code or
%           the help text of this function
%      fixflag: Results of processing only stored if fixflag==1. 
%           Since mat files are modified in place, it may be advisible to
%           do a test run to first check that the processing runs without
%           errors. Set to zero to do a test run 
%
%   See Also ADDVARIABLE2MAT, OUTLIERS2NAN

functionname='changematvar: Version 25.03.07';


varlist='';
if ~isempty(variablesout) 
    variablesout=cellstr(variablesout); 
    varlist=strm2rv(char(variablesout),' ');
end;

briefcomment=framecomment(briefcomment,'changematvar: Brief comment');



trialspec='';
ndig=0;
%listmode=0;
mylist=1;
if nargin>5
    mylist=triallist;
    ndig=length(int2str(max(mylist)));
    
    trialspec=['changematvar min/max/n trials: ' int2str(min(mylist)) ' ' int2str(max(mylist)) ' ' int2str(length(mylist))];
    
    %listmode if one calcspec for each trial would be easy enough to
    %implement
    %    if size(variablevalue,1)==length(triallist)
    %        listmode=1;
    %        disp('Treating variablevalue as list');
    %    end;
    
end;

nlist=length(mylist);

for ii=1:nlist
    mysuff='';
    if ndig
        mysuff=int2str0(mylist(ii),ndig);
    end;
    myname=[matfile mysuff];
    
    if exist([myname '.mat'])

                disp([myname]);

        %        myval=variablevalue;
        %        if listmode myval=variablevalue(ii,:); end;
        try
            
            fixmat(myname,calcspec,variablesout,fixflag);
            
            
        catch
%            disp(myname)
            disp(['Problem evaluating ' calcspec]);
            disp(lasterr);
            return;
        end;
        comment=mymatin(myname,'comment','No comment before processing with changematvar');
        comment=['changematvar calcspec: ' calcspec crlf 'changematvar changed variables: ' varlist crlf trialspec crlf briefcomment crlf comment];
        comment=framecomment(comment,functionname);
        if fixflag save(myname,'comment','-append'); end;
    else
        disp(['Skipping file ' myname]);
    end;
    
end;
function fixmat(fixmat_myname,fixmat_calcspec,fixmat_variablesout,fixmat_fixflag);

load(fixmat_myname);

%get sizes of variables to be modified
if ~isempty(fixmat_variablesout)
    fixmat_nvar=length(fixmat_variablesout);
    fixmat_vsize=cell(fixmat_nvar,1);
    for fixmat_ii=1:fixmat_nvar
        eval(['fixmat_vsize{fixmat_ii}=size(' fixmat_variablesout{fixmat_ii} ');']);
    end;
end;


eval(fixmat_calcspec);

%keyboard;

if ~isempty(fixmat_variablesout)
    
    
    badsize=0;
    for fixmat_ii=1:fixmat_nvar
        eval(['fixmat_chksize=size(' fixmat_variablesout{fixmat_ii} ');']);
        if length(fixmat_chksize)~=length(fixmat_vsize{fixmat_ii})
            badsize=1;
        else
            if any(fixmat_chksize~=fixmat_vsize{fixmat_ii})
                badsize=1;
            end;
        end;
        if badsize
            disp('Variable sizes changed??')
            disp(fixmat_myname);
            disp(fixmat_variablesout{fixmat_ii});
            disp(fixmat_chksize);
            disp(fixmat_vsize{fixmat_ii});
            disp('Abort the program with CTRL C if this should not have happened!');
            keyboard;
%            return
        end;
        
    end;
    
    
    
    
    if fixmat_fixflag
        save(fixmat_myname,fixmat_variablesout{:},'-append');
    end;
    
end;
