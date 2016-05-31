function outstats=kalman_fb(basepath,kalmansuffix,triallist,chanlist,startpos)
% KALMAN_FB Kalman position calculation (forwards/backwards)
% function outstats=kalman_fb(basepath,kalmansuffix,triallist,chanlist,startpos)
% kalman_fb: Version 9.1.09
%
%	Description
%		Run kalman amp2pos forwards-backwards-forwards
%			Store these variants, and also mean of backwards and 2nd
%			forwards
%		startpos: Optional, specify as for tapad

functionname='kalman_fb_bs amp2pos: Version 2.3.09';

maxchan=12;
orifac=pi/180;
ndig=4;
rmsfac=2500;


private.kalman_fb=[];

amppath=[basepath pathchar];

kalmanpath=[amppath 'kalman' kalmansuffix pathchar ];

amppath=[amppath 'amps' pathchar];

startname='start4kalman.pos';
iniposdir='inipos';
iniext='.ini';
userstart=0;

mkdir([kalmanpath 'amps']);

%no verbose output if optimization start position method is used
verboseswitch='';
initswitch='';
%user-defined start position
if nargin>4
    mkdir(iniposdir);
    ss=ones(1,7,12)*NaN;
    ss(1,1:5,:)=(startpos(:,1:5))';
    savepos(startname,ss);
    userstart=1;
    verboseswitch=' -v ';
    initswitch=[' --initdir ' iniposdir ' '];
    private.kalman_fb.startpos=startpos;
end;

ignoreswitch='';
ignorechan=setdiff(1:maxchan,chanlist);
if ~isempty(ignorechan)
    ignoreswitch=strm2rv(int2str(ignorechan'),',');
    ignoreswitch(end)=' ';
    ignoreswitch=[' -i ' ignoreswitch];
end;


kalmanpospath=[kalmanpath 'workpos'];	%raw forwards backwards forwards
kalmanpathf0=[kalmanpath 'rawposf0'];		%mat forwards (1)
kalmanpathf=[kalmanpath 'rawposf'];		%mat forwards (2)
kalmanpathb=[kalmanpath 'rawposb'];		%mat backwards
kalmanpathm=[kalmanpath 'rawposm'];		%mat merged forwards/backwards

mkdir(kalmanpospath);
mkdir(kalmanpathf0);
mkdir(kalmanpathf);
mkdir(kalmanpathb);
mkdir(kalmanpathm);


%store some stats on rms for different solutions (and distance between
%forwards-backwards

outstats=ones(max(triallist),maxchan,4)*NaN;

%optimization for tapad
options='-l';   %fix to levenberg-marquardt
lsq_options = optimset('lsqnonlin');
        if (~isempty(findstr('-l', options)))	% 	select method		
            %next line must be wrong!!
            %	if (~isempty(findstr('-f', options)))	% 	select method		
            lsq_options = optimset(lsq_options, 'Display', 'off', 'LargeScale', 'off', 'LevenbergMarquardt', 'on', 'TolX', 1E-8, 'TolFun', 1E-8, 'MaxIter', 1000);
        else
            lsq_options = optimset(lsq_options, 'Display', 'off', 'LargeScale', 'on', 'LevenbergMarquardt', 'off', 'TolX', 1E-4, 'TolFun', 1E-6, 'MaxFunEvals', 2000);
        end




for itrial=triallist
    
    
    
    disp(itrial);
    trials=int2str0(itrial,ndig);
    ampdata=mymatin([amppath trials],'data');
    samplerate=mymatin([amppath trials],'samplerate');
    dimensionamp=mymatin([amppath trials],'dimension');
    basecomment=mymatin([amppath trials],'comment');
    
    [descriptor,unit,dimension]=headervariables;
    dimension.axis(3)=dimensionamp.axis(3);       %copy sensor names from amp file
    
    kalmanampfile=[kalmanpath 'amps' pathchar trials '.amp'];
    
    ndat=size(ampdata,1);
    
    resultbs=ones(ndat,7,maxchan)*NaN;
    tapadstart=ones(maxchan,7)*NaN;
    tapadstartindex=zeros(maxchan);
    derivtmp=ones(1,6);
    Residuals=ones(maxchan,6);
    Iterations=ones(maxchan,1);

    for ichan=chanlist
        %look for beststart reasonably near middle of sequence
        ibegin=round(0.25*ndat);
        iend=round(0.75*ndat);
        tmpamp=ampdata(:,:,ichan);
        [dodo,tmpdif]=gradient(tmpamp);
        mybs=findbeststart(tmpamp,tmpdif,1);      %dummy channel
        mybs=ibegin+mybs-1;
        tapadstartindex(ichan)=mybs;
        
        [tapadstart(ichan,:), Residuals(ichan,:), Iterations(ichan)] = calcpos(ampdata(mybs,:,ichan), derivtmp, startpos(ichan,:), lsq_options);
        %check result ok (rms?)
        %store tapadresult as start position
        
        
        saveamp(kalmanampfile,ampdata(mybs:end,:,:));
        
        ss=ones(1,7,12)*NaN;
        ss(1,1:5,ichan)=(tapadstart(ichan,1c:5))';
        savepos(startname,ss);
        
        copyfile(startname,[iniposdir pathchar trials iniext]);
        ignorechan=setdiff(1:maxchan,ichan);
        ignoreswitch=strm2rv(int2str(ignorechan'),',');
        ignoreswitch(end)=' ';
        ignoreswitch=[' -i ' ignoreswitch];
        
        
        
        kalmans=['./amp2pos -s ' ignoreswitch verboseswitch initswitch ' -d ' kalmanpospath ' ' kalmanampfile];
        
        disp(kalmans);
        [status,result]=system(kalmans);
        disp([int2str(status) ' ' result]);
        
        %load result
        
        tmppos=LoadPos([kalmanpospath pathchar trials]);
        resultbs(mybs:ndat,:,:)=tmppos; 
        
        
        
        %repeat procedure from beststart back to beginning
        saveamp(kalmanampfile,ampdata(mybs:-1:1,:,:));
        
        kalmans=['./amp2pos -s ' ignoreswitch verboseswitch initswitch ' -d ' kalmanpospath ' ' kalmanampfile];
        
        disp(kalmans);
        [status,result]=system(kalmans);
        disp([int2str(status) ' ' result]);
        
        tmppos=LoadPos([kalmanpospath pathchar trials]);
        resultbs(mybs:-1:1,:,:)=tmppos; 
        
    end;
    
    saveamp(kalmanampfile,ampdata);
    %store 1st sample as start position
    ss=ones(1,7,maxchan)*NaN;
    ss(1,1:5,:)=resultbs(1,1:5,:);
    savepos(startname,ss);
    
    copyfile(startname,[iniposdir pathchar trials iniext]);
    ignorechan=setdiff(1:maxchan,chanlist);
    ignoreswitch=strm2rv(int2str(ignorechan'),',');
    ignoreswitch(end)=' ';
    ignoreswitch=[' -i ' ignoreswitch];
    
    kalmans=['./amp2pos -s ' ignoreswitch verboseswitch initswitch ' -d ' kalmanpospath ' ' kalmanampfile];
    
    disp(kalmans);
    [status,result]=system(kalmans);
    disp([int2str(status) ' ' result]);
    
    tmpposf=LoadPos([kalmanpospath pathchar trials]);
    
    %store amps in reverse
    saveamp(kalmanampfile,ampdata(ndat:-1:1,:,:));
    %store last sample as start position
    ss=ones(1,7,maxchan)*NaN;
    ss(1,1:5,:)=resultbs(end,1:5,:);
    savepos(startname,ss);
    
    copyfile(startname,[iniposdir pathchar trials iniext]);
    kalmans=['./amp2pos -s ' ignoreswitch verboseswitch initswitch ' -d ' kalmanpospath ' ' kalmanampfile];
    
    disp(kalmans);
    [status,result]=system(kalmans);
    disp([int2str(status) ' ' result]);
    
    tmpposb=LoadPos([kalmanpospath pathchar trials]);
    
    
    
    
    
    %only result from last call
    comment=[kalmans crlf int2str(status) ' ' result crlf basecomment];
    
    comment=framecomment(comment,functionname);
    
    
    %save beststart pass as first version
    data=single(resultbs);
    
    
    %save as mat file with standard variables
    save([kalmanpathf0 pathchar trials],'data','descriptor','dimension','samplerate','comment','unit','private');
    
    %backward calculation
    data=flipdim(tmpposb,1);
    datab=data;
    data=single(data);
    
    
    %save as mat file with standard variables
    save([kalmanpathb pathchar trials],'data','descriptor','dimension','samplerate','comment','unit','private');
    
    %forward calculation
    data=tmpposf;
    dataf=data;
    data=single(data);
    
    
    %save as mat file with standard variables
    save([kalmanpathf pathchar trials],'data','descriptor','dimension','samplerate','comment','unit','private');
    
    %calculate merged solution
    nchan=size(data,3);
    
    data=ones(size(data))*NaN;
    
    for ich=chanlist
        %use loadpos_sph2cartm?????
        %to average the forward and backward solution first convert the spherical
        %coorinates to unit vector
        pos1=dataf(:,1:3,ich);
        ori1=dataf(:,4:5,ich)*orifac;
        [ox1,oy1,oz1]=sph2cart(ori1(:,1),ori1(:,2),1);
        
        d1=[pos1 ox1 oy1 oz1];
        
        pos2=datab(:,1:3,ich);
        ori2=datab(:,4:5,ich)*orifac;
        [ox2,oy2,oz2]=sph2cart(ori2(:,1),ori2(:,2),1);
        
        d2=[pos2 ox2 oy2 oz2];
        
        dm=(d1+d2)/2;
        
        oriout=ones(size(dm,1),2)*NaN;
        %convert orientation information back to spherical coordinates
        [oriout(:,1),oriout(:,2),dodo]=cart2sph(dm(:,4),dm(:,5),dm(:,6));
        
        dm=[dm(:,1:3) oriout/orifac];
        %get posamps and rms for composite solution
        pax=calcamps(dm);
        
        [newrms,par7tmp]=posampana(ampdata(:,:,ich),pax,rmsfac);
        %compute distance between forwards and backwards as "parameter 7"
        par7=eucdistn(pos1,pos2);
        data(:,:,ich)=[dm newrms par7];
        outstats(itrial,ich,:)=mean([dataf(:,6,ich) datab(:,6,ich) newrms par7]);
        %    keyboard;
    end;
    
    disp(squeeze(outstats(itrial,:,:)));
    %save as mat file with standard variables
    data=single(data);
    save([kalmanpathm pathchar trials],'data','descriptor','dimension','samplerate','comment','unit','private');
    
end;
