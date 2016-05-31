function [teststats,taxdistb,rmsdistb,nbad]=rigtestf(refsensor_spec,tstsensors,reftrial,tsttrial);
% RIGTESTF: Compare rigid body results for different sets of reference sensors
% function [teststats,taxdistb,nbad]=rigtestf(refsensor_spec,tstsensors,reftrial,tsttrial);
% rigtestf: Version 04.11.2012
%
%   Syntax
%       Input
%       refsensor_spec: cell array of m*2 arrays
%           each element in the cell array specifies a ref sensor setting
%           each setting consists of sensors to use in first column, and distance
%           for virtual sensor in the second column
%           0 means no virtual sensor is generated (i.e. no use made of sensor
%           orientation)
%       tstsensors: Sensors to which rigid body analysis will be applied.
%           Should be sensors that do not move independently of the ref
%           sensors in the test trial. Thus, after transformation they
%           should appear to be completely stationary
%       reftrial: Name of file of position data from which target position
%           of the ref sensors is taken (i.e. average over all samples in
%           trial), for example when subject is sitting still with a
%           neutral head position.
%       tsttrial: Name of file of position data containing movements that
%           are to be factored out of the test sensors using the reference
%           sensors.
%           For example, this could be a trial in which the subject
%           performs head movements while trying not to allow any
%           independent movement of sensors on lips, tongue etc.
%       Output   
%       teststats: Results of stability analysis arranged
%           testsensors, ref sensor setting, stats
%               stats standard deviation of distances from sensor mean
%               after transformation (after transformation the sensor
%               ideally should be motionless). (1) for cartesian
%               coordinates (2) for orientation coordinates, (3) and (4),
%               same for mean distances from mean
%       taxdistb: mean and sd (columns) of taxonomic distance for each ref set
%           (rows)
%       nbad: total samples where transformation was unsuccessful for each
%           ref set 
%       rmsdistb: breakdown over ref. sensors and ref. sets of distortion
%           in transformation (mean and std over samples)
%
%   Notes
%       As preliminary analysis the program prints out statistics on the
%       stability of distances between all pairs of reference sensors in
%       the first set.
%       So to get a complete breakdown it may be useful to always use all
%       available ref sensors as the first set specified in refsensor_spec


%maybe allow input args to specify range in ref and test trial

methodSpec='Procrustes';
ndig=4;
ndim=3;


nrset=length(refsensor_spec);

ntst=length(tstsensors);



reffile=reftrial;
[refdata,descriptor,unit,dimension,sensorsin]=loadpos_sph2cartm(reffile);

tstfile=tsttrial;
[tstdata,descriptor,unit,dimension,sensorsin]=loadpos_sph2cartm(tstfile);

ndat=size(tstdata,1);

%initialize result buffers

taxdistb=ones(nrset,2)*NaN; %mean and sd of taxonomic distance
nbad=zeros(nrset,1);    %number of samples where transformation failed

%to get a break down over ref sensors of transformation result
% will need a cell array as number of sensors can differ for each set of
% ref sensors
rmsdistb=cell(nrset,2); %means and std over ref sensors and ref set
nstat=4;
teststats=ones(ntst,nrset,nstat)*NaN;      %store statistics on stability of test sensors

statnames=str2mat('SD of distance from mean position (Cartesian)',...
    'SD of distance from mean position (Orientation)',...
    'Mean absolute distance from mean position (Cartesian)',...
    'Mean absolute distance from mean position (Orientation)');
    


%main loop thru ref sensor specifications
for ir=1:nrset
    disp(['Ref. set ' int2str(ir)]);
    
    refsensors=refsensor_spec{ir};

    disp(refsensors);
    vdspec=refsensors(:,2);

    nrefs=size(refsensors,1);

nref2=nrefs+sum(vdspec>0); %number of sensors seen by procrustes

    refsensors=refsensors(:,1);


    slists=sensorsin(refsensors,:);
    slists=strm2rv(slists,' ');

%average data from reference trial, to serve as target of transformation
    datax=squeeze(nanmean(refdata(:,1:6,refsensors)));

%data from ref sensors from test trial
    datat=tstdata(:,1:6,refsensors);


    if ir==1

        %preliminary analysis: stability of euclidean distances between all pairs of reference
        %sensors

        %allow this to be skipped (i.e just do when testing all available ref
        %sensors, but skip when analyzing a subset)

        %or: allow multiple ref sensor setting as input
        % only do this for first setting in list

        eucx=ones(nrefs,nrefs)*NaN;
        eucsd=ones(nrefs,nrefs)*NaN;
        for ii=1:nrefs
            dat1=datat(:,1:3,ii);
            for jj=1:nrefs
                dat2=datat(:,1:3,jj);
                euctmp=eucdistn(dat1,dat2);
                eucx(ii,jj)=nanmean(euctmp);
                eucsd(ii,jj)=nanstd(euctmp);
            end;
        end;
        disp('Euclidean distances (all pairs of ref. sensors)');
        disp(slists);
        disp('Cartesian mean');
        disp(eucx);
        disp('Cartesian sd');
        disp(eucsd);
        disp('Means by sensor of sds');
        disp(mean(eucsd));


        %repeat for orientation

        %this factor is only really appropriate for angles up to 60 deg
        %Relationship between euclidean distance of the vectors and angular
        %difference is basically linear up to eucdist of 1, corresponding to 60 deg.
        %(the theoretical maximum distance of 2 then corresponds to 180 deg.)
        orifac=60;
        eucx=ones(nrefs,nrefs)*NaN;
        eucsd=ones(nrefs,nrefs)*NaN;
        for ii=1:nrefs
            dat1=datat(:,4:6,ii);
            for jj=1:nrefs
                dat2=datat(:,4:6,jj);
                euctmp=eucdistn(dat1,dat2)*orifac;
                eucx(ii,jj)=nanmean(euctmp);
                eucsd(ii,jj)=nanstd(euctmp);
            end;
        end;
        disp(['Orientations x ' int2str(orifac)]);
        disp('Orientation mean');
        disp(eucx);
        disp('Orientation sd');
        disp(eucsd);
        disp('Means by sensor of sds');
        disp(mean(eucsd));

        keyboard;

    end;        %preliminary analysis

    %loop through testsensors
taxdistbuf=ones(ndat,1)*NaN;
rmsdistbuf=ones(ndat,nref2)*NaN;
hmatc=cell(ndat,1);

    for itst=1:ntst
        %    disp(ivd);
        tstsensor=tstsensors(itst);
        datatx=tstdata(:,1:6,tstsensor);


        %for storing transformed test sensor
        testc=ones(ndat,3)*NaN;
        testo=ones(ndat,3)*NaN;

        %really better completely outside test sensor loop (but see also setting up of X1 below)

        
        if itst==1
        data3=ones(nrefs,ndim)*NaN;
        data3v=ones(nrefs,ndim)*NaN;
        for ii=1:nrefs
            td=datax(1:3,ii);
            tv=datax(4:6,ii);
            %keyboard;
            data3v(ii,:)=td'+(tv*vdspec(ii))';
            data3(ii,:)=td';
        end;
        end;
        

        for idi=1:ndat

        if itst==1
            data3t=ones(nrefs,ndim)*NaN;
            data3vt=ones(nrefs,ndim)*NaN;

            %not very efficient if virtual distance zero for most ref sensors
            for ii=1:nrefs
                tdt=squeeze(datat(idi,1:3,ii));
                tvt=squeeze(datat(idi,4:6,ii));
                %keyboard;
                data3vt(ii,:)=tdt'+(tvt*vdspec(ii))';
                data3t(ii,:)=tdt';
            end;

            X1=[data3];
            X2=[data3t];
            vvv=find(vdspec>0);

            if ~isempty(vvv)
                X1=[X1;data3v(vvv,:)];
                X2=[X2;data3vt(vvv,:)];
            end;

%note: for a lot of test sensors it would be better to compute the
%transformations first for all samples outside the test sensor loop
            
            %note:
            %rege_h gets input as sensor*dimensions
            %but mulitplication with hmat afterwards needs the data transposed

            [hmat,taxdist]=rege_h(X1,X2,methodSpec);
            %        [H, X2dot, Deltasquare, Avtaxdist]=Rota_ini(X1,X2,methodSpec);

            hmatc{idi}=hmat;
            taxdistbuf(idi)=taxdist;
            %also store individual euclidean distances  so stability of each sensor after transformation can
            %be calculated
            X2dot=[X2';ones(1,nref2)];
            X2dot=(hmat*X2dot)';
            X2dot(:,end)=[];
            %keyboard;
            euctmp=eucdistn(X1,X2dot);
            rmsdistbuf(idi,:)=euctmp;

        end;
        
            
            
            %transform test sensor and store for stability analysis
            hmat=hmatc{idi};
            tmpc=datatx(idi,1:3);
            tmpo=datatx(idi,4:6);

            tmpc=hmat*[tmpc';1];
            tmpc(end)=[];

            testc(idi,:)=tmpc;

            tmpo=hmat(1:3,1:3)*tmpo';
            testo(idi,:)=tmpo;

        end;    %loop thru data points

%compute stability statistics for current test sensor
        xbartmp=mean(testc);
        euctmp=eucdistn(testc,repmat(xbartmp,[ndat 1]));
        teststats(itst,ir,1)=std(euctmp);
        teststats(itst,ir,3)=mean(euctmp);
        xbartmp=mean(testo);
        euctmp=eucdistn(testo,repmat(xbartmp,[ndat 1]));
        teststats(itst,ir,2)=std(euctmp)*orifac;
        teststats(itst,ir,4)=mean(euctmp)*orifac;

        plot(testc);
        title(['Sensor ' int2str(tstsensor) ', after transformation using ref set ' int2str(ir)]);
        xlabel('Time (samples)');
        ylabel('x/y/z coordinates');
        drawnow;




    end;        %loop thru test sensors

    %taxonomic distance stats for current ref sensor set
    
    vv=find(taxdistbuf==-1);
        taxdistbuf(vv)=NaN;
        nbad(ir)=length(vv);
        taxdistb(ir,:)=[nanmean(taxdistbuf) nanstd(taxdistbuf)];
        rmsdistb{ir,1}=nanmean(rmsdistbuf);
        rmsdistb{ir,2}=nanstd(rmsdistbuf);
        
        

end;        %loop through ref sensor settings

disp('Mean and SD of taxonomic distance for each set of reference sensors');
disp(taxdistb);


legtxt=cell(nrset,1);
for ii=1:nrset
    tmpr=refsensor_spec{ii};
    tmpt=['ref ' int2str(tmpr(:,1)') ' vd ' int2str(tmpr(:,2)')];
    legtxt{ii}=tmpt;
end;

for ifi=1:nstat
figure;
    hl=plot(tstsensors,teststats(:,:,ifi),'linewidth',2,'marker','o');
    
hleg=legend(hl,legtxt);

xlabel('Test sensor');
%work out units.....
title([deblank(statnames(ifi,:)) ' for ref trial ' reftrial ' , test trial ' tsttrial]);
end;



%keyboard;

