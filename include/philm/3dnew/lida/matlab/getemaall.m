function [active,sample,sweep,dataS,dataC,pos] = getemaall (s,agname) 
% GETEMAALL -- get all current data from AG500
% [active,sample,sweep,dataS,dataC,pos]=getEmaAll(s,agname)
% GETEMAALL: Version 12.06.2012
%
%   Syntax
%       s: a java object of class java.net.Socket 
%       agname: Optional, default to 'AG500'
%
%   Assumptions
%       ssh tunneling open for port 30303 or port open
%       Cs5recorder running
%       open tunneling using
%           ssh -L 30303:192.168.1.XXX:30303 csop@192.168.1.XXX
%           where XXX is the server number plus 150
%       Note: If there are any changes in the data stream provided by the
%       AG500 or AG501 via the TCPIP connection then the java program
%       recmon will need changing (currently (10.2012) set up to handle
%       AG500 with 6 transmitters and 12 channels, or AG501 with 9
%       transmitters and 16 channels).
%
%   Example 
%       import java.net.*
%       import java.io.*
%       s = Socket('AG500Server', 30303);
%       [active,sample,sweep,dataS,dataC,pos] = getemaall(s);
%
%   See also
%       lida_connect recmon (java)
%
%   Updates
%       12.2008 Original version lbo
%       06.2012 Optional second input argument to specify machine, e.g.
%           'AG500', 'AG501'

import java.io.*;
import java.net.*;
import org.ema.*;

mymachine='AG500';

if nargin > 2 || ~isa(s, 'java.net.Socket')
    error('getemaall: Argument si must be of class java.net.Socket');
end
if nargin>1 mymachine=agname; end;

%make this configurable?
%it seems quite likely that read may quite often return an error, simply
%because new data is not yet available on the connection.
%So its probably better to incorporate an automatic retry here, rather than
%assuming the connction needs resetting every time an error occurs

%not so sure ....

retrylim=2;
retrywait=0.02;

%get input and output streams
si=s.getInputStream;
so=s.getOutputStream;

%send command ('data\n')
so.write([abs('data') 10]);
so.flush;

%read 
rec=Recmon(mymachine);


retrycount=0;
readsuccess=0;
retriesneeded=NaN;
while retrycount<retrylim
        pause(retrywait);
    try
        rec.read(si);
        retriesneeded=retrycount;
        retrycount=retrylim;
        readsuccess=1;
    catch
        retrycount=retrycount+1;
    end;
end;

%it seems no error is returned if error has no input argument
if ~readsuccess
%    disp('getemaall: retry limit exceeded');
    error('x');
end;

    %else
%    disp(['getemaall: retries needed : ' int2str(retriesneeded)]);
%end;

%try
%    rec.read(si);
%catch
%    disp('error in getemaall');
%    disp(lasterr);
    %    keyboard;
%    error(['getemaall: ' lasterror]);
%end

active = int32(rec.getActive);
sample = int32(rec.getSample);
dataC = rec.getDataC;
dataS = rec.getDataS;
pos = rec.getPos;
sweep=int32(rec.getSweep);
%this should probably never occur if errors are correctly caught above
if ((sample==0) & (sweep==0))
    error('y');
end;

