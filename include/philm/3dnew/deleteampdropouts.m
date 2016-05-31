function deleteampdropouts(pospath,amppath,triallist,fixchannel)
% DELETEAMPDROPOUTS Delete repaired dropouts after processing is completed
% function deleteampdropouts(pospath,amppath,triallist,fixchannel)
% deleteampdropouts: Version 11.3.08
%
%   See Also
%       FIXAMPDROPOUTS

functionname='deleteampdropouts: Version 11.3.08';

ndig=4;

newcomment=['Input files : ' pospath ' ' amppath crlf 'First/last/n trial : ' int2str([triallist([1 end]) length(triallist)]) crlf 'Fixed channel : ' int2str(fixchannel)  crlf];


for itrial=triallist
    disp(itrial);
    posfile=[pospath int2str0(itrial,ndig)];
    ampfile=[amppath int2str0(itrial,ndig)];
    if exist([posfile '.mat'],'file')
        data=mymatin(posfile,'data');
        comment=mymatin(posfile,'comment');

        private=mymatin(ampfile,'private');

        fixlist=private.fixampdropouts.fixlist;

        if ~isempty(fixlist)
            data(fixlist,:,fixchannel)=NaN;
        end;

        private=mymatin(posfile,'private');
        private.deleteampdropouts.fixlist=fixlist;
        comment=[newcomment comment];
        comment=framecomment(comment,functionname);
        save(posfile,'data','comment','private','-append');
    else
        disp('Trial missing?');


    end;
end;
