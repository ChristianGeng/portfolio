function calcsensorfromothers(pospath,amppath,outpath,triallist,coff_file)
% CALCSENSORFROMOTHERS Calculate predicted position of sensors based on others
% function calcsensorfromothers(pospath,amppath,outpath,triallist,coff_file)
% calcsensorfromothers: Version 25.11.07
%
%   Description
%       coff_file contains the result of the regression analysis carried
%       out by PREDICTSENSORFROMOTHERS
%       In particular it also contains the information on what sensor is to
%       be predicted.
%       predictsensorfromothers normally calculates the prediction using
%       both raw data and a principal component approach.
%       The PC approach will be used here if the variable PC.pcorder > 0
%       Note that a folder with posamps is generated to accompany the
%       predicted positions stored in outpath (this is why both positions
%       and amplitudes are needed for the input data (in pospath and
%       amppath respectively)
%       (All paths should be specified without path character)
%
%   See Also
%       PREDICTSENSORFROMOTHERS AMPSVSPOSAMPA VELOCITYPREDPOS

functionname='calcsensorfromothers: Version 25.11.2007';


%??? need to allow for multiple passes???

myversion=version;
saveop='-v6';
if myversion(1)<'7' saveop=''; end;

rmsfac=2500;
orifac=pi/180;

mkdir([outpath pathchar 'posamps']);

newcomment=['Input paths: ' pospath ' ' amppath crlf 'Output path: ' outpath crlf ...
    'First/last/n trials: ' int2str([triallist(1) triallist(end) length(triallist)]) crlf ...
    'Coefficient file: ' coff_file crlf];


%bc is a cell array of regression coefficients
%row1: raw data, row2: PC. Columns are the 6 coordinates (3 pos, 3 ori)
bc=mymatin(coff_file,'bc');
sensor2predict=mymatin(coff_file,'sensor2predict');
sensorsused=mymatin(coff_file,'sensorsused');
predictor_coordinates=mymatin(coff_file,'predictor_coordinates');
PC=mymatin(coff_file,'PC');

pcorder=PC.pcorder;

imethod=1;
nscore=0;
if pcorder>0
    nscore=pcorder;
    imethod=2;
end;


ndig=4;



for itrial=triallist
    trialstr=int2str0(itrial,ndig);
    inname=[pospath pathchar trialstr];
    outname=[outpath pathchar trialstr];
    ampname=[amppath pathchar trialstr];    %needed for recalculating rms

    posampin=[pospath pathchar 'posamps' pathchar trialstr];
    posampout=[outpath pathchar 'posamps' pathchar trialstr];
    
    
    
    private=[];
    comment='';
    if exist([inname '.mat'],'file')
        copyfile([inname '.mat'],[outname '.mat']);
        copyfile([posampin '.mat'],[posampout '.mat']);
        private=mymatin(inname,'private');
        comment=mymatin(inname,'comment');

        %check this field already exists????
        private.calcsensorfromothers.b=bc;
        comment=[newcomment comment];
        comment=framecomment(comment,functionname);

        [data,descriptor,unit,dimension,allsensorlist]=loadpos_sph2cartm(inname);
        disp(itrial);
        ndim=6;     %i.e 3 pos, 3 ori; Assume this is fixed

        mysensor=sensor2predict;
        preddat=data(:,predictor_coordinates,sensorsused);
        preddat=reshape(preddat,[size(preddat,1) length(sensorsused)*length(predictor_coordinates)]);
        % if PC approach, convert to pc scores
        if nscore
            sduse=PC.sdev;
            if PC.covflag
                sduse=[];
            end;
            eigvec=PC.eigvec;
            eigvec=eigvec(:,1:nscore);
            pcscore=pcscores(preddat,eigvec,PC.xbar,sduse);
            preddat=pcscore;
            %                predmat=x2fx(pcscore,x2fx_mode);
        end;




        ndat=size(data,1);

        for idim=1:ndim
            %check this???
            dd=[ones(ndat,1) preddat]*bc{imethod,idim};
            data(:,idim,mysensor)=dd;
        end;

        %predict new posamps

        %and convert data back to spherical orientations

            [data(:,4,mysensor),data(:,5,mysensor),dodo]=cart2sph(data(:,4,mysensor),data(:,5,mysensor),data(:,6,mysensor));
            
            data(:,4:5,mysensor)=data(:,4:5,mysensor)/orifac;      %convert back to degrees if necessary
            pax=calcamps(data(:,1:5,mysensor));

            datanew=data;
            data=mymatin(inname,'data');
            aa=mymatin(ampname,'data');
            
            
            %parameter 7 no longer relevant, so store posampdt (may be overwritten
            %later anyway but e.g eucdist2pos
            [datanew(:,6,mysensor),datanew(:,7,mysensor)]=posampana(aa(:,:,mysensor),pax,rmsfac);
            %            disp('new rms calculated');

        
        
        
        data(:,1:7,mysensor)=single(datanew(:,1:7,mysensor));
        save(outname,'data','comment','private','-append',saveop);

        data=mymatin(posampout,'data');

        data(:,:,mysensor)=single(pax);
        comment=mymatin(posampout,'comment');

                comment=[newcomment comment];
        comment=framecomment(comment,functionname);

        save(posampout,'data','comment','-append',saveop);
        



    else
        disp('skipping trial');
    end;

end;

