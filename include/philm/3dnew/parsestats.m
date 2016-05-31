function sout=parsestats(myfile)
% PARSESTATS Make summary of stats from do_comppos_a (for ampvsposampa)
% function parsestats(myfile)
% parsestats: Version 1.4.09
%
%   See also
%       doampvsposampa do_comppos_a_f

maxsensor=12;
%rounding: rms, tangvel, eucdist (high and low), p7
%could be input argument??
roundspec=[1 10 0.5 0.1];

rmsbuf=ones(1,maxsensor)*NaN;
tangbuf=rmsbuf;
euclob=rmsbuf;
euchib=rmsbuf;
p7buf=rmsbuf;

%myfile='comppos_stats_dsadjabeststartl2nose.txt';
ss=file2str(myfile);
vv1=strmatch('Sensor',ss);
vv2=strmatch('Suggested',ss);

ns=length(vv2);
for isi=1:ns
	datok=0;
	tmps=ss(vv2(isi),:);
	ipi=findstr('|',tmps);
	if length(ipi)==1
		tmps=tmps((ipi+1):end);
		ipi=findstr('(',tmps);
		if length(ipi)==1
			varname=tmps(1:(ipi-1));
			tmps=tmps((ipi+1):end);
			ipi=findstr(')',tmps);
			if length(ipi)==1
				mychan=str2num(tmps(1:(ipi-1)));
				tmps=tmps((ipi+1):end);
				ipi=findstr(':',tmps);
				if length(ipi)==1
					tmpdat=str2num(tmps((ipi+1):end));
					datok=1;
				end;
			end;
		end;
	end;
if datok
	if strcmp('rms',varname)
		mydat=ceil(tmpdat(2)/roundspec(1))*roundspec(1);
		if ~isnan(rmsbuf(mychan))
			disp(['more than one analysis for channel ' int2str(mychan) ' ??']);
		else
			rmsbuf(mychan)=mydat;
		end;
	end;
	
	if strcmp('tangential velocity',varname)
		mydat=ceil(tmpdat(2)/roundspec(2))*roundspec(2);
			tangbuf(mychan)=mydat;
	end;
	if strcmp('parameter 7',varname)
		mydat=ceil(tmpdat(2)/roundspec(4))*roundspec(4);
			p7buf(mychan)=mydat;
	end;
	if strcmp('euclidean distance',varname)
		mydatx(2)=ceil(tmpdat(2)/roundspec(3))*roundspec(3);
		mydatx(1)=floor(tmpdat(1)/roundspec(3))*roundspec(3);
		if all(mydatx==0) mydatx=mydatx*NaN; end;
		euchib(mychan)=mydatx(2);
			euclob(mychan)=mydatx(1);
	end;
	
end;


end;






vv=[vv1;vv2];
vv=sort(vv);
ss=ss(vv,:);
%this suppresses parameter 7
%ss(5:5:end,:)=[];
disp(ss);

if nargout sout=ss; end;

disp(['rmsthreshb  = [  ' num2str(rmsbuf,'%6d') '];']);
disp(['velthreshb  = [ ' num2str(tangbuf,'%6d') '];']);
disp(['parameter7b = [ ' num2str(p7buf,'%6.1f') '];']);
disp(['lolimb =      [' num2str(euclob,'%6.1f') '];']);
disp(['hilimb =      [' num2str(euchib,'%6.1f') '];']);
