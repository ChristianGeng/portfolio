function dataout=loadpos_sph2cart(posfile,badspec);
% LOADPOS_SPH2CART Load ag500 pos file and convert spherical coordinates to Cartesian
% function dataout=loadpos_sph2cart(posfile,badspec);
% LOADPOS_SPH2CART: Version 4.05.05
%
%   Description
%       Converts x,y,z,phi,theta,rms,extra to x,y,z,ox,oy,oz,rms,extra
%
%       Assumes phi and theta are in degrees
%       Converts invalid input data to NaNs
%           Controlled by badspec
%           m*2 array with criterion parameter in first column (re. input
%           data!!, i.e normally parameters 6 and above)
%           and threshold value in second column
%           Currently any data EXCEEDING the threshold is set to NaN

dataout=[];
data=loadpos(posfile);

if isempty(data) return; end;

nsens=size(data,3);
npar=size(data,2);

if nargin>1
    nbad=size(badspec,1);
    for ibad=1:nbad
        badp=badspec(ibad,1);
        badth=badspec(ibad,2);
        for ii=1:nsens
%temporary; fix in comamposampdt
            vv=find(abs(data(:,badp,ii))>badth);
%            vv=find(data(:,badp,ii)>badth);
            if ~isempty(vv)
                nv=length(vv);
                vv=[vv;vv+1];   %as value compamposampdt involves difference, also set next sample to NaN
                disp(['Bad data (sensor, n, badp, bad th) : ' int2str(ii) ' ' int2str(nv) ' ' int2str(badp) ' ' num2str(badth)]);
                data(vv,1:5,ii)=NaN;
            end;
        end;
    end;

end;

dataout=ones(size(data,1),npar+1,nsens);

dataout(:,[1:3 7:end],:)=data(:,[1:3 6:end],:);

%convert from spherical to cartesian
for ii=1:nsens
    spd=data(:,4:5,ii)*pi/180;
    [ox,oy,oz]=sph2cart(spd(:,1),spd(:,2),1);
    dataout(:,4:6,ii)=[ox oy oz];
end;
