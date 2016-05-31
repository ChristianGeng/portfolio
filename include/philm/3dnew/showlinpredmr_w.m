function posdatout=showlinpredmr_w(rawdatall,posdatall);
%prediction of coordinates from raw signals with linear regression
%input amp and position data must be arranged as three-dimensional array,
%with sensor as third dimension
%version using robustfit and choice of models (e.g interaction or quadratic
%terms)
%version with overlapping windows

samplerate=200;

%mymodel='purequadratic';  %for x2fx
mymodel='linear';  %for x2fx

functionname='showlinpredm, Version 1.12.04';

%should be input arguments
%could also assume that position data contains amposampdt
velthr=300;      %detection of implausible velocities (mm/s assumed)
rmsthr=10;			%rms threshold

%parameters for overlapping window
winsize=400;
winshift=winsize/2;
%winshift=round(winsize/8);
maxdist=(winsize/2)+1;

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
	
	
	%velocity criterion
	
	tangl=tangvel>velthr;
	rmsl=rmsdat>rmsthr;
	
	nbadtang=sum(tangl);
	nbadrms=sum(rmsl);
	badvec=[tangl | rmsl];
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
	
%set up window details
wingo=1:winshift:ny;
winend=winsize:winshift:ny;
nwin=length(winend);
wingo=wingo(1:nwin);
%make sure all data used
%pending a more elegant solution, this is preferable to just lengthening
%the last window, as otherwise maxdist for the weight calculations will
%also need adjusting
if winend(end)~=ny
	winend=[winend ny];
	wingo=[wingo ny-winsize+1];
end;

nwin=length(winend);


winpos=(wingo+winend)/2;	%may need to be adjusted if a lot of invalid data
winvalid=zeros(nwin,1);	%count valid data in each window
	
	
vlistbase=vlist;

	%        hf=figure;        
	%compute the regression again for the final selection of data
	%(here, both positions and orientations are processed)
	for idim=1:ndimx
		myname=['Sensor ' int2str(mysensor) ' ' dimlistx(idim,:) ' ' dimunitx(idim,:)];
		disp(myname);
		y=alldatorg(1:ny,idim);
%		ny=length(y);		%ny defined above
		
		hatbuf=ones(ny,nwin);		
		X=x2fx(rawdat,mymodel);        

	for iwin=1:nwin
		vv=find(vlistbase>=wingo(iwin) & vlistbase<=winend(iwin));
	vlist=vlistbase(vv);
		winvalid(iwin)=length(vlist);

			if winvalid(iwin)<winsize/2
				disp('large proportion of missing data in window');
			end;
			
		yg=y(vlist);
		
		
		Xg=X(vlist,2:end);      %skip first column (constant term) as not needed by robustfit
		
		
%		nyg=length(yg);
		
		br=robustfit(Xg,yg);        
		
		
		
		yhat=X*br;
		hatbuf(:,iwin)=yhat;
%	keyboard;	
	end;
	
	%compute weighted prediction
	pbase=repmat((1:ny)',[1 nwin]);
	pcomp=repmat(winpos,[ny 1]);
	pdist=abs(pbase-pcomp);
	pdist(pdist>maxdist)=maxdist;
	pdist=1-pdist./maxdist;
	wsum=(sum(pdist'))';
	pdist=pdist./repmat(wsum,[1 nwin]);
	hatbufw=hatbuf.*pdist;
	
	yhat=(sum(hatbufw'))';
	
	
		
		ymark=y;
		ymark(badtrace)=NaN;    %show location of unreliable data in different colour
		figure;
		%            subplot(2,3,idim);
		hl=plot([y yhat ymark]);
		title(myname,'interpreter','none');
		legend(hl,str2mat('original','predicted','used'));
		grid on
		drawnow
		posdatnew(:,idim)=yhat;
		
%		            keyboard;
	end;
	
	
	%use this to document the processing
	% also trace of samples used in regression???
	
	finalres=eucdistn(posdatnew(:,1:3),alldatorg(:,1:3));
	
	
	%            delete(hf)    
	
	nansumend=sum(isnan(finalres));
	disp(['nans in new data ' int2str(nansumend)]);
	if nansumend
		keyboard;
	end;
	
	disp(['Final mean euclidean distance : ' num2str(mean(finalres))]);
	
%maybe only replace NaNs
	posdatnewall(:,Pin.px:Pin.pz,mysensor)=posdatnew(:,Px.px:Px.pz);
	[myphi,mytheta,myrad]=cart2sph(posdatnew(:,Px.ox),posdatnew(:,Px.oy),posdatnew(:,Px.oz));
	posdatnewall(:,Pin.phi:Pin.theta,mysensor)=[myphi mytheta]./deg2rad;
    end;        %sensor in use
    
    end;
if nargout posdatout=posdatnewall; end;
