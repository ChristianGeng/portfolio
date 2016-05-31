function  varargout=NDIimport(fileToRead1,varargin);
% Purpose:  - Import NDI WAVE FILE,
%           - correct the time axis
%
% Imports data from the specified file
%
% Syntax:
% [...] = NDIimport(); displays this help message
%
% NDIimport(fileToRead1), reads fileToRead1 but returns empty matrix
%
% [data,...] = NDIimport(fileToRead1), reads fileToRead1 and returns
% a 3D data array The first dimension equals the number of aquired samples,
% the second dimension are x,y,z,q0,qx,qy,z,0 and the third dimension is
% the number of sensors.
%
% [data,...] = NDIimport(fileToRead1,'QUATERNION') is the same as data=NDIimport(fileToRead1),
% (i.e. data are left in standard NDI format using quaternions)
%
% [data] = NDIimport(fileToRead1,'SPHERICAL') returns x,y,z,phi,theta,NaN,NaN
% in the second dimension. They alre also converted to deg for the analogy
% with the Carstens way of representation.
%
% [data] = NDIimport(fileToRead1,'SPHERICALMKT') returns x,y,z,phi,theta,NaN,NaN
% in the second dimension as adopted from mkt. They alre also converted to deg for the analogy
% with the Carstens way of representation.
%s
% [data,NDIdescr] = NDIimport(fileToRead1, ... ) also returns the descriptor as found in
% the Spread sheet
%
% [data,NDIdescr,rawdata] = NDIimport(fileToRead1, ... ) also returns the original
% 2D data matrix after correcting the time axis as described by Melanie
% Scholz.
%
% [data,NDIdescr,rawdata,timeAx] = NDIimport(fileToRead1, ... ) returns the
% time axis
%
%  CG $17-Dec-2011$ 18:19:37
%
% CHANGELOG:
% $17-Dec-2011$
% +  Spincalc -> SpinCalc
% +  Exports NDI sensor status variable in SPHERICAL MODE

varargout{1}=[]; % data
varargout{2}=[]; % descriptor
varargout{3}=[]; % timeax
error(nargchk(0, 2, nargin));

if nargin < 1,
    eval('help NDIimport');
    warning('returning empty matrix')
    return;
end;

retformatuse='QUATERNION';
if nargin>1
    retformat=upper(varargin{1});
    switch retformat
        case 'QUATERNION'
            retformatuse='QUATERNION';
        case 'SPHERICAL'
            retformatuse='SPHERICAL';
        otherwise
            warning('return format not recognized: returning empty returns!!');
            return;
    end
end
% disp(['will return data as ' retformatuse])

ndim=7;

if isoctave
    %newData1 = importdata_octave(fileToRead1,'\t',1);
    rawdata=dlmread(fileToRead1,'\t');
    rawdata=rawdata(2:end,:);
    fid=fopen(fileToRead1,'r'); myline=fgetl(fid); fclose(fid);
    [matchstart,matchend,tokenindices,matchstring,tokenstring,tokenname,NDIdescr]=regexp(myline,'\t');
    
elseif ismatlab
    newData1 = importdata(fileToRead1);
    rawdata=newData1.data;
    NDIdescr=newData1.textdata;
else('error: Neither Matlab or Octave?')
end

NDIdescriptor=char(NDIdescr);

% Create new variables in the base workspace from those fields.
% vars = fieldnames(newData1);
% for i = 1:length(vars)
%     assignin('base', vars{i}, newData1.(vars{i}));
% end


% calculate correct Time Axis for articulatory data (see snippets of mail / Xls-File by Melanie)
%myStamps='Z:\myfiles\potsdam\NDIWaves\Melaniesstamps.xls'
%xlsfinfo(myStamps)
%[status,sheets,format]=xlsread(myStamps,'stamps');
WaveSR=22050;
%The WavID is the actual sample number in the Wav file closest to the kinematic sample.
wavId=rawdata(:,3);
wavIdShift=circshift(wavId,-1);
sampdur= (wavIdShift -  wavId) ./ WaveSR ;
wavId_1=wavId(1)./WaveSR; % compare: disp(status(1,4))
% timeAx: Artikulatorische ZeitAchse in Sekunden
timeAx=wavId_1 + cumsum(sampdur);
timeAx=[wavId_1  ; timeAx(1:end-1) ];
rawdata(:,1)=timeAx;


II=strmatch('Sensor',NDIdescriptor);

sensorstatus=rawdata(:,II(2:2:end));
sensorID=rawdata(:,II(1:2:end));

II=II(1:2:end);
nsensors=length(II);
%descriptor=NDIdescriptor([II(1)+2:II(1)+8],:);
data=nan(size(rawdata,1), 7, nsensors);

if(size(NDIdescriptor,1)>size(rawdata,2))
    rawdata(:, size(rawdata,2)+1:size(NDIdescriptor,1)) = NaN;
end

for ll=1:nsensors
    datIdx=[II(ll)+2:II(ll)+8];
    NDIdescriptor(datIdx,:);
    tmpdat=rawdata(:,datIdx);
    
    switch retformatuse
        case 'QUATERNION'
            data(:,1:ndim,ll)=tmpdat(:,1:ndim);
        case 'SPHERICAL'
            % assumption: quaternion tools on path
            %             here:(180/pi).*phi;
            %              NDIWAVE2pos: orifac = pi/180;
            for idxDatlen=1:length(tmpdat)
                tmpCart=SpinCalc('QtoDCM',tmpdat(idxDatlen,[7 4 5 6]),1e-6,0)*[0 -1 0]';
                %norm(sum(tmpCart.^2))
                [theta,phi,r]=cart2sph(tmpCart(1),tmpCart(2),tmpCart(3)); % NOTE: phi theta change carried out here!
                tmpdat(idxDatlen,4:ndim)=NaN;
                tmpdat(idxDatlen,4)=theta;
                tmpdat(idxDatlen,5)=phi;
            end
            tmpdat(:,4:5)=tmpdat(:,4:5).*(180/pi); % radians to deg
            
        case 'SPHERICALMKT'
            % original Version:
            [az,el]=quat2sph(tmpdat(:,4:7));
            % vertauschen von az und el
            %[el,az]=quat2sph(tmpdat(:,4:7));
            tmpdat(:,4:ndim)=NaN;
            tmpdat(:,4)=az;
            tmpdat(:,5)=el;
            
        otherwise
            
    end
    data(:,1:ndim,ll)=tmpdat(:,1:ndim);
    %         data(:,4,ll)=(180/pi).*phi;
    %         data(:,5,ll)=(180/pi).*theta;
    
    % nanvar((180/pi).*THETA)
    % nanvar((180/pi).*PHI)
end

switch retformatuse
    case 'QUATERNION'
        descriptor=char('x[mm]','y[mm]','z[mm]','q0','qx','qy','qz');
    case {'SPHERICAL','SPHERICALMKT'}
        descriptor=char('x[mm]','y[mm]','z[mm]','az','el','status','compdist');
        data(:,6,:)=sensorstatus;
        %            keyboard
    otherwise
        
end


varargout{1}=data;
varargout{2}=descriptor;
varargout{3}=rawdata;
varargout{3}=timeAx;

