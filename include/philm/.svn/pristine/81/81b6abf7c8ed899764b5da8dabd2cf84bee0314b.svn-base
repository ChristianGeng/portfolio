ndig=4;

triallist=1:4;

for itrial=triallist
	aa=loadamp(['amps\' int2str0(itrial,ndig) '.amp']);
	pp=loadpos(['rawpos\' int2str0(itrial,ndig) '.pos']);
	
	newpos=showlinpredmr_w(aa,pp);
	savepos(['rawpos\' int2str0(itrial,ndig) '.pxx'],newpos);

	newpos(:,6,:)=60000;
	savepos(['rawpos\' int2str0(itrial,ndig) '.pos'],newpos);
end;
