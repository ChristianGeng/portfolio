function filterpos(inpath,outpath,amppath,triallist,sensorlist,coff,orifac,rmsfac)
% FILTERPOS filter ag500 position data and recalculate rms error
% function filterpos(inpath,outpath,amppath,triallist,sensorlist,coff,orifac,rmsfac)
%  Filter coefficients are stored in coff. If coff is a vector, the same
%  filter is applied to all channels. Coff can also be a cell, with entries
%  matching the vector of sensors to process in sensorlist
% orifac should be pi/180 for new recordings that store orientation in
% degrees
% rmsfac should be 2500 for compatibility with data calculated by calcpos

%orifac=pi/180;
%rmsfac=2500;

nsensor=length(sensorlist);
ampext='.amp';
posext='.pos';
ndig=4;

%number of coordinates to process
%orientations are converted to cartesian, filtered, then converted back
%again

ndim=6;


coffc=cell(nsensor,1);

if ~iscell(coff)
    for ii=1:nsensor coffc{ii}=coff; end;
else
    coffc=coff;
end;

if length(coffc)~=nsensor
    disp('Coefficient list does not match sensor list');
    return;
end;

for itrial=triallist
    data=loadpos([inpath pathchar int2str0(itrial,ndig) posext]);
    if ~isempty(data)
        disp(itrial);
        aa=loadamp([amppath pathchar int2str0(itrial,ndig) ampext]);
        for isensor=1:nsensor
            mysensor=sensorlist(isensor);
            mycoff=coffc{isensor};
            pos1=data(:,1:3,mysensor);
            ori1=data(:,4:5,mysensor)*orifac;
            [ox1,oy1,oz1]=sph2cart(ori1(:,1),ori1(:,2),1);

            d1=[pos1 ox1 oy1 oz1];


            for idim=1:ndim
                %maybe allow for upsampling (interpolation???)
                d1(:,idim)=decifir(mycoff,d1(:,idim));
            end;

            [d1(:,4),d1(:,5),dodo]=cart2sph(d1(:,4),d1(:,5),d1(:,6));

            d1(:,4:5)=d1(:,4:5)/orifac;      %convert back to degrees if necessary


            pax=calcamps(d1(:,1:3),d1(:,4:5));

            [posamprms,posampdt]=posampana(aa(:,:,mysensor),pax,rmsfac);

%            keyboard;
            data(:,1:7,mysensor)=[d1(:,1:5) posamprms posampdt];
        end;

        savepos([outpath pathchar int2str0(itrial,ndig) posext],data);
    end;        %data not empty
end;

