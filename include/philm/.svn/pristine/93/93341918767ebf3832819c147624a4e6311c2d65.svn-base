function [s,agname] = lida_connect (varargin)
% LIDA_CONNECT --- open a socket to lida host
% function [s,agname] = lida_connect (varargin)
% LIDA_CONNECT: Version 12.06.2012
%
%   Syntax
%       s = lida_connect(timeout) returns Java Object of class Socket
%       [s,agname] = lida_connect(timeout) returns the name of the AG machine
%       The optional parameter timeout maybe used to specify a timout interval
%           in milliseconds for subsequent reading operations of the socket.
%       The welcome string "200 Welcome" will be read so that the InputStream
%           will be empty thereafter.
%           Output of this on the terminal is suppressed if a second input argument
%           is present.
%
%   Assumptions
%       ssh tunneling open for port 30303 or port open
%       Cs5recorder running
%       Note: If there are any changes in the data stream provided by the
%       AG500 or AG501 via the TCPIP connection then the java program
%       recmon will need changing (currently (10.2012) set up to handle
%       AG500 with 6 transmitters and 12 channels, or AG501 with 9
%       transmitters and 16 channels). See getemaall for the format of the
%       data stream.
%
%   Description
%       Per default, the IPS Munich settings are used for connection, i.e.
%       IP=141.84.138.216 PORT=30303
%       Alternatively, if a struct named "lida" with the fields "host" (IP / hostname
%       of lida) and port (TCP/IP port to connect to) exists in a file
%       "lida_cfg.mat", these values will be taken to override the default.
%       The lida struct can also have a name field to allow switching
%       between different AG systems. Default is 'AG500'
%
%   See Also
%       getemaall, togglestatus, recmon (java)
%
%   Updates
%       19.08.2008 Original version (lbo)
%       12.08 second input argument (phil)
%       6.2012 Prepare for alternative AG500/501 systems: Message if not
%           using default configuration. Introduce 'name' field in lida struct.
%           Replace original additional output arguments (si, so) with this
%           name

if nargout > 2
    error('Too many output arguments');
end

if nargin > 2
    error('Too many input arguments');
end

import java.io.*;
import java.net.*

moregreet=' ';
deflida.host='141.84.138.216';
deflida.port=30303;
deflida.name='AG500';
matname='lida_cfg.mat';

if exist(matname,'file')
    lida=mymatin(matname, 'lida', deflida);
    if ~isfield(lida,'name')
        lida.name='AG500';
    end;
    moregreet=['. lida_connect to: ' lida.name ' at ' lida.host ' (settings from ' matname ')'];
    
else
    lida=deflida;
end
s=Socket(lida.host, lida.port);

%if nargin == 1 %should probably have been changed when second input
%argument was introduced
if nargin
    s.setSoTimeout(varargin{1});
end


if nargout > 1
    agname = lida.name;
end

%if nargout >= 2
%    varargout{1} = s.getInputStream;
%end

%if nargout == 3
%    varargout{2} = s.getOutputStream;
%end

greet=lida_greetings(s);
if nargin<2 
	disp([greet(1:(end-2)) moregreet]); 
end;

