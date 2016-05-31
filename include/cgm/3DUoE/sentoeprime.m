function sentoeprime

eprimeport=5500;
% one alternative
eprime1ip='129.215.204.10'; % which ip or machine?? Eddie
con1eprime=pnet('tcpconnect',eprime1ip,eprimeport);  % port not right!!
pnet(con1eprime,'printf','maptask1\n');
pnet(con1eprime,'status')
statcon=pnet(con1eprime,'status');
pnet(con1eprime,'close')
 



 % another - with the socket command
 sock=pnet('tcpsocket',eprimeport);
 if(sock==-1), error('Specified TCP port is not possible to use now.'); end
  con1eprime=pnet(sock,'tcplisten');
  	[ip,port]=pnet(con1eprime,'gethost');
    pnet(con1eprime,'printf','maptask1');
    
    
      pnet(con1eprime,'close');
      