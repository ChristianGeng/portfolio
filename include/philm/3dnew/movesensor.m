function movesensor(inpath1,inpath2,triallist,chanlist)
% MOVESENSOR Move sensor data from auxiliary file to main file
% function movesensor(inpath1,inpath2,triallist,chanlist)
% movesensor: Version 17.4.06
%
%   Syntax
%       Chosen sensors are taken from inpath2 (auxiliary file) and placed in inpath1 (main file):  
%       (path names with backslash (i.e common part of file name))
%       triallist/chanlist: Vector of trials/channels to process
%       No checks that sensor names of main and auxiliary files match
%
%   See Also MERGEBYMEANSQU

functionname='movesensor: Version 17.04.06';

maxchan=12;

myver=version;

saveop='';
if myver(1)>='7' saveop='-v6'; end;

newcomment=['Input 1, Input 2: ' inpath1 ' ' inpath2  crlf ...
        'First/last/n trials: ' int2str([triallist(1) triallist(end) length(triallist)]) crlf ...
        'Sensor list: ' int2str(chanlist) crlf];


for itrial=triallist
    disp(itrial);
    ts=int2str0(itrial,4);
    
    inname=[inpath1 pathchar ts];
    inname2=[inpath2 pathchar ts];
    %    outname=[outpath pathchar ts];
    outname=[inpath1 pathchar ts];
    
    
    
    if exist([inname '.mat'])
        
        pp1=mymatin(inname,'data');
        comment=mymatin(inname,'comment');
        private=mymatin(inname,'private');
        
        %note: no checks that auxiliary input exists, and data is same length
        if exist([inname2 '.mat'])
            
            pp2=mymatin([inpath2 pathchar ts],'data');
            comment2=mymatin([inpath2 pathchar ts],'comment');
            private2=mymatin([inpath2 pathchar ts],'private');
            
            comment2=framecomment(comment2,'Movesensor: Comment from auxiliary input file');
            comment=[newcomment comment crlf comment2];
            comment=framecomment(comment,functionname);
            
            if isfield(private,'movesensor')
                private.movesensor.movesensor=private.movesensor;
            end;
            private.movesensor.private2=private2;
            
            
            
            %        pout=ones(size(pp1))*NaN;
            
            for ich=chanlist
                
                pp1(:,:,ich)=pp2(:,:,ich);            
                
            end;        %channel list
            
            %always output as mat file, but some variables will be missing if
            %input was not mat
            data=single(pp1);
            save(outname,'data','comment','private','-append',saveop);
        else
            disp('input 2 missing')
            
        end;        %input 2 not missing
    else
        disp('input 1 missing');
    end;            %input 1 not missing
end;                %trial list

