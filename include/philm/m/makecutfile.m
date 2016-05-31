function makecutfile(recpath,cutname,triallist,labellist);
% MAKECUTFILE Make cut file by examining length of signal files
% function makecutfile(recpath,cutname,triallist,labellist);
% makecutfile: Version 8.5.08
%
%   Description
%       labellist is optional. If absent try and use item_id in signal file as label
%       If labellist is present, must match triallist one-to-one
%       recpath is common part of name of signal files, without trial
%       number.
%       Digits in trialnumber is based on maximum of triallist
%       so may be necessary to include leading zeros in recpath
%
%   Updates
%       1.08 Start implementing data variables where time is not the first
%       dimension (but still correctly handle sensor-style, like 3D EMA)


functionname='makecutfile: Version 8.5.08';

uselist=0;
if nargin>3 uselist=1; end;

ntrial=length(triallist);

cutdata=ones(ntrial,4)*NaN;

if uselist
    cutlabel=labellist;
    if not(size(cutlabel,1)==ntrial);
        disp('labellist wrong length for triallist');
        return;
    end;
    cutlabel=cellstr(cutlabel);
else
    cutlabel=cell(ntrial,1);
end;


ndig=length(int2str(max(triallist)));

commentok=0;

for ipi=1:ntrial
    itrial=triallist(ipi);
    trials=int2str0(itrial,ndig);
    myname=[recpath trials];
    %    disp(myname)
    if exist([myname '.mat'],'file');
        samplerate=mymatin(myname,'samplerate');

        if ~commentok
            comment=mymatin(myname,'comment','No comment in signal file');
            commentok=1;
        end;



        if not(uselist)
            tmplabel=mymatin(myname,'item_id',trials);
            cutlabel{ipi}=tmplabel;
        end;

        disp([trials ' ' cutlabel{ipi}]);

        cutdata(ipi,3)=0;
        cutdata(ipi,1)=0;
        cutdata(ipi,4)=itrial;

        D=whos('-file',myname,'data');
        mysize=D.size;
        Dd=whos('-file',myname,'descriptor');
        mysized=Dd.size;

        %should also try and read dimension descriptor
        timestr='';
        timecheckp=0;
        mydimension=mymatin(myname,'dimension');
        if isfield(mydimension,'descriptor')
            vvt=strmatch('time',lower(mydimension.descriptor));
            if length(vvt)==1
                timestr=deblank(mydimension.descriptor(vvt,:));
                timecheckp=vvt;
            end;
        end;


        %do we need both conditions in practice?
        timedim=1;
        if length(mysize)>2
            if mysized(1)==1
                timedim=length(mysize);
            end;
        end;

        if mysized(1)~=mysize(2) timedim=length(mysize); end;

        %condition for sensor-style data:
        %   if ndesc>1 & length(dataS.size)>2

        if ~isempty(timestr)
            if timedim~=timecheckp
                disp('Check program logic for identifying time dimension');
                disp(['timedim, timecheckp, timestr : ' int2str([timedime timecheckp]) ' ' timestr]);
            end;

        end;



        mytime=mysize(timedim)/samplerate;


        cutdata(ipi,2)=mytime;
    else
        disp([myname ': No signal file']);
    end;
end;

disp(['Time dimension was ' int2str(timedim)]);


if ~commentok
    disp('No signal files at all? Check recpath and triallist (e.g correct number of leading zeros in trial number)');
    disp('No cut file created');
    return;
end;

%keyboard;

vv=find(isnan(cutdata(:,1)));
cutdata(vv,:)=[];
cutlabel(vv)=[];

data=cutdata;
label=char(cutlabel);
[descriptor,unit,valuelabel]=cutstrucn;


comment=framecomment(comment,'From first signal file');

comment=['Path to signal files : ' recpath crlf comment];

comment=framecomment(comment,functionname);



save(cutname,'data','label','descriptor','unit','valuelabel','comment');
