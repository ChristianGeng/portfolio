function ftpobj=connect2cs
% CONNECT2CS Set up ftp connection to control server
% function ftpobj=connect2cs
% connect2cs: Version 13.11.08
%
%   Description
%       Sets up ftp connection to control server
%       By default, uses ip address currently in use at IPS Munich.
%		However, if a mat file named csconfig.mat is present on matlab's
%		path, and if it contains a string variable named ipaddress, then
%		this will be used instead.
%		Note: csconfig.mat should not be placed in one of the directories
%		updated by subversions.
%       Defines global variable ftpobj (e.g for use by docopyds)
%		i.e mainly intended to be used to allow copying of files from AG500
%		control server using matlab's ftp functions
%
%	Updates
%		Allow alternative IP address

global ftpobj

ipaddress='141.84.138.216';

if exist('csconfig.mat','file')
	ipaddress=mymatin('csconfig','ipaddress');
	disp('csconfig: using address in csconfig.mat');
end;



disp(['Connecting to AG500 control server at ' ipaddress '; please wait']);

ftpobj=ftp(ipaddress);

