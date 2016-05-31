function mergebymeansqu(inpath1,inpath2,amppath,outpath,triallist,chanlist,filterspec)
% MERGEBYMEANSQU Merge two versions of AG500 position calculation
% function mergebymeansquare(inpath1,inpath2,amppath,outpath,triallist,chanlist,filterspec)
% mergebymeansqu: Version 8.10.08
%
%   Description
%       Merge two version of position calculation (e.g forward and reverse)
%       using mean square error (square of rms parameter) as weighting
%       scheme.
%       After merging, the data can be filtered (probably smoothed)
%       and then the rms parameter is recalculated for the new data
%
%   Syntax
%       inpath1/2: The path to the input position data (without backslash)
%       amppath: path to the amplitude data (needed for recalculating rms)
%       outpath: path for the output position data
%       triallist/chanlist: Vector of trials/channels to process
%       filterspec: m*2 cell array. In first column name of mat file with
%       filter coefficients for FIR filter
%       In second column, vector of channels to which the filter is to be
%       applied
%       Also outputs a mat file with a list of nans encountered in the
%       input
%
%   Notes
%       Orientations assumed to be in degrees
%       Factor 2500 hardcoded for rms calculations
%
%	Updates
%		store difference between positions as 'parameter 7'
%		store posamps
%
%   See Also
%       CALCAMPS tapadm function for getting amp data for calculated
%       position

functionname='mergebymeansqu: Version 8.10.08';


%rmsfac=1;
rmsfac=2500;
%orifac=1;       %ev pi/180 for degrees to rad
orifac=pi/180;

maxchan=12;


myver=version;

saveop='';
if myver(1)>='7' saveop='-v6'; end;


cofbuf=cell(maxchan,1);
filtername=cell(maxchan,1);
filtercomment=cell(maxchan,1);
filtern=zeros(maxchan,1);

nfrow=size(filterspec,1);

for ifi=1:nfrow
	tmpname=filterspec{ifi,1};
	fchan=filterspec{ifi,2};
	mycoffs=mymatin(tmpname,'data');
	mycomment=mymatin(tmpname,'comment');
	myn=length(mycoffs);
	nc=length(fchan);
	for ific=1:nc
		mychan=fchan(ific);
		cofbuf{mychan}=mycoffs;
		filtername{mychan}=tmpname;
		filtercomment{mychan}=mycomment;
		filtern(mychan)=myn;
	end;
end;

newcomment=['Input 1, Input 2, Amps, Output : ' inpath1 ' ' inpath2 ' ' amppath ' ' outpath crlf ...
	'First/last/n trials: ' int2str([triallist(1) triallist(end) length(triallist)]) crlf ...
	'Sensor list: ' int2str(chanlist) crlf];

myblanks=(blanks(maxchan))';
filtercomment=strcat(int2str((1:maxchan)'),' File: ',filtername,' " ',filtercomment,' ", ncof = ',int2str(filtern));
newcomment=[newcomment 'Filter specs for each channel:' crlf strm2rv(char(filtercomment),crlf) crlf];

nancntbuf=ones(max(triallist),maxchan,3)*NaN;
nanvec=cell(max(triallist),maxchan);

posamppath=[outpath pathchar 'posamps'];
mkdir(posamppath);

for itrial=triallist
	disp(itrial);
	ts=int2str0(itrial,4);

	inname=[inpath1 pathchar ts];
	outname=[outpath pathchar ts];
	posampfilename=[posamppath pathchar ts];
	matin=0;
	comment='';
	if exist([inname '.mat'])
		matin=1;
		copyfile([inname '.mat'],[outname '.mat']);
		comment=mymatin(inname,'comment');

	end;



	pp1=loadpos(inname);
	if ~isempty(pp1)

		comment=framecomment(comment,'Comment from first input file');
		comment=[newcomment comment];
		comment=framecomment(comment,functionname);

		pp2=loadpos([inpath2 pathchar ts]);
		aa=loadamp([amppath pathchar ts]);


		pout=ones(size(pp1))*NaN;
		posamps=ones(size(pp1,1),6,size(pp1,3))*NaN;

		for ich=chanlist
			pos1=pp1(:,1:3,ich);
			ori1=pp1(:,4:5,ich)*orifac;
			ms1=pp1(:,6,ich).^2;
			[ox1,oy1,oz1]=sph2cart(ori1(:,1),ori1(:,2),1);

			d1=[pos1 ox1 oy1 oz1];

			pos2=pp2(:,1:3,ich);
			ori2=pp2(:,4:5,ich)*orifac;
			ms2=pp2(:,6,ich).^2;
			[ox2,oy2,oz2]=sph2cart(ori2(:,1),ori2(:,2),1);

			d2=[pos2 ox2 oy2 oz2];
			%            disp('NaNs in input 1 and 2');


			vn1=isnan(d1(:,1));
			vn2=isnan(d2(:,1));
			vn12=vn1&vn2;
			vnot=~vn12;
			nancount=[sum(vn1) sum(vn2) sum(vn12)];
			nancntbuf(itrial,ich,:)=nancount;

			disp([itrial ich nancount]);
			dointerp=0;
			if any(nancount)
				disp(['Ch ' int2str(ich) ' NaNs in inputs 1, 2, both: ' int2str(nancount)]);
				%keyboard;
				if any(vn1)
					vv=find(vn1);
					d1(vv,:)=d2(vv,:);
					ms1(vv)=ms2(vv);
				end;
				if any(vn2)
					vv=find(vn2);
					d2(vv,:)=d1(vv,:);
					ms2(vv)=ms1(vv);
				end;

				%to replace nans in both, interpolate dout (below)
				if any(vn12)
					dointerp=1;
					vnans=find(vn12);
					vnotnans=find(vnot);
					nanvec{itrial,ich}=vnans;
				end;
			end;


			badweight=find((ms1+ms2)==0);

			ms1(badweight)=1;
			ms2(badweight)=1;

			w1=1-(ms1./(ms1+ms2));
			w2=1-(ms2./(ms1+ms2));

			dout=ones(size(d1))*NaN;
			np=size(d1,2);
			%keyboard;
			for ipi=1:np
				dout(:,ipi)=(d1(:,ipi).*w1) + (d2(:,ipi).*w2);
				nchk=find(~isnan(dout(:,ipi)));
				if any(vn12)
					if length(nchk)~=length(vnotnans)
						disp('unexpected nans');
						keyboard;
					end;
				end;


				if dointerp
					dout(vnans,ipi)=interp1(vnotnans,dout(vnotnans,ipi),vnans,'pchip','extrap');
				end;


				if filtern(ich)
					b=cofbuf{ich};
					dout(:,ipi)=decifir(b,dout(:,ipi));
				end;
			end;
			%         keyboard;
			%calculate posamps, rms and dt for merged data
			%            [pax,localpos,h]=sc_calclocalpos_tap(dout(:,1:3),dout(:,4:6));
			%            fab=calfac(ich,:);
			%
			%            fax=repmat(fab,[length(pax) 1]);
			%            pax=pax.*fax;



			pout(:,1:3,ich)=dout(:,1:3);
			oriout=ones(size(pout,1),2)*NaN;
			[oriout(:,1),oriout(:,2),dodo]=cart2sph(dout(:,4),dout(:,5),dout(:,6));

			pout(:,4:5,ich)=oriout/orifac;      %convert back to degrees if necessary
			pax=calcamps(pout(:,1:5,ich));

			%10.08 store position difference as parameter 7
			[pout(:,6,ich),pout(:,7,ich)]=posampana(aa(:,:,ich),pax,rmsfac);
			par7=eucdistn(pos1,pos2);
			pout(:,7,ich)=par7;
			posamps(:,:,ich)=pax;
		end;        %channel list

		%always output as mat file, but some variables will be missing if
		%input was not mat
		data=single(pout);
		if matin
			save(outname,'data','comment','-append',saveop);
			data=single(posamps);
			[descriptor,unit,dimension]=headervariables(1);
			dimensionpos=mymatin(inname,'dimension');
			samplerate=mymatin(inname,'samplerate');
			dimension.axis(3)=dimensionpos.axis(3);       %copy sensor names from first input pos file

			save(posampfilename,'data','samplerate','comment','descriptor','unit','dimension');

		else
			save(outname,'data','comment',saveop);
		end;



		%    savepos([outpath pathc ts '.pos'],pout);
	end;            %input not empty
end;                %trial list

save mergebymeansqu_nans nancntbuf nanvec
