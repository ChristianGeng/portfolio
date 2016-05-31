function ftpobj=connect2cs5ftp
% CONNECT2CS6FTP Set up ftp connection to control server 5
% function ftpobj=connect2cs
% connect2cs: Version 20.10.08
%
%   Description
%       Sets up ftp connection to control server
%       using ip address currently in use at IPS Munich
%       Defines global variable ftpobj (e.g for use by docopyds)
% New cs5 : 129.215.204.6
% New cs6 : 129.215.204.7


global ftpobj

disp('Connecting to AG500 control server; please wait');
ftpobj=ftp('129.215.204.6');

