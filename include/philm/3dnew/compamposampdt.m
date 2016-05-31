function [xbufrms,sdbufrms,maxbufrms,xbufdt,sdbufdt,maxbufdt]=compamposampdt(ampdir,posdir,triallist,rmsfac)
% COMPAMPOSAMPDT Compare 1st derivative of measured amps and posamps.
% function [xbufrms,sdbufrms,maxbufrms,xbufdt,sdbufdt,maxbufdt]=compamposampdt(ampdir,posdir,triallist,rmsfac)
% compamposampdt: Version 17.9.05
%
%   Description
%       this version stores result as 7th parameter of pos file
%       also recalculates rms in parameter 6
%       returns stats of rms and dt for each trial in output arguments
%       rmsfac: should be 2500 for compatibility with current Carstens
%       software
%       ampdir/posdir: specifiy without backslash
%
%   See Also
%       POSAMPANA

outparrms=6;
outpardt=7;

%triallist=5:154;

xbufrms=ones(max(triallist),12)*NaN;
sdbufrms=ones(max(triallist),12)*NaN;
maxbufrms=ones(max(triallist),12)*NaN;
xbufdt=xbufrms;
sdbufdt=sdbufrms;
maxbufdt=maxbufrms;

%outname='rawposadj\posampdt\posampdt_';
%rmsfac=2500;       for new carstens software
%rmsfac=1;       for tapad

for iti=triallist
    disp(iti)
    mytrial=int2str0(iti,4);
    aa=loadamp([ampdir '\' mytrial '.amp']);
%    aa=loadamp([ampdir '\' mytrial]);
    if ~isempty(aa)
        nsensor=size(aa,3);
%        pa=loadamp([posdir '\posamps\' mytrial '.amp']);
%        pp=loadpos([posdir '\' mytrial '.pos']);
        pa=loadamp([posdir '\posamps\' mytrial]);
        pp=loadpos([posdir '\' mytrial]);

        [posamprms,data]=posampana(aa,pa,rmsfac);

        xbufrms(iti,:)=mean(abs(posamprms));
        sdbufrms(iti,:)=std(posamprms);
        maxbufrms(iti,:)=max(posamprms);
        xbufdt(iti,:)=mean(abs(data));
        sdbufdt(iti,:)=std(data);
        maxbufdt(iti,:)=max(data);

        for ii=1:nsensor 
            pp(:,outpardt,ii)=data(:,ii);
            pp(:,outparrms,ii)=posamprms(:,ii);
        end;

%        savepos([posdir '\' mytrial '.pos'],pp);
        savepos([posdir '\' mytrial],pp);


        %save([outname mytrial],'data');
    end;        %aa not empty
end;
