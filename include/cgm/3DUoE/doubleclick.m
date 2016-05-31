function doubleclick(machine)
% simple toggle for recording status 
% 
% Exmaple: doubleclick('cs5')
% 
% New cs6 : 129.215.204.7
% New cs5 : 129.215.204.6
%
%
% GETEMAALL -- get current data from RT stream on tcp/ip of your 
% Controlserver as sent from LIDA on port 30303
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


    
if strcmp(machine,'cs6')
    csip='129.215.204.7';
elseif strcmp(machine,'cs5')
    csip='129.215.204.6';
elseif strcmp(machine,'both')
    disp(['operating cs5 and cs6'])    
elseif strcmp(machine,'cs60')
    csip='141.89.97.192'
elseif strcmp(machine,'localhost')
    csip='127.0.0.1';
elseif strcmp(machine,'cs76') % HU alt
    csip='194.94.12.68';    
elseif strcmp(machine,'cs79') % HU neu
%     static IPS: 37,42,43
%     DNS: 141.20.1.3,141.20.2.3,141.20.1.31,
%     GW 141.20.144.1
%     255.255.255.0
    csip='141.20.144.42';        
elseif strcmp(machine,'cs80') % HU neu
    csip='141.20.144.43';    
elseif strcmp(machine,'both')
    cs5ip='129.215.204.6';
    cs6ip='129.215.204.7';
% scharfmachen
 % cs5
  con1cs5=pnet('tcpconnect',cs5ip,30303);
  hello=pnet(con1cs5,'readline'); 
  pnet(con1cs5,'printf','click\n');
% cs6
  con1cs6=pnet('tcpconnect',cs6ip,30303);
  hello=pnet(con1cs6,'readline'); 
  pnet(con1cs6,'printf','click\n');

% go
  %cs5
  con2cs5=pnet('tcpconnect',cs5ip,30303);
  hello=pnet(con2cs5,'readline'); %Hello 
  pnet(con2cs5,'printf','go\n');
  %cs5
  con2cs6=pnet('tcpconnect',cs6ip,30303);
  hello=pnet(con2cs6,'readline'); %Hello 
  pnet(con2cs6,'printf','go\n');
  [pnet(con1cs5,'status') pnet(con2cs5,'status') pnet(con1cs6,'status') pnet(con2cs6,'status') ];
%   statcon1cs5=pnet(con1cs5,'status');
%   statcon2cs5=pnet(con2cs5,'status');
%   statcon1cs6=pnet(con1cs6,'status');
%   statcon2cs6=pnet(con2cs6,'status');
   closecon(con1cs5);
   closecon(con2cs5);
   closecon(con1cs6);
   closecon(con2cs6);  
elseif strcmp(machine,'bothHU')
    cs5ip='141.20.144.42';
    cs6ip='141.20.144.43';
% scharfmachen
 % cs5
  con1cs5=pnet('tcpconnect',cs5ip,30303);
  hello=pnet(con1cs5,'readline'); 
  pnet(con1cs5,'printf','click\n');
% cs6
  con1cs6=pnet('tcpconnect',cs6ip,30303);
  hello=pnet(con1cs6,'readline'); 
  pnet(con1cs6,'printf','click\n');

% go
  %cs5
  con2cs5=pnet('tcpconnect',cs5ip,30303);
  hello=pnet(con2cs5,'readline'); %Hello 
  pnet(con2cs5,'printf','go\n');
  %cs5
  con2cs6=pnet('tcpconnect',cs6ip,30303);
  hello=pnet(con2cs6,'readline'); %Hello 
  pnet(con2cs6,'printf','go\n');
  [pnet(con1cs5,'status') pnet(con2cs5,'status') pnet(con1cs6,'status') pnet(con2cs6,'status') ];
%   statcon1cs5=pnet(con1cs5,'status');
%   statcon2cs5=pnet(con2cs5,'status');
%   statcon1cs6=pnet(con1cs6,'status');
%   statcon2cs6=pnet(con2cs6,'status');
   closecon(con1cs5);
   closecon(con2cs5);
   closecon(con1cs6);
   closecon(con2cs6);  
else, warning('machine  single unknown');
%     return;
end

% if strcmp(machine,'both')
%     cs5ip='129.215.204.6';
%     cs6ip='129.215.204.7';
% % scharfmachen
%  % cs5
%   con1cs5=pnet('tcpconnect',cs5ip,30303);
%   hello=pnet(con1cs5,'readline'); 
%   pnet(con1cs5,'printf','click\n');
% % cs6
%   con1cs6=pnet('tcpconnect',cs6ip,30303);
%   hello=pnet(con1cs6,'readline'); 
%   pnet(con1cs6,'printf','click\n');
% 
% % go
%   %cs5
%   con2cs5=pnet('tcpconnect',cs5ip,30303);
%   hello=pnet(con2cs5,'readline'); %Hello 
%   pnet(con2cs5,'printf','go\n');
%   %cs5
%   con2cs6=pnet('tcpconnect',cs6ip,30303);
%   hello=pnet(con2cs6,'readline'); %Hello 
%   pnet(con2cs6,'printf','go\n');
%   [pnet(con1cs5,'status') pnet(con2cs5,'status') pnet(con1cs6,'status') pnet(con2cs6,'status') ];
% %   statcon1cs5=pnet(con1cs5,'status');
% %   statcon2cs5=pnet(con2cs5,'status');
% %   statcon1cs6=pnet(con1cs6,'status');
% %   statcon2cs6=pnet(con2cs6,'status');
%    closecon(con1cs5);
%    closecon(con2cs5);
%    closecon(con1cs6);
%    closecon(con2cs6);  
% else, 
%  %con=pnet('tcpconnect','hostname',port)
%   con1=pnet('tcpconnect',csip,30303);
%   hello=pnet(con1,'readline'); %Hello 
%   pnet(con1,'printf','click\n');
%   
%   con2=pnet('tcpconnect',csip,30303);
%   hello=pnet(con2,'readline'); %Hello 
%   pnet(con2,'printf','go\n');
%   
%   % both cons are already closed here! 
%    statcon1=pnet(con1,'status');
%    statcon2=pnet(con2,'status');
%        
% if (statcon1 ~= 0)
%   %disp(['closing con 1:'])  
%   pnet(con1,'close')
%  else, warning('indeeed, con1 already closed')
% end
%    
% if (statcon2 ~= 0)
%  %   disp(['closing con 2:'])
%     pnet(con2,'close')
% else, warning('indeeed, con2 already closed')
% end
% end
% 




function closecon(con)

 statcon=pnet(con,'status');
 if (statcon ~= 0)
  %disp(['closing con 1:'])  
  pnet(con,'close')
 else, warning('closecon: indeeed, connection already closed')
end
 