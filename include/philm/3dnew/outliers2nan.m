function outliers2nan(pospath,triallist,sensorsused,rmsthreshb,velthreshb,compsens,eucthresh,fixflag)
% OUTLIERS2NAN Delete outliers in pos files. In place! Use with care!
% function outliers2nan(pospath,triallist,sensorsused,rmsthreshb,velthreshb,compsens,eucthresh,fixflag)
% outliers2nan: Version 1.1.06
%
%   Syntax
%       Fixflag: data only changed if fixflag==1, so do trial run with fixflag==0
%       pospath: common part of file name, i.e excluding the digits of the trial number
%       triallist: List of trials to process (currently trial number assumed to have 4 digits)
%       sensorsused: list of sensors to process
%           each element of sensorsused is used as an index into the following variables: 
%   `   rmsthreshb: list of rms thresholds. If scalar, same value is used for all sensors
%       velthreshb: Tangential velocity threshold (syntax same as rmsthreshb)
%       compsens: (Same syntax as rmsthresb; set to NaN if not needed) Euclidean distance of target sensor from this sensor is
%           compared with the setting in eucthresh.
%       eucthresh: n_sensor * 2 array of lower and higher limits for euclidean distances
%
%   See Also
%       AMPVSPOSAMP Uses similar settings for rms, velocity and euclidean distance threshold
%       COMPPOS_F Help with determining appropriate threshold settings

functionname='outliers2nan: Version 1.1.06';

nsensor=12;

if length(rmsthreshb)==1 rmsthreshb=repmat(rmsthreshb,[nsensor 1]); end;
if length(velthreshb)==1 velthreshb=repmat(velthreshb,[nsensor 1]); end;
if length(compsens)==1 compsens=repmat(compsens,[nsensor 1]); end;

if size(eucthresh,2)<2 eucthresh=[NaN NaN]; end;
if size(eucthresh,1)<nsensor eucthresh=[eucthresh;repmat([NaN NaN],[nsensor 1])]; end;
    
sf=200;         %normally will be read from input file

ndig=4;     %fixed

ntrial=length(triallist);

badindex=cell(max(triallist),nsensor);
baddata=badindex;

diary([pospath 'outliers_lst.txt']);

newcomment='';
for ii=sensorsused
    ss=['Sensor ' int2str(ii) ' rms: ' num2str(rmsthreshb(ii)) ' velocity: ' num2str(velthreshb(ii)) ' comparison sensor: ' int2str(compsens(ii)) ' thresholds: ' num2str(eucthresh(ii,:))];
    newcomment=[newcomment ss crlf];
end;


for iti=1:ntrial
    tt=triallist(iti);
    tts=int2str0(tt,ndig);
    
%assume matlab input
    myname=[pospath tts];
    px=double(mymatin(myname,'data'));
    sf=mymatin(myname,'samplerate');
    descriptor=mymatin(myname,'descriptor');
    P=desc2struct(lower(descriptor));
    comment=mymatin(myname,'comment');

    comment=[newcomment comment];
    comment=framecomment(comment,functionname);
    
    private=mymatin(myname,'private');
    
    %check for existing field outliers2nan in private
    
    %    px=loadpos([pospath '\' tts '.pos']);
    deleted_data=cell(nsensor,1);
    deleted_samples=cell(nsensor,1);
    
    sensorsfixed=0;
    if ~isempty(px)
        for ii=sensorsused
            rmsthresh=rmsthreshb(ii);
            velthresh=velthreshb(ii);


            vtmprms=px(:,P.rms,ii)>rmsthresh;
            postmp=px(:,1:3,ii);
            euctmp=eucdistn(postmp(1:end-1,:),postmp(2:end,:));
            euctmp=euctmp*sf;
            euctmp=euctmp>velthresh;
            euctmp=[euctmp;euctmp(end)];
            euctmp=euctmp |[euctmp(1);euctmp(1:end-1)];

            euccomp=zeros(size(vtmprms));
            if ~isnan(compsens(ii))
                compdata=px(:,1:3,compsens(ii));
                euccomp=eucdistn(postmp,compdata);
                euccomp=euccomp<eucthresh(ii,1) | euccomp>eucthresh(ii,2);
            end;
            vtmp=vtmprms | euctmp | euccomp;

            if any(vtmp)
                disp(['Trial/Sensor ' int2str([tt ii])  '. Bad samples (overall, rms, vel. euc. ' int2str(sum([vtmp vtmprms euctmp euccomp]))]);

                if fixflag
                    vtmpv=find(vtmp);
%                    badindex{tt,ii}=vtmpv;
%                    baddata{tt,ii}=px(vtmpv,:,ii);
                    deleted_data{ii}=single(px(vtmpv,:,ii));
                    deleted_samples{ii}=vtmpv;
                    px(vtmp,:,ii)=NaN;
                    sensorsfixed=1;
                    
                end;



            end;

        end;    %sensor loop
        if sensorsfixed
%store fixed data in private????
            disp('writing data');
            data=single(px);
            if isfield('outliers2nan',private);
                private.outliers2nan.outliers2nan=private.outliers2nan;
            end;
            
            private.outliers2nan.deleted_data=deleted_data;
            private.outliers2nan.deleted_samples=deleted_samples;
%            keyboard;
            save(myname,'data','comment','private','-append');
%            savepos([pospath '\' tts '.pos'],px);
        end;


    end;        %input not empty

end;        %trial loop

if fixflag
    save([pospath 'deleted_data'],'badindex','baddata','pospath','triallist','sensorsused','rmsthreshb','velthreshb','compsens','eucthresh');
end;

diary off
