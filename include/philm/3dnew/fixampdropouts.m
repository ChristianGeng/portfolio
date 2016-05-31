function fixampdropouts(inpath,triallist,fixchannel,sigthresh)
% FIXAMPDROPOUTS Fix short dropouts caused by faulty sensor leads
% function fixampdropouts(inpath,triallist,fixchannel,sigthresh)
% fixampdropouts: Version 17.2.08
%
%   Syntax
%       sigthresh: 2 element vector. Lower limit on signal level and upper
%       limit on change in signal level. Determine appropriate values with
%       the output argument of filteramps
%
%   See Also
%       FILTERAMPS, SHOWPEGELSTATS

functionname='fixampdropouts: Version 17.2.08';

ntrans=6;
ndig=4;
%interpmethod='pchip';
%extrapspec='extrap';

interpmethod='spline';
extrapspec=NaN;         %extrapolation does not seem to work well (at least not with splines)
ispread=2;
newcomment=['Input file path : ' inpath crlf 'First/last/n trial : ' int2str([triallist([1 end]) length(triallist)]) crlf 'Fixed channel : ' int2str(fixchannel) crlf 'Signal thresholds : ' num2str(sigthresh) crlf];


fixlist=cell(max(triallist),1);

disp('Warning: This function works in place; type ''return'' to continue');
keyboard;

diary([inpath 'fixampdropouts_diary.txt']);


for itrial=triallist
    disp(itrial);
    myfile=[inpath int2str0(itrial,ndig)];
    if exist([myfile '.mat'],'file')
        data=mymatin(myfile,'data');
        warning off;
        comment=mymatin(myfile,'comment');
        private=mymatin(myfile,'private');
        warning on;
        tmpdata=data(:,1:ntrans,fixchannel);
        pegel=eucdistn(tmpdata,zeros(size(tmpdata)));
        diffpegel=abs(diff(pegel));
        diffpegel=[diffpegel;diffpegel(end)];
        vnans=(pegel<sigthresh(1)) | (diffpegel>sigthresh(2));
        if sum(vnans)>0
            for isi=1:ispread
                vnans=vnans | [zeros(isi,1); vnans(1:(end-isi))];
                vnans=vnans | [vnans((isi+1):end);zeros(isi,1)];
            end;
            if any(vnans([1 end]))
                disp('NaNs at start or end of sequence');
            end;
            


            vnotnans=find(~vnans);
            vnans=find(vnans);
            tmpdata(vnans,:)=interp1(vnotnans,tmpdata(vnotnans,:),vnans,interpmethod,extrapspec);
            data(:,1:ntrans,fixchannel)=tmpdata;
            disp([int2str(length(vnans)) ' NaNs found']);
            fixlist{itrial}=vnans;

            if isfield(private,'fixampdropouts')
                private.fixampdropouts.fixampdropouts=private.fixampdropouts;
            end;
            private.fixampdropouts.fixlist=vnans;
            comment=[newcomment comment];
            comment=framecomment(comment,functionname);
            save(myfile,'data','comment','private','-append');
        end;
    else
        disp('Trial missing?');


    end;
end;
save([inpath 'fixampdropouts_fixlist'],'fixlist','triallist','fixchannel','sigthresh');

diary off
