function [statusb,resultc]=calcpos4mat(calcpospath,rawpath,triallist);
% CALCPOS4MAT Run calcpos binary from matlab for AG500 position calculation
% function [statusb,resultc]=calcpos4mat(calcpospath,rawpath,triallist);
% calcpos4mat: Version 28.09.2010
%
%	Syntax
%		calcpospath: Location of the calcposcmd binary (without last
%			pathchar)
%			Normally in a directory named age/bin
%			Example of complete specification:
%			'/raid/tera21/Phil/calcpostst/age/bin';
%			If location of binary is known to system then can be left empty
%			(not yet tested)
%		rawpath: Location of the directory containing the amp subdirectory
%			with the input data. Specify without last pathchar
%			The output position data will be stored below rawpath in rawpos
%		statusb: Status flag of call to calcpos for each trial (length
%			equal to max(triallist)
%			If not zero, processing was unsuccessful
%			Details are given in corresponding element of resultc
%		resultc: Cell array, same arrangement as statusb
%			Contains further information if processing was unsuccessful
%			(corresponds to terminal output of calcposcmd)
%			Note: cpcmd.log should contain the calcposcmd terminal output
%			for the last trial processed.

functionname='calcpos4mat: Version 28.09.2010';


exename='calcposcmd ';
calcstr=exename;
if ~isempty(calcpospath)
	calcstr=[calcpospath pathchar exename];
end;


%mypath='ampsfiltraw/';
mypath=[rawpath pathchar];

ndig=4;
nsensor=12;
statsbuf=ones(nsensor,7)*NaN;
maxtrial=max(triallist);
statusb=zeros(maxtrial,1);
resultc=cell(maxtrial,1);

for ii=triallist
	disp(ii)
	trials=int2str0(ii,ndig);
	myname=[mypath 'amps' pathchar trials '.amp'];
	if exist(myname,'file')
		comstr=[calcstr myname];
		[statusb(ii),result]=system(comstr);

		if statusb(ii)
			disp('Error in calcpos?');
			resultc{ii}=result;
			%	keyboard;
		else

			data=loadpos([mypath 'rawpos' pathchar trials]);

			if isempty(data)
				%should probably not happen, if calcpos has not returned an error condition
				disp('pos file not found?');
				keyboard;
				statusb(ii)=1;
				resultc{ii}='Pos file not found?';
			else

				statsbuf=statsbuf*NaN;
				for jj=1:nsensor
					statsbuf(jj,:)=mean(data(:,:,jj));
				end;

				disp(round(statsbuf));
			end;

		end;

	else
		statusb(ii)=1;
		resultc{ii}='Amp file missing?';
	end;

end;

if any(statusb)
	disp('errors in calcpos');
	disp('Inspect statusb and resultc for details');
end;
