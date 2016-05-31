function alignspl_tw(trialcutfile,refcutfile,outfile,recpath,audiochan)
% ALIGNSPL_TW Align spl contours and adjust seg boundaries with time-warping
% function alignspl_tw(trialcutfile,refcutfile,outfile,recpath,audiochan)
% alignspl_tw: Version 10.3.06
%
%   Description
%       Aligns audio signals using cross-correlation between SPL contours,
%       then fine tunes alignment with dynamic time-warping
%       Result is used to adjust segment boundaries of reference items to
%       match additional repetitions
%       Dynamic timewarping functions from Dan Ellis <dpwe@ee.columbia.edu>
%
%   See Also SIMMX, DP for dynamic timewarping

functionname='alignspl_tw: Version 10.3.06';

ikanal=1;       %audio channel
if nargin>4 ikanal=audiochan; end;

wavpath=recpath;


%should be input argument
labselect=1:5;      %columns of label to define categories (target words)
refdatab=mymatin(refcutfile,'data');
reflabelb=mymatin(refcutfile,'label');

trialdata=mymatin(trialcutfile,'data');
triallabel=mymatin(trialcutfile,'label');

ndig=length(int2str(max(trialdata(:,4))));


ulist=unique(refdatab(:,4));    %trial numbers of reference trials
nu=size(ulist,1);

newcut=[];
newlabel='';

%spectral analysis for dynamic timewarping
%nfft may need to depend on samplerate
nfft=512;
mywindow=blackman(nfft);
noverlap=round(nfft*0.75);

%parameters for kaiser window filtering of SPL contour (probably not too
%critical)
kwfc=80;        %cutoff frequency
kwalpha=50;     %damping in dB

for iu=1:nu
%for iu=4:4
    reftrial=ulist(iu);
%    disp(ulist(iu,:));
    vv=find(trialdata(:,4)==reftrial);
    typelabel=triallabel(vv,labselect);
    disp(typelabel);   

    vv=strmatch(typelabel,triallabel);
    mylist=trialdata(vv,4);
    mylabellist=triallabel(vv,:);
    vv=find(mylist==reftrial);
    reftriallabel=deblank(mylabellist(vv,:));
    mylist(vv)=[];
    mylabellist(vv,:)=[];

    nf=length(mylist);
    
    y1=double(mymatin([wavpath int2str0(reftrial,ndig)],'data'));
    y1=y1(:,ikanal);
    sf=mymatin([wavpath int2str0(reftrial,ndig)],'samplerate');
    
    %filter for smoothing spl contour
    [w,docstr]=kaiserdw(kwfc,kwalpha,sf);
    
    vv=find(refdatab(:,4)==reftrial);
    refcut=refdatab(vv,:);
    reflabel=reflabelb(vv,:);
    
    
    newcut=[newcut;refcut];
    newlabel=strvcat(newlabel,reflabel);
    
    
    y1f=sqrt(decifir(w,y1.^2));
    
    for ii=1:nf
        currenttriallabel=deblank(mylabellist(ii,:));
        disp(ii);
        mytrial=mylist(ii);
        y2=double(mymatin([wavpath int2str0(mytrial,ndig)],'data'));
        y2=y2(:,ikanal);        
        y2f=sqrt(decifir(w,y2.^2));
        hf=figure;
        hax1=subplot(2,1,1);
        %keyboard;
        hl(1)=plot(y1f,'g');
    hold on
        hl(2)=plot(y2f,'m');
    drawnow;
        [c,lags]=xcorr(y1f,y2f);
        [dodo,maxp]=max(c);
        myshift=lags(maxp);
        if myshift==0 myshift=1; end;
        
        myshift_t=myshift/sf;
        disp(myshift);
        
        if myshift<0
            y2fs=y2f(abs(myshift):end);
            compwav=y2(abs(myshift):end);
            refwav=y1;
            segstart=0;
        else
            y2fs=[zeros(myshift,1);y2f];
            compwav=y2;
            refwav=y1(myshift:end);
            segstart=myshift_t;            
        end;
        
        refcutx=refcut;
        refcutx(:,1:2)=refcutx(:,1:2)-segstart;
        
        
        
        %        pause
%        hold on
        delete(hl(2));
        hl(2)=plot(y2fs,'r');
    drawnow;
        %        pause;
        
%        close all
        
    hax2=subplot(2,1,2);
plot(refwav,'g');
        hold on
        plot(compwav,'r');
        drawnow;
        disp('starting time warp')
        %do timewarping
        % Calculate STFT features for both sounds (25% window overlap)[
        [D1,flist,tlist1] = specgram(refwav,nfft,sf,mywindow,noverlap);
        [D2,flist,tlist2] = specgram(compwav,nfft,sf,mywindow,noverlap);
        
        winlen2=(length(mywindow)/sf)/2;
        tlist1=tlist1+winlen2;
        tlist2=tlist2+winlen2;
        
        % Construct the 'local match' scores matrix as the cosine distance 
        % between the STFT magnitudes
        SM = simmx(abs(D1),abs(D2));
        
        % Use dynamic programming to find the lowest-cost path between the 
        % opposite corners of the cost matrix
        % Note that we use 1-SM because dp will find the *lowest* total cost
        
        [p,q,C] = dp(1-SM);
        
        disp('end time warp')
        
        % Calculate the frames in D2 that are indicated to match each frame
        % in D1, so we can resynthesize a warped, aligned version
        D2i1 = zeros(1, size(D1,2));
        for i = 1:length(D2i1); D2i1(i) = q(min(find(p >= i))); end
        
        tlistc=tlist2(D2i1);
        
        compcutx=interp1(tlist1,tlistc,refcutx(:,1:2));
        
        ncut=size(compcutx,1);
        
        tmpdata=compcutx+segstart-myshift_t;
        typeoffset=0;
        tstmode=0;
%test mode probably no longer works !!!
        if tstmode
            typeoffset=10;
            
            %for testing. Compare with segmented data
            %and include in output file
            vv=find(data(:,4)==mylist(ii));
            compcut=data(vv,:);
            complabel=label(vv,:);
            
            newcut=[newcut;compcut];
            newlabel=str2mat(newlabel,complabel);
            
            
            if size(compcut,1)==ncut
                disp('differences');
                disp((tmpdata-compcut(:,1:2))*1000);
            else
                disp('no comparison possible');
            end;
            
        end;
        
        tmpdata=[tmpdata refcutx(:,3)+typeoffset ones(ncut,1)*mytrial];
        tmplabel=reflabel;
        %may need to replace rep number???
        tmplabel=cellstr(tmplabel);
%keyboard;
        
        tmplabel=strrep(tmplabel,reftriallabel,currenttriallabel);
        tmplabel=char(tmplabel);
        
        newcut=[newcut;tmpdata];
        newlabel=strvcat(newlabel,tmplabel);
        
        
        %        keyboard;
        close all
        
    end;        %loop through reps
    
end;    %main loop through word types

load(refcutfile);


data=newcut;
label=newlabel;

comment=framecomment(comment,functionname);


save(outfile,'data','label','comment','descriptor','unit','cut_type_label','cut_type_value');
