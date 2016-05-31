function [dataout,descriptor,unit,dimension,sensorlist]=loadpos_sph2cartm(posfile);
% LOADPOS_SPH2CARTM Load tapadm output file and convert spherical coordinates to Cartesian
% function [dataout,descriptor,unit,dimension,sensorlist]=loadpos_sph2cartm(posfile);
% LOADPOS_SPH2CARTM: Version 17.11.05
%
%   Description
%       Converts x,y,z,phi,theta,rms,extra to x,y,z,ox,oy,oz,rms,extra
%
%       If descriptor variable in input file does not have phi in
%       the expected position, then data is not changed
%       If unit variable is not 'degrees' then angles are assumed to be
%       radians

dataout=[];
descriptor=[];unit=[];dimension=[];sensorlist=[];

data=loadpos(posfile);

phiexp=4;

if isempty(data) return; end;

descriptor=mymatin(posfile,'descriptor');
dd=lower(descriptor);
unit=mymatin(posfile,'unit');
uu=lower(unit);

dimension=mymatin(posfile,'dimension');

sensorlist='';
isi=strmatch('sensor',lower(dimension.descriptor));
if length(isi)==1
sensorlist=dimension.axis{isi};
else
    disp('loadpos_sph2cartm: Unable to set up sensor list');
end;


vp=strmatch('phi',dd);

phiok=0;

if not(isempty(vp))
    if vp(1)==phiexp
        phiok=1;
    end;
end;

if not(phiok)
    dataout=data;
    disp('loadpos_sph2cartm: Data not transformed');
    return
end;

anglefac=pi/180;
myunit=uu(vp(1),:);

if isempty(findstr('deg',myunit))
    anglefac=1;
    disp('assuming angles in radians')
end;

%set up output descriptor and unit

nsens=size(data,3);
npar=size(data,2);

descriptor=cellstr(descriptor);
newdesc=cell(npar+1,1);
newdesc([1:3 7:end])=descriptor([1:3 6:end]);
unit=cellstr(unit);
newunit=cell(npar+1,1);
newunit([1:3 7:end])=unit([1:3 6:end]);

newdesc(4:6)={'orix','oriy','oriz'};
newunit(4:6)={'norm','norm','norm'};

descriptor=char(newdesc);
unit=char(newunit);

isi=strmatch('coordinate',lower(dimension.descriptor));
if length(isi)==1
dimension.axis{isi}=descriptor;
else
    disp('loadpos_sph2cartm: Unable to update dimension');
end;



dataout=ones(size(data,1),npar+1,nsens);

dataout(:,[1:3 7:end],:)=data(:,[1:3 6:end],:);

%convert from spherical to cartesian
for ii=1:nsens
    spd=data(:,4:5,ii)*anglefac;
    [ox,oy,oz]=sph2cart(spd(:,1),spd(:,2),1);
    dataout(:,4:6,ii)=[ox oy oz];
end;
