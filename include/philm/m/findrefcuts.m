function reflabels=findrefcuts(cutfile,labelv,typev,plotflag,min_n);
% FINDREFCUTS Find most typical item in a group based on segmentation results
% function reflabels=findrefcuts(cutfile,labelv,typev,plotflag,min_n);
% findrefcuts: Version 10.07.2011
%
%   Syntax
%       labelv specifies the columns of the label variable in cutfile that
%           defines the groups
%       typev specifies the cut types to use when determining the most
%           typical items, i.e the item with smallest average difference from
%           the mean duration over all cut types
%       plotflag (optional). Turns plotting on and off (default is on)
%           One figure for each group (segment durations broken down by cut type in each
%           figure). If there are a very large number of groups it may be
%           necessary to turn plotting off to prevent matlab from crashing.
%       min_n (optional, defaults to 2): Results only returned for groups
%           with at least this number of items
%
%   Note
%       For a given ensemble category, all cut types must be present once (and only once)
%       in each trial that contains a member of the ensemble
%       On the other hand, the same trial can contain members of different
%       ensembles (I think/hope)
%       The graphics are intended to give an idea of whether there are any
%       very unusual segment durations for each cut type and each ensemble
%
%   See Also
%       ENSCUTTW Main use of findrefcuts is to set up reference segments
%       for ensemble averages with time warping

doplot=1;
if nargin>3 if ~isempty(plotflag) doplot=plotflag;end; end;

mintoken=2;
if nargin>4 mintoken=min_n; end;

load(cutfile);

labelx=label(:,labelv);

grplabel=unique(labelx,'rows');

ngrp=size(grplabel,1);

reflabels=cell(ngrp,1);
tokencount=zeros(ngrp,1);
for igrp=1:ngrp
    mylabel=deblank(grplabel(igrp,:));
    disp(['Group ' int2str(igrp) ' : ' mylabel]);

    vc=strmatch(mylabel,labelx);
    ltmp=label(vc,:);
    dtmp=data(vc,:);

    %first pass: get means and check same n for each type
    ntype=length(typev);
    typen=zeros(ntype,1);
    typemeandur=zeros(ntype,1);
    for iti=1:ntype
        mytype=typev(iti);
        %      disp(['Checking cut type ' int2str(mytype)]);
        vt=find(dtmp(:,3)==mytype);
        typen(iti)=length(vt);
        typemeandur(iti)=mean(dtmp(vt,2)-dtmp(vt,1));
        tchk=dtmp(vt,4);
        if iti==1
            tchk1=dtmp(vt,4);
        end;
        if typen(iti)~=typen(1)
            disp('Must have same n for each cut type');
            disp([typev;typen]);
            return
        end;

        if ~all(tchk==tchk1)
            disp('Trial numbers do not match over cut types');
            disp([tchk;tchk1]);
            return;
        end;

        if length(unique(tchk))~=length(tchk)
            disp('Multiple cuts per trial??');
            disp([ltmp(vt,:) num2str(dtmp(vt,:))]);
%            disp(tchk);
            keyboard
            return;
        end;




    end;



    typen=typen(1);

        tokencount(igrp)=typen;
        
    devbuf=zeros(typen,1);
    mycol=hsv(typen);

if typen>=mintoken
    if doplot figure; end;
    %second pass. Get deviations from mean
    for iti=1:ntype
        mytype=typev(iti);
        vt=find(dtmp(:,3)==mytype);
        cl=dtmp(vt,2)-dtmp(vt,1);

        if doplot
            plot(cl,repmat(mytype,[typen 1]),'.');
            for ixx=1:typen
                %         text(cl(ixx),mytype,ltmp(vt(ixx),:),'color',mycol(ixx,:));
                text(cl(ixx),mytype,int2str(ixx),'color',mycol(ixx,:),'fontweight','bold');
            end;



            drawnow;
            hold on;

        end;
        devbuf=devbuf+abs(cl-typemeandur(iti));
    end;

    if doplot
        title(mylabel,'fontsize',12,'fontweight','bold','interpreter','none');
        xlabel('Duration (s)');
        ylabel('Cut type');

    end;

    disp(['Deviation sums n and mean/sd/max/min (in ms): ' int2str(typen) ' ' num2str([mean(devbuf) std(devbuf) max(devbuf) min(devbuf)]*1000)]);
%    disp(devbuf);
    [dodo,mp]=min(devbuf);
    [dodo,maxp]=max(devbuf);

    reflabels{igrp}=deblank(ltmp(vt(mp),:));
    worstitem=deblank(ltmp(vt(maxp),:));
    disp(['Reference item and worst item : ' reflabels{igrp} ' ' worstitem]);

    hold off;
else
    disp('Not enough tokens for this group');
end;

end;

vv=find(tokencount<mintoken);
reflabels(vv)=[];

reflabels=char(reflabels);
