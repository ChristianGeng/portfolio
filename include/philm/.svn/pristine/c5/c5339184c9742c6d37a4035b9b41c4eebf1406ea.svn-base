function daf_demo_cb(obj,event,hai,delaysamp)
% DAF_DEMO_CB Callback for use with daf_demo
% function daf_demo_cb(obj,event,hai,delaysamp)


daqdone1=get(obj,'samplesavailable');
addone1=get(hai,'SamplesAcquired');

data=getdata(hai,delaysamp);
daqdone2=get(obj,'samplesavailable');
addone2=get(hai,'SamplesAcquired');

putdata(obj,data);

%disp([daqdone1 daqdone2 addone1 addone2]);
