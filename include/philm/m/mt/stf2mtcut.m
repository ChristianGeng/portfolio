function stf2mtcut(cutname,trialtype)
% STF2MTCUT Convert stf (or REC) style cut files to mt style
% function stf2mtcut(cutname,trialtype)
% stf2mtcut Version 29.9.98
%
% Syntax
%    cutname: Input segment file name (MAT file), without extension
%			output file will have '_t' appended to the name
%    trialtype: (Optional) Segment type of segments delimiting complete trial. Default=0
%			Segment type is column 3 in 'data'. Column 4 must be the trial number (may be missing in old segment files)
%
% Description
%   converts segment files used with STF or REC signal files to MT style
%    	i.e all times referenced to start of trial

if nargin<2 trialtype=0;end;

newsuff='_t';
newname=[cutname newsuff];
[mystat,msg]=copyfile([cutname '.mat'],[newname '.mat']);

if ~mystat
   disp('Unable to copy input file');
   disp(msg);
   return;
end;


data=mymatin(cutname,'data');
label=mymatin(cutname,'label');


if size(data,2)<4
   disp('No trial number information')
   return
end;





%determine probable number of trials
vt=find(data(:,3)==trialtype);
ntrial=max(data(vt,4));

ndat=size(data,1);

%add a sort of record number to keep track of any rearrangement of the segment data
% so labels can also be rearranged

fixdata=[data (1:ndat)'];
outdata=[];

disp(['Highest trial number : ' int2str(ntrial)]);


for ii=1:ntrial
	vi=find(data(:,4)==ii);
	if ~isempty(vi) tmp=fixdata(vi,:);
      vt=find(tmp(:,3)==trialtype);
      
		if length(vt)==1
			trialgo=tmp(vt,1);
			tmp(:,1:2)=tmp(:,1:2)-trialgo;
			outdata=[outdata;tmp];
		else
			disp('missing or ambiguous trial segment')
			disp(tmp)
        
      end;
   else
      disp(['No data for trial ' int2str(ii)]);
   end;
end;
vr=outdata(:,5);
label=label(vr,:);
data=outdata(:,1:4);
ndatn=size(data,1);
if ndat~=ndatn
   disp(['Input/output sizes do not match ' int2str(ndat) ' ' int2str(ndatn)]);

end;


eval(['save ' newname ' data label -append']);

