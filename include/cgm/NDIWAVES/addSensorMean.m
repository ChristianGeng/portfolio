function addSensorMean(infile,sensor1,sensor2,sensout)
% addSensorMean: add middle point between 2 sensors to file
% Purpose: Calculate mean point of 2 sensors which can help head correction
% in situation where three sensors where used to record the occlusal plane
% trial. 
%   
% Usage Example: addSensorMean('rawpos_filt/0001','BPL','BPR','BPBASE')
% adds the mean point bettern BPL and BPR


% infile='rawpos_filt/0003';
% sensor1='BPL';
% sensor2='BPR';
% sensout='BPBASE';


s=load(infile);
idxS1=strmatch(sensor1,s.dimension.axis{3});
idxS2=strmatch(sensor2,s.dimension.axis{3});


infile=rmextension(infile);
outfile=[infile,'_sensAdd'];
idxImpute=size(s.data,3)+1;
% keyboard
sensornames=cellstr(s.dimension.axis{3});
sensornames{idxImpute}=sensout;
s.dimension.axis{3}=char(sensornames);

s.data(:,:,idxImpute)=0;
dat2impute=(s.data(:,1:3,[idxS1])+s.data(:,1:3,[idxS2]))./2;
s.data(:,1:3,idxImpute)=dat2impute;




save([outfile '.mat'],'-struct','s');

end

