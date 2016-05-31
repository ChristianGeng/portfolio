 function togglestatus(s)
 %TOGGLESTATUS(s)  - toggle AG500 recording status
 %
 %    usage:  ToggleStatus
 %
 %assumptions:
 %    ssh tunneling open for port 30303
 %     Cs5recorder running
 %
 % open tunneling using
 % ssh -L 30303:192.168.1.XXX:30303 csop@192.168.1.XXX
 % where XXX is the server number plus 150
%	This version assumes connection opened using lida_connect
 
 % mkt 06/08 from simpleclick.lpr

 import java.lang.String;
 import java.io.*;
 import java.net.*;

 try,

 % open connection
%     s = Socket('141.84.138.216',30303);
     si = s.getInputStream;
     so = s.getOutputStream;

 % read greeting; expect "200 Welcome"
     buf = []; k = 0;
     while k ~= 10,
         k = si.read;
         buf(end+1) = k;
     end;
     buf = char(buf);    % echo this for debugging if necessary
     disp(buf);
 % send command
 command=String(['simplestart' crlf]);
 so.write(command.getBytes);
 so.flush;
 % read response; expect "200 OK"
     buf = []; k = 0;
     while k ~= 10,
         k = 1
         buf(end+1) = k;
     end;
     buf = char(buf);
     disp(['Hallo ' buf]);
     
 catch,
     lasterr
 end;

 % always disconnect
 %s.close;

