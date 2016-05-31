function renumber_trials(recname1,recname2,triallist)
% RENUMBER_TRIALS Copy trial data files, changing trial number
% function renumber_trials(recname1,recname2,triallist)
% RENUMBER_TRIALS: Version 14.12.2005
%
%   Syntax
%       Triallist: 2 column list of corresponding input and output trial numbers
%           The number of digits in the trial number is determined by the
%           largest element in each column. Recname1 and 2 may need
%           trailing zeros in some cases

functionname='RENUMBER_TRIALS: Version 14.12.2005';

if not(size(triallist,2)==2)
    disp('Trial list must have two columns (input and output number)');
    return
end;

ntrial=size(triallist,1);


%number of digits in trial number; may not work correctly for all cases
%may need to adjust with zeros in recname1 or recname2 in unusual cases

ndigin= length(int2str(max(triallist(:,1))));
ndigout=length(int2str(max(triallist(:,2))));

for ii=1:ntrial
    innum=triallist(ii,1);
    inname=[recname1 int2str0(innum,ndigin)];
    newnum=triallist(ii,2);
    
    disp([innum newnum]);
    
    if exist([inname '.mat'],'file')
        
        outname=[recname2 int2str0(newnum,ndigout)];
        
        if not(exist([outname '.mat'],'file'))
            
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
        else
            disp('output file already exists');
            return
        end;
    else
        disp('Missing input trial?')
    end;
    
    
end;
