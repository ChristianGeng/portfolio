function ag100cal
% AG100CAL Prepare autokal results for further processing.
% ag100cal
% ag100cal: Version 6.6.97
%
%   Description
%       Script started life as draft version of inaki plate calibration procedure for MIT system
%       i.e autocal data corresponds to measurements made at inaki positions
%       Normally this script should be run from a "meta" script
%       like inakimet.m, which in turn can arrange for input to be taken from a command file
%       If both voltge and measured x,y,(z) data are present the program simply sets up
%       an errormap in a MAT file for use by errorana, and terminates.
%       If only voltage data is present, the program calculates v2d lookup tables.
%
%   Syntax
%       Input:
%           AUTOKAL ascii output from mfa2txt.exe (arrangement see below)
%       Output:
%          1. Updated lookup tables, in file pointed to by variable v2dname
%          2. Error map: for each sensor list of true and measured positions
%             This can be used by the coordinate correction algorithm
%		        in emmaproc (errorana.m)
%               Stored in a MAT file with the same name as the input autokal text file
%		        Its arrangement is sensor number, true x/y, measured x/y
%	        3. For each sensor, table of measured voltages and distances for
%		        each of the Inaki positions. For use by the Kaburagi
%		        adaptive v2d algorithm. Stored in matrix v2dlist (don't confuse with v2dtable)
%		        Similar structure to errormap:
%		        Column 1, sensor number, cols 2-4 known distances,
%		        cols 5-7 measured voltages
%		        Creation/appending see errormap
%               ====following is irrelevant for ag100
%		The voltage offsets must also be available to an
%		adaptive v2d algorithm. These are stored in
%		matrix voltage_offsets (size maxsensor*ntrans)
%		This is created if it does not exist.
%		Note: the voltages in v2dlist have had the offset subtracted

%	It might just have been possible to incorporate this as an
%	additional option in emmaproc
%
    
philcom(0);

functionname='ag100cal: Version 6.6.97';
namestr=['<Start of Comment> ' functionname crlf];
%could maybe be placed in a fixed directory


v2dname='v2dtable.ema';
%
%initialization for lookup tables
a2dsteps=4096;
a2dnegfsd=0;
%voltage value negfsd is indexed 1 in the lookup table
a2doffset=1;


%initialization - mostly from emmaproc
ndim=3;
maxsensor=15;
ntrans=3;
%various definitions for transmitter location
%
%use these units internally
units='cm';
unitfac=1000;   %conversion autokal units to cm
%mit	r_cen=27.5;
r_cen=18.52717;      %32.090/2/cos(30)


%define transmitter coordinates
%work internally with mit arrangement, i.e order neck, forehead, chin
%Carstens arrangement is reverse i.e chin, forehead, neck
%see the transcol variable

pifac=2*pi./360;
transa=pifac*[0 120 240];
transx=r_cen*cos(transa);
transy=r_cen*sin(transa);
x_cen=0;y_cen=0;


%arrangement of autokal text file (output of mfa2text)
%Col 1: Running number (from 0)
%Col 2-4: Autokal x,y,z position
%Col. 5..n: 3 cols. per sensor, either voltage data or measured x,y,z data
% Number of columns is thus determined by number of sensors in use.
%Row 1..n_sensor: "ZEN" data (not used in this program)
%Row n_sensor+1 .. 2*nsensor: Estimated individual sensor offsets from nominal position in magazine
%                             Sensor 3 must be zero
%Normally the results of the field measurements should then follow
% in 2 blocks: first, voltage measurements; second, same measurements
% after conversion to x,y (z)  coordinates.


autokname=philinp('Autokal text file : ');
namestr=[namestr 'Autokal text file: ' autokname crlf];
eval (['load ' autokname]);
%file must be in current directory
varname=strtok(autokname,'.');

eval (['indat=' varname ';']);
[m,n]=size(indat);
%????? must be sorted out
[abint,abnoint,abscalar,abnoscalar]=abartdef;

nsensor=(n-4)./ndim;
autoksum=4;         %voltage values are actually the sum of 4 measurements
%        nsensor=abart ('Number of sensors in use',10,1,maxsensor,abint,abscalar);
%determine from autokal input file
sensorlist=1:nsensor;
%           nsensor=length(sensorlist);
disp ([int2str(nsensor) ' emma sensors in autokal file']);
namestr=[namestr 'No. of sensors in autokal file: ' int2str(nsensor) crlf];


hisensor=max(sensorlist);

ivpos=nsensor+nsensor+1;                %start of voltage data for v2d calculation

zendat=indat(1:nsensor,:);
offsetdat=indat((nsensor+1):(ivpos-1),2:3);
offsetdat=offsetdat./unitfac;

%set up base offsets
%magazines are mounted in autokal parallel to x-axis of
%coordinate system (vertical in the device);
%lowest number coil is closest to neck, i.e has largest x-coordinate
%each magazine has a constant y offset

baseoffx=[2 1 0 -1 -2]';
baseoffx=[baseoffx;baseoffx;baseoffx];
baseoffy=[0 0 0 0 0 2.5 2.5 2.5 2.5 2.5 -2.5 -2.5 -2.5 -2.5 -2.5]';
baseoffset=[baseoffx baseoffy];
sensoroffsets=baseoffset(1:nsensor,:);
disp (['Estimated sensor-specific offsets in ' units]);
disp (offsetdat);
dodos=philinp('Subtract sensor-specific offsets ? [N] ');
if isempty(dodos) dodos='N'; end;
namestr=[namestr 'Sensor-specific offsets subtracted: ' dodos crlf];
namestr=[namestr 'If subtracted, see variable sensoroffsets for values (rows=sensors, columns=x and y offset used)' crlf];
%sensor-specific offsets
%note signs!!!!
if upper(dodos)=='Y'
    sensoroffsets=sensoroffsets-offsetdat;
    disp ('offsets used');
    disp (sensoroffsets);
end;

%

alldat=indat(ivpos:m,:);

%find whether adc and xy data, normally both should be present
vv=find(alldat(:,1)==0);
xydone=length(vv)>1;
ipend=size(alldat,1);

if xydone
    ipvend=vv(2)-1;
    %check exactly same number of voltage and xy data????
else
    ipvend=ipend;
    radlim=abart ('Max. distance from centre (cm)',8,0.5,r_cen,abnoint,abscalar);
    namestr=[namestr 'Max. distance from centre used: ' num2str(radlim) crlf];
    
end;

voltagedat=alldat(vv(1):ipvend,5:n);
voltagedat=voltagedat./autoksum;
%z pos ignored
inakitruexy=alldat(vv(1):ipvend,2:3);
inakitruexy=inakitruexy./unitfac;

%       scan voltage values for suspicious data, e.g at fsd
%       could be done more precisely by using offset values in .cfg file
%
maxvoffset=100;
maybefsd=a2dsteps-maxvoffset;
voltagemax=max(voltagedat);
nvcol=size(voltagedat,2);
for ii=1:nvcol
    vv=find(voltagedat(:,ii)==voltagemax(ii));
    nvv=length(vv);
    disp ('voltage column, max value, n at max');
    disp ([ii voltagemax(ii) nvv]);
    if voltagemax(ii)>maybefsd
        myquestion=philinp('Delete these measurements? [N]');
        myquestion=upper(myquestion);
        if myquestion=='Y'
            disp('Deleting data'); %????comment???
            voltagedat(vv,ii)=ones(nvv,1)*NaN;
        end;
    end;
end;



if xydone
    xydat=alldat((ipvend+1):ipend,5:n);
    vweg=3:3:(nsensor*3);
    xydat(:,vweg)=[];
    xydat=xydat./unitfac;
    errormap=[];
    ip1=1;
    ipv1=1;
    for sloop=1:nsensor
        isensor=sensorlist(sloop);
        inakiist=xydat(:,[ip1 ip1+1]);
        m1=size(inakiist,1);
        svolt=voltagedat(:,ipv1:(ipv1+2));
        vnan=(sum(svolt'))';
        vv=find(~isnan(vnan));
        inakiist=inakiist(vv,:);
        m2=size(inakiist,1);
        disp (['Sensor, n before after elimination ' int2str(isensor) ' ' int2str(m1) ' ' int2str(m2)]);
        nvv=size(inakiist,1);
        
        postable=inakitruexy(vv,:);
        postable(:,1)=postable(:,1)+sensoroffsets(isensor,1);
        postable(:,2)=postable(:,2)+sensoroffsets(isensor,2);
        
        errormap=[errormap;[ones(nvv,1)*isensor postable inakiist]];
        ip1=ip1+2;
        ipv1=ipv1+3;
    end;
    
    %save error map in standard format
    
    namestr=[namestr '<End of Comment> ' functionname crlf];
    descriptor=str2mat('sensor_number','true_x','true_y','measured_x','measured_y');
    unit=str2mat('',units,units,units,units);
    comment=namestr;
    data=errormap;
    eval(['save ' varname ' data descriptor unit comment sensoroffsets']);
    
    return; %temporary, ignore rest
end;    %xy present

[m,n]=size(voltagedat);
ninaki=m;

%index matrix to the transmitter signals for each sensor
%maps from Carstens arrangement to MIT arrangement

transcol=[(3:3:n)' (2:3:n)' (1:3:n)'];

%======================================

%polynomial order used in predicting radius from voltage

polyord=1;
polyordx=0;	%for adjustment of predicted to measured distance
%

%=================================
%===========================


%set up access to lookup table.....
%%%%??????
%open disk file
fidv2d=fopen(v2dname,'w');%read and write .....??????
tableprecision='float';
tablebyte=4;

meanbufin=voltagedat;

%--------------------------------------
%     main loop thru sensors
%=======================================
% 1. Set up lookup table
% 2. Set up error map (table of true and measured positions)
exptab=zeros(nsensor,ndim);
raderr=zeros(nsensor,ndim);
raderrm=zeros(nsensor,ndim);

for sloop=1:nsensor
    isensor=sensorlist(sloop);
    %                disp ('===========');
    %		disp (['Sensor ' int2str(isensor)]);
    %                disp ('===========');
    vtable=meanbufin(:,transcol(isensor,:));
    %for multisensor magazines, rather than directly using
    %the inaki distances from the inaki table
    %it will be necessary to compute the distances to the
    %transmitters explicitly for each sensor, based on a table
    %of x and y offsets from the nominal inaki positions
    
    postable=inakitruexy;
    postable(:,1)=postable(:,1)+sensoroffsets(isensor,1);
    postable(:,2)=postable(:,2)+sensoroffsets(isensor,2);
    
    cendis=eucdist([postable zeros(ninaki,2)],[1 3 2 4]);
    vv=find(cendis<radlim);
    disp ('number of positions outside radius limit')
    disp (ninaki-length(vv));
    postable=postable(vv,:);
    vtable=vtable(vv,:);
    
    %eliminate voltages at fsd
    vnan=(sum(vtable'))';
    vv=find(~isnan(vnan));
    postable=postable(vv,:);
    vtable=vtable(vv,:);
    
    nvv=size (vtable,1);
    
    disp (['Measurements remaining after eliminating voltages at fsd: ' int2str(nvv)]);
    
    dtable=zeros(nvv,ntrans);
    for dorad=1:ntrans
        mtemp=[ones(nvv,1)*transx(dorad) ones(nvv,1)*transy(dorad)];
        %======================= indices to x1, x2, y1, y2 in temporary matrix
        dtable(:,dorad)=eucdist([postable mtemp],[1 3 2 4]);
    end;
    
    
    %for ag100 assume voltage offset already subtracted
    %vtable=vtable-(ones(nvv,1)*voffset);
    
    
    %for kaburagi adaptive calibration method vtable and dtable
    %must be stored, but also the offsets
    
    if exist('v2dlist')==0 v2dlist=[];end;
    v2dlist=[v2dlist;[ones(nvv,1)*isensor dtable vtable]];
    
    %voltage offset not available for AG100, except from cfg file
    %not relevant as automatically subtracted
    %              if exist('voltage_offsets')==0 voltage_offsets=zeros(maxsensor,ntrans);end;
    %              voltage_offsets(isensor,:)=voffset;
    
    
    %following voltages define the normal working range of emma
    %i.e normally up to radius of about 8cm from centre
    %they can be used for ensuring that measures of
    %goodness of fit,
    %are only based on the voltage
    %ranges that are likely to be encountered in practice
    
    minv=min(vtable);
    maxv=max(vtable);
    losig=max(minv);
    hisig=min(maxv);	%i.e most restricted range
    
    %	disp ('Min. voltages (0..4095) per transmitter')
    %	disp (minv);
    %	disp ('Max. voltages (0..4095) per transmitter')
    %	disp (maxv);
    
    
    %basic calibration works with log voltages and log distances
    vtablel=log(vtable);
    dtablel=log(dtable);
    %storage for polynomial coefficients for 2 stages of v2d procedure
    p=zeros(ntrans,polyord+1);
    px=zeros(ntrans,polyordx+1);
    
    %values required at these voltages (skip ad value 0)
    vl=[1 1:a2dsteps-1];
    vl=log(vl);
    
    lookup=zeros(a2dsteps,ntrans);
    for lt=1:ntrans
        %determine polynomial coefficients
        [p(lt,:),S]=polyfit(vtablel(:,lt),dtablel(:,lt),polyord);
        %		disp (['Transmitter ' int2str(lt)]);
        %might be worth doing this anyhow
        if polyord==1
            myexp=1./p(lt,1);
            exptab(sloop,lt)=myexp;
            %			disp (['Exponent : ' num2str(myexp)]);
        end;
        %set up table
        [yl delta]=polyval(p(lt,:),vl,S);
        %delta (confidence interval)
        %probably only interesting for welldefined voltage regions
        %what are the units? log (cm)?
        deltamean(lt)=mean(delta(losig:hisig));
        %disp (['Average delta for polynomial fit' num2str(deltamean(lt))]);
        
        %convert back from log
        
        ve=exp(yl);
        lookup(:,lt)=ve';
        
        %compare known and estimated distances at the measured voltages
        %rounding??
        vv=vtable(:,lt);
        lookupd=lookup(vv,lt);
        %disp ([lookupd dtable(:,lt)]);
        derror=mean(abs(lookupd-dtable(:,lt)));
        derrorm=max(abs(lookupd-dtable(:,lt)));
        %                disp (['Stage 1. Mean error (mm) : ' num2str(10*derror)]);
        raderr(sloop,lt)=derror;
        raderrm(sloop,lt)=derrorm;
        %
        
        if polyordx > 0
            %Second stage, predict measured distance from predicted (sic!) distance directly???
            %probably of marginal importance
            [px(lt,:),S]=polyfit(lookupd,dtable(:,lt),polyordx);
            %disp ('distance-distance coefficients')
            %disp (px(lt,:));
            [dnew delta]=polyval(px(lt,:),lookupd,S);
            derror=mean(abs(dnew-dtable(:,lt)));
            %                   disp (['Stage 2. Mean error (mm) : ' num2str(10*derror)]);
            % apply to whole table
            lookup (:,lt)=polyval(px(lt,:),lookup(:,lt));
            %
        end;    %skip 2nd stage
        
        %lookup table is now set up=================
        %
        %
        %set table at fsd to some arbitrary very large
        %distance so overloaded inputs will trigger bad data
        lookup(a2dsteps,lt)=lookup(1,lt);
        %
        %tables could be stored as distance squared....
        %
    end;
    %
    %end of loop thru transmitters
    %===============================================================
    
    
    %write to disk here
    %not yet activated, file position must be sorted out
    filepos=(isensor-1)*ntrans*a2dsteps*tablebyte;
    status=fseek (fidv2d,filepos,'bof');
    ncheck=a2dsteps*ntrans;
    count=fwrite (fidv2d,lookup,tableprecision);
    if count~=ncheck
        disp ('v2d table write incomplete ? ');
    end;
    
    %error??????
    
    
    %use lookup tables to compute measured positions
    %		vtest=vtable+(ones(nvv,1)*voffset);
    vtest=vtable;
    vtest=vtest+a2doffset;
    inakiist=zeros(nvv,2);
    for lc=1:nvv
        vv=vtest(lc,:);
        for jj=1:ntrans radii(jj)=lookup(vv(jj),jj); end;
        mypos=mit(radii);
        inakiist(lc,:)=mypos(1:2);
        %disp ('Tilt')
        %disp (mypos(3));
    end;
    %store in error map
    %viz. isensor, postable, inakimeasured
    if ~exist('errormap') errormap=[]; end;
    errormap=[errormap;[ones(nvv,1)*isensor postable inakiist]];
    
    %call script can call errorana to view errormap
    
    
end;
%================= end of loop thru sensors
disp ('exponents');
disp (exptab);
raderr=raderr.*10;
disp ('mean radial errors');
disp (raderr);
disp ('max radial errors');
disp (raderrm.*10);

status=fclose (fidv2d);

