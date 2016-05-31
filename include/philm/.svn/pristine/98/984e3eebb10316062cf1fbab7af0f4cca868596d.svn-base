% MEANCOD Means of coded data
% (Probably obsolete)
%
% first version
% assume codes run from 0
% matrices anabuf, parametername and parameterlabel must be present
% check size of parametername/label matches anabuf columns

%flag values for abart
abint=1;
abnoint=0;
abscalar=1;
abnoscalar=0;
[maxrow,maxcol]=size(anabuf);
%xmiss=?????
ncod=abart ('Number of code parameters',2,1,maxcol,abint,abscalar);
parvec=abart ('Parameter vector',1,1,maxcol,abint,abnoscalar);
%display parameters selected
totprod=1;
for ll=1:ncod
    disp (['Code ' int2str(ll)]);
    codepos=0;
    while codepos==0
        codename=philinp('Code name : ');
        codepos=getstrin(codename,parametername);
    end;
    codcol(ll)=codepos;
    disp (['Code found at parameter ' int2str(codepos)]);
    %could be done automatically from max and min of column
    %and histogram to find nonzero bins
    c1=anabuf (:,codcol(ll));
    vv=find (c1~=xmiss);
    c1=c1(vv);
    minc=min(c1);maxc=max(c1);
    disp('Min:max, histogram, labels');
    disp (minc:maxc);
    [h,xx]=hist(c1,minc:maxc);
    disp (h);
    disp (strtok(parameterlabel(codcol(ll),:)));
    %expand to explicit choice
    codval(ll)=abart('Maximum code value',maxc,0,maxrow-1,abint,abscalar);
    codprod(ll)=totprod;
    totprod=totprod*(codval(ll)+1);
    %disp (totprod)
end
%generate a matrix with all code combinations
codmat=zeros(totprod,ncod);
labelmat=setstr(zeros(totprod,ncod));
for ll=1:ncod
    elrep=codprod(ll);
    seqrep=totprod./((codval(ll)+1)*elrep);
    block=ones(elrep,1)*[0:codval(ll)];
    bigb=[];
    for jj=1:seqrep bigb=[bigb block]; end
    codmat(:,ll)=bigb(:);
    labellist=parameterlabel(codcol(ll),1:codval(ll)+1);
    block=ones(elrep,1)*labellist;
    bigb=[];
    for jj=1:seqrep bigb=[bigb block]; end
    labelmat(:,ll)=bigb(:);
end
labelmat=setstr(labelmat);

%nmissing, nvalid, mean, median, std, max, min, 
nstat=7;
vv=codcol(1:ncod);
datacod=anabuf(:,vv);
%outer loop thru parameters
for pp=1:length(parvec)
    ipar=parvec(pp);
    disp (['Parameter ' int2str(ipar)]);
    disp (strtok(parametername(ipar,:)));
    d1=anabuf(:,ipar);
    %actual calculation loop thru totprod code combinations
    statb=ones(totprod,nstat)*xmiss;
    for ll=1:totprod
        curcod=codmat(ll,:);
        curcod=ones(maxrow,1)*curcod;
        testm=curcod==datacod;
        %testm must be transposed as all works columnwise
        vv=find (all(testm'));
        d2=d1(vv);
        ntot=length(vv);
        %disp (['Total data ' int2str(ntot)]);
        vv=find(d2~=xmiss);
        d2=d2(vv);
        nvalid=length(vv);
        %use eval for desired stats functions
        statb(ll,1)=ntot-nvalid;	%nmissing
        statb(ll,2)=nvalid;
        statb(ll,3)=mean(d2);
        statb(ll,4)=median(d2);
        statb(ll,5)=std(d2);
        statb(ll,6)=max(d2);
        statb(ll,7)=min(d2);
    end			%loop thru codes
    
    codelist='';
    for pp=1:ncod codelist=[codelist strtok(parametername(codcol(pp),:)) ' ']; end
    codelist=[codelist 'nmiss nvalid mean median std max min']; 
    disp (codelist);
    %	disp (labelmat);
    %	disp ([codmat statb]);
    %sprintf('%2.0f%2.0f%2.0f%2.0f%3.0f%5.0f%8.4f%8.4f\n',[codmat statb]')	
    for ll=1:totprod
        ss=sprintf('%s%5.0f%5.0f%8.4f%8.4f%8.4f%8.4f%8.4f%8.4f%8.4f',labelmat(ll,:),statb(ll,:));
        disp (ss);
    end
    
end			%loop thru parameters						