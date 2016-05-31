function biglist=sensorsigs(sensornames,parnames);
% SENSORSIGS Make list of signals from list of sensors and coordinates
% function biglist=sensorsigs(sensornames,parnames);
% sensorsigs: Version 14.10.05

nsens=size(sensornames,1);
mycell=cell(nsens,1);
parc=cellstr(parnames);

for ii=1:nsens
    mycell{ii}=char(strcat(deblank(sensornames(ii,:)),'_',parc));
end;

%keyboard;
biglist=strvcat(mycell);
