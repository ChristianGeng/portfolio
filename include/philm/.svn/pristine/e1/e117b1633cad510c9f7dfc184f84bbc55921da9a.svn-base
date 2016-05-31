function descout=flatdescriptor(descriptor,dimension);
% FLATDESCRIPTOR Get flat descriptor for sensor-style mat files
% function descout=flatdescriptor(descriptor,dimension);
% flatdescriptor: Version 17.11.05

sensorlist=dimension.axis{3};
ndesc=size(descriptor,1);
        nsensor=size(sensorlist,1);
        
        desctmp=repmat(descriptor,[nsensor 1]);
        descnew=[];
        for isi=1:nsensor
            tmptmp=repmat(sensorlist(isi,:),[ndesc 1]);
            descnew=[descnew;tmptmp];
        end;
        
            descout=strcat(descnew,'_',desctmp);
