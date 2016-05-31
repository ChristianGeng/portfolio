function binsig(xchan,ychan,binvec,klammer);
% BINSIG Stats for y channels binned on x axis
% function binsig(xchan,ychan,binvec,klammer);
% binsig: Version 11.9.97
%
%   Description
%       use mm_org to set up data access
%       y channels are binned using data in x channels
%       binvec is a vector of bin edges (e.g 0:0.1:10)
%       (there will be length(binvec)-1 bins)
%       klammer is to make a selection from the cut file
%
%   Note
%       Needs rewriting for mt functions!!

% check xchan, ychan same length

        functionname='binsig: Version 11.9.97';
        namestr=['<Start of Comment> ' functionname crlf];

        nchan=length(xchan);

        hh=findobj('tag','cut_file_axis');
        hh=get(hh,'title');
        cutname=get(hh,'string');
        namestr=[namestr 'Cut file: ' cutname '. Bracket level: ' int2str(klammer) crlf];
        %maybe better from cut file
        namestr=[namestr 'Comment from first signal file ================' crlf];
        ctmp=mm_gtagd(xchan(1),'comment');
        namestr=[namestr ctmp crlf];

        comment=[namestr '<End of Comment> ' functionname crlf];

        maxn=100000;
        buf=zeros(maxn,2);
        bins=binvec;
        nbin=length(bins);
        binsh=bins(2:nbin);
        bins(nbin)=[];
        nbin=nbin-1;
        binpos=(bins+binsh)./2;
        [m,n]=size(binpos);
        if n>m binpos=binpos';end;

        data=binpos;
        descriptor='bin_position';
        unit=mm_gtagd(1,'unit');

        cutdata=mm_gcbud;
        vv=find(cutdata(:,3)==klammer);
        cutdata=cutdata(vv,:);
        ncut=size(cutdata,1);
        sf=mm_gtagd(xchan(1),'samplerate');     %assume all channels same

        for ichan=1:nchan
        if ichan>1 load mybin; end;
        ixc=xchan(ichan);iyc=ychan(ichan);
        dtmp=deblank(mm_gtagd(iyc,'descriptor'));
        utmp=deblank(mm_gtagd(iyc,'unit'));
        descriptor=str2mat(descriptor,[dtmp '_mean'],[dtmp '_sd'],[dtmp '_max'],[dtmp '_min'],[dtmp '_n']);
        unit=str2mat(unit,utmp,utmp,utmp,utmp,' ');
        binmax=zeros(nbin,1);binmin=zeros(nbin,1);binmean=zeros(nbin,1);binsd=zeros(nbin,1);binn=zeros(nbin,1);
        ip=1;
        for icut=1:ncut
            mytime=cutdata(icut,1:2);
            xy=mmxxydis([ixc iyc],mytime,sf);
            ll=size(xy,1);
            ip2=ip+ll-1;
            buf(ip:ip2,:)=xy;
            ip=ip2+1;
        end;
        ip=ip-1;
        buf=buf(1:ip,:);

        %loop thru bins
        for ib=1:nbin
            disp([ib bins(ib) binsh(ib)]);
            vv=find((buf(:,1)>bins(ib)) & (buf(:,1)<=binsh(ib)));
            if ~isempty(vv)
               x=buf(vv,2);
               binn(ib)=length(x);
               disp(binn(ib));
               binmax(ib)=max(x);
               binmin(ib)=min(x);
               binmean(ib)=mean(x);
               binsd(ib)=std(x);
            end;
        end;
        data=[data binmean binsd binmax binmin binn];

        save mybin data descriptor unit comment;

        end;       %channel loop
