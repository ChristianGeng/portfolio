function adjampsa(inpath,outpath,triallist,sensorlist,bc)
% ADJAMPSA Adjust amplitudes using prediction of residue from all amplitudes
% function adjampsa(inpath,outpath,triallist,sensorlist,bc)
% adjampsa: Version 15.2.05
%
%   Description
%       Each element of the cell array bc contains the vector of regression
%       coefficients (normally 7; constant term first, then one for each
%       transmitter)
%       The coefficients will normally have been determined by
%       AMPSVSPOSAMPSA
%       sensorlist is a vector of sensors to process.
%       The sensor number gives the index into the row of cell array of bc
%       bc must have 6 columns, corresponding to the number of
%       transmitters
%
%   See Also
%       AMPSVSPOSAMPA

functionname='adjampsa: Version 15.12.2005';

myversion=version;
saveop='-v6';
if myversion(1)<'7' saveop=''; end;


newcomment=['Input path: ' inpath crlf 'Output path: ' outpath crlf ...
    'First/last/n trials: ' int2str([triallist(1) triallist(end) length(triallist)]) crlf ...
    'Sensor list: ' int2str(sensorlist) crlf ...
    'Adjustment coefficients in private.adjamps' crlf];


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
    private.adjamps.b=bc;
    comment=[newcomment comment];
    comment=framecomment(comment,functionname);

    data=loadamp(inname);
    disp(itrial);
    if ~isempty(data)
        ndim=size(data,2);
        for isensor=1:nsensor
            mysensor=sensorlist(isensor);
%essential to use a copy as original data is overwritten!!
            da=data(:,:,mysensor);
            
            for idim=1:ndim
                dd=da(:,idim);
                predres=[ones(length(dd),1) da]*bc{mysensor,idim};
                dd=dd+predres;
                data(:,idim,mysensor)=dd;
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

