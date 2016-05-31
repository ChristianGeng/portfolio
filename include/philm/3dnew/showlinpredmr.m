function posdatout=showlinpredmr(rawdatall,posdatall);
%prediction of coordinates from raw signals with linear regression
%input amp and position data must be arranged as three-dimensional array,
%with sensor as third dimension
%version using robustfit and interaction terms

samplerate=200;

mymodel='purequadratic';  %for x2fx
%mymodel='linear';  %for x2fx

functionname='showlinpredmr, Version 13.5.05';

velthr=200;      %detection of implausible velocities (mm/s assumed)
rmsthr=5;			%rms threshold


nsensin=12;
ntran=6;
dimlist=str2mat('px','py','pz','phi','theta','rms');
dimlistx=str2mat('px','py','pz','ox','oy','oz');	%processed parameters
dimunit=str2mat('mm','mm','mm','deg','deg','norm');
dimunitx=str2mat('mm','mm','mm','norm','norm','norm');
Pin=desc2struct(dimlist);
Px=desc2struct(dimlistx);

deg2rad=pi/180;

ndim=size(dimlist,1);

ndimx=size(dimlistx,1);    %posx,posy,posz, orix, oriy, oriz , i,e number of dimensions to process

posdatnewall=posdatall;

for mysensor=1:nsensin
	rawdat=rawdatall(:,:,mysensor);
    %zero record flags sensors not in use
    if any(rawdat(1,:))
	
	disp(['Sensor ' int2str(mysensor)]);
	rawdat=rawdatall(:,:,mysensor);
	posdat=posdatall(:,Pin.px:Pin.pz,mysensor);
	oridat=posdat;
	rmsdat=posdatall(:,Pin.rms,mysensor);
	tmpdat=posdatall(:,Pin.phi:Pin.theta,mysensor)*deg2rad;
	
	%convert orientation data to cartesian for processing
	[oridat(:,1),oridat(:,2),oridat(:,3)]=sph2cart(tmpdat(:,1),tmpdat(:,2),1);
%	keyboard;
	hfvel=figure;
	
	
	alldatorg=[posdat oridat];
	
	posdat=posdat(:,1:3);
	
	%use as further criterion for bad data
	tangvel=eucdistn(posdat(1:(end-1),1:3),posdat(2:end,1:3))*samplerate;
	tangvel=[tangvel;tangvel(end)];	%match original length
	figure(hfvel);
	subplot(2,1,1);
	plot(tangvel);
	ylim([0 velthr]);
	ylabel('mm/s');        
	title(['Tangential velocity, Sensor ' int2str(mysensor)]);
	subplot(2,1,2);
	plot(rmsdat);
	    ylim([0 rmsthr]);
	ylabel('rms');        
	title(['Residual, Sensor ' int2str(mysensor)]);
	drawnow
	%pause
	%delete(hfvel);
	
	ny=size(posdat,1);
	posdat=[posdat (1:ny)'];        %keep track of eliminated records
	
%NaNs already in input data

vnanin=isnan(posdat(:,1));
    
disp(['NaNs in input data ' int2str(sum(vnanin))]); 

	%velocity criterion
	
	tangl=tangvel>velthr;
	rmsl=rmsdat>rmsthr;
	
	nbadtang=sum(tangl);
	nbadrms=sum(rmsl);
	badvec=[tangl | rmsl];
    badvec=badvec|vnanin;
    vv=find(badvec);
	
	nbad=length(vv);
	
	disp(['Bad data (velocity, rms, total) : ' int2str([nbadtang nbadrms nbad])]);
	
	%propagate the indication of unreliable data slightly
	vv=[vv;vv+1;vv-1;vv+2;vv-2];
	vv=unique(vv);
	vvv=find(vv>0 & vv<=ny);
	vv=vv(vvv);
	
	posdat(vv,:)=NaN;
	
	
	
	
	vlist=find(~isnan(posdat(:,4)));      %final list of samples to use
	
	posdatnew=ones(ny,ndimx)*NaN;
	badtrace=ones(ny,1);
	badtrace(vlist)=0;
	badtrace=logical(badtrace);
	
	%        hf=figure;        
	%compute the regression again for the final selection of data
	%(here, both positions and orientations are processed)
	for idim=1:ndimx
		myname=['Sensor ' int2str(mysensor) ' ' dimlistx(idim,:) ' ' dimunitx(idim,:)];
		disp(myname);
		y=alldatorg(:,idim);
		
		
		yg=y(vlist);
		resultg=rawdat(vlist,:);
		
		ny=length(y);
		
		X=x2fx(rawdat,mymodel);        
		Xg=X(vlist,2:end);      %skip first column (constant term) as not needed by robustfit
		
		
		nyg=length(yg);
		
		br=robustfit(Xg,yg);        
		
		
		
		yhat=X*br;
		
		
		ymark=y;
		ymark(badtrace)=NaN;    %show location of unreliable data in different colour
		hf(idim)=figure;
		%            subplot(2,3,idim);
		hl=plot([y yhat ymark]);
		title(myname,'interpreter','none');
		legend(hl,str2mat('original','predicted','used'));
		grid on
		drawnow
		posdatnew(:,idim)=yhat;
		
		%            keyboard;
	end;
	
	
	%use this to document the processing
	% also trace of samples used in regression???
	
	finalres=eucdistn(posdatnew(:,1:3),alldatorg(:,1:3));
	
	
	%            delete(hf)    
	
	
	%disp(mean(finalres));
	
%maybe only replace NaNs
	posdatnewall(:,Pin.px:Pin.pz,mysensor)=posdatnew(:,Px.px:Px.pz);
	[myphi,mytheta,myrad]=cart2sph(posdatnew(:,Px.ox),posdatnew(:,Px.oy),posdatnew(:,Px.oz));
	posdatnewall(:,Pin.phi:Pin.theta,mysensor)=[myphi mytheta]./deg2rad;

    disp('hit any key for next sensor');
    pause;
    delete(hfvel);
    delete(hf);
    
    
    end;        %sensor in use
    end;
if nargout posdatout=posdatnewall; end;
