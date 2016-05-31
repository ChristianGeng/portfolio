function [active,sample,sweepnumber,dataS,dataC,pos] = getEmaDataDestroy(nummer)
% GETEMADATA -- get current data from RT stream on tcp/ip of your 
% Controlserver as sent from LIDA on port 30303
% Desctructive version: Conenction is closed after usage
% This port 30303 must acceessible in order to work 
% This can be achieved 
% (A)tunneling: 
%    open tunneling using
%    ssh -L 30303:192.168.1.XXX:30303 csop@192.168.1.XXX
%    where XXX is the server number plus 150
%    Cs5recorder running
% (B) opening it permanently by editing your iptables 
%
% Code Example on the Usage: 
% cs6rt.host=cs6ip
% cs6rt.port=30303
% cs6rt=rtstream_connect(cs6rt)
%
% There aslso exist wrappers for the UoE setup:
% concs6=connectcs6rt
% concs5=connectcs5rt
% get samples with 
% [active,sample,sweepnumber,dataS,dataC,pos] = getEmaData(cs6rt.con)
% Close the connection with:
% cs6rt=rtstream_close(cs6rt)

% See Also RTSTREAM_CLOSE, RTSTREAM_CONNECT CONNECTCS5RT CONNECTCS6RT GETEMADATA

whos
nummer
%con=pnet('tcpconnect','129.215.204.7',30303);
con=pnet('tcpconnect',nummer,30303)
    pnet(con,'setreadtimeout',10)  % set read time out to 10 sec!! That solves it
    hello=pnet(con,'readline'); %Hell 

 pnet(con,'printf','data\n');
    oursamples=pnet(con,'Read',2,'uint32','intel');

active=bitand(oursamples(1),2^31)>0;
%active=(bin(fi(tmp))
% c = bitand(a, b)
sweepnumber = oursamples(2);
%ourdat=double(pnet(con,'Read',952,'uint8'));
dataS=double(pnet(con,'Read',[6 12],'single','intel'))';
dataC=double(pnet(con,'Read',[6 12],'single','intel'))';
extra=pnet(con,'Read',10,'uint32','intel');
pos=double(pnet(con,'Read',[7 12],'single','intel'))';
pnet(con,'close')











  
