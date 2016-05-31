function adjamps(inpath,outpath,triallist,sensorlist,b1,b2)
% ADJAMPS Adjust amplitudes
% function adjamps(inpath,outpath,triallist,sensorlist,b1,b2)
% adjamps: Version 19.9.05
%
%   Description
%       newamp=b1+b2*oldamp
%       The coefficients in b1 and b2 will normally have been determined by
%       AMPSVSPOSAMPS
%       sensorlist is a vector of sensors to process.
%       The sensor number gives the index into the row of b1 and b2
%       b1 and b2 must both have 6 columns, corresponding to the number of
%       transmitters
%
%   See Also
%       AMPSVSPOSAMP

functionname='adjamps: Version 19.09.2005';

myversion=version;
saveop='-v6';
if myversion(1)<'7' saveop=''; end;


newcomment=['Input path: ' inpath crlf 'Output path: ' outpath crlf ...
    'First/last/n trials: ' int2str([triallist(1) triallist(end) length(triallist)]) crlf ...
    'Sensor list: ' int2str(sensorlist) crlf ...
    'Adjustment coefficients (output=b1+b2*input) in private.adjamps' crlf];


nsensor=length(sensorlist);

ndig=4;



for itrial=triallist
    inname=[inpath pathchar int2str0(itrial,ndig)];
    outname=[outpath pathchar int2str0(itrial,ndig)];
    matin=0;
    private=[];
    comment='';
    if exist([inname '.mat'])
        matin=1;
        copyfile([inname '.mat'],[outname '.mat']);
        private=mymatin(inname,'private');
        comment=mymatin(inname,'comment');

    end;
%check this field already exists????
    private.adjamps.b1=b1;
    private.adjamps.b2=b2;
    comment=[newcomment comment];
    comment=framecomment(comment,functionname);

    data=loadamp(inname);
    disp(itrial);
    if ~isempty(data)
        ndim=size(data,2);
        for isensor=1:nsensor
            mysensor=sensorlist(isensor);

            for idim=1:ndim
                data(:,idim,mysensor)=b1(mysensor,idim)+(b2(mysensor,idim)*data(:,idim,mysensor));
            end;
        end;

        %always output as mat file, but some variables will be missing if
        %input was not mat
        data=single(data);
        if matin
            save(outname,'data','comment','private','-append',saveop);
        else
            save(outname,'data','comment','private',saveop);
        end;


        %    saveamp([outpath pathchar int2str0(itrial,ndig) ampext],data);



    else
        disp('skipping trial');
    end;

end;

