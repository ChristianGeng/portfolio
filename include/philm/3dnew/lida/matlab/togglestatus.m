function togglestatus
% TOGGLESTATUS  - toggle AG500 recording status
% function togglestatus
% TOGGLESTATUS: Version 12.06.2012  
%
%   Assumptions
%       ssh tunneling open for port 30303
%       Cs5recorder running
%       open tunneling using
%           ssh -L 30303:192.168.1.XXX:30303 csop@192.168.1.XXX
%           where XXX is the server number plus 150
%
%   Description
%       From 12.08 uses lida_connect for platform-independent connection.
%       Suppresses output messages (unless confirmation after sending
%       command is unexpected).
%       Only disadvantage of lida_connect at the moment on non-ips-platforms is
%       that configuration file is read every time togglestatus is called.
%       (but this is needed anyway if working with both ag500 and ag501
%       systems)
%
%   See Also
%       lida_connect
%
%   Updates
%       06.2008 Original version from simpleclick.lpr (mkt)
%       12.2008 use lida_connect (lbo/phil)
%       06.2012 adapt to new version of lida_connect

import java.lang.String;
import java.io.*;
import java.net.*;

lidatimeout=200;


try,

%	[s,si,so]=lida_connect(lidatimeout,1);	%quiet mode
	s=lida_connect(lidatimeout,1);	%quiet mode
	
	% open connection
%    s = Socket('141.84.138.216',30303);
%   06.2012 si and so no longer provided as output argument by lida_connect
    si = s.getInputStream;
    so = s.getOutputStream;

    % read greeting; expect "200 Welcome"
%    buf = []; k = 0;
%    while k ~= 10,
%        k = si.read;
%        buf(end+1) = k;
%    end;
%    buf = char(buf);    % echo this for debugging if necessary
%    disp(buf);
    % send command
    so.write([abs('simplestart') 10]);
    so.flush;
    %  so.write(abs(['go' crlf]));
    %  so.flush;
    % read response; expect "200 OK"
%    buf = []; k = 0;
%    while k ~= 10,
%        k = si.read;
%        buf(end+1) = k;
%    end;
%    buf = char(buf);
%    disp(buf);
    greet=lida_greetings(s);
    if ~strcmp('200 Ok',greet(1:6))
        disp(greet);
    end;

catch,
    lasterr
end;

% always disconnect
s.close;

