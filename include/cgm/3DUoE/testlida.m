function status=testlida(action)
% TESTLIDA Prototype for control of the AG500 from MATLAB
% function status=testlida(action)
% Version 06/06/08: Fixed the read timeout
% requires the the free tcp_udp_ip Toolbox by Peter Rydesäter 
% available at
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=345&objectType=file
%

%    In order to work, port 30303 has to be open, either by ssh tunneling
%    or by modifying the firewall 

%    tunnel can be opened by 
%    ssh -L 30303:192.168.1.XXX:30303 csop@192.168.1.XXX
%    Here, XXX is the server number plus 150


%    Cs5recorder must run


% Until sofar, it understands the commands 
% testlida('doubleclick') to toggle recording state
% testlida('getstatus') to check whether recording is on
% testlida('listen') to get the data on that stream
% This was enough for testing purposes, but in the future it should contain
% the possibility of combining starting commands and returning the data
% acquired (might be a simple way of using Phil's pegelstats. Note: samplerate is NOT constant).
%
% The data structure has 960 bytes altogether - see the code in the listen command:
%
% 
% dataS=double(pnet(con,'Read',[6 12],'single','intel'))'; 
%  1-normed amplituden (corrected by calfactor)
%
% dataC=double(pnet(con,'Read',[6 12],'single','intel'))';
% intentionally left empty - might change in the future
%
% extra=pnet(con,'Read',10,'uint32','intel')
% intentionally left empty - might change in the future
%
% pos=double(pnet(con,'Read',[7 12],'single','intel'))';
% self-evident
%
% ================================================
% Rubbish!
% copied in from the correspondence with Bahne and Burkhardt
%
% compiling free pascal:
% fpc source.pas
% cs5recmon.pas
%
% dword: 4byte integer / word
% dummy is the sweepnumber
%
% Make sure that you always close the connections you have
% used with 
% pnet(con,'close')
% pnet('closeall')
% 
%  first two double bits of 32 bit words
%  dataS=zeros(12,6)'
%
% this listening is blocking! could be usefull when running on a separate computer!
% better working with the command getstatus at the moment 
% which returns  sweepnumber etc. 



% Old cs6 : 192.168.1.156
% New cs6 : 129.215.204.7
% New cs5 : 129.215.204.6


csip='129.215.204.7';

if strcmp(action,'doubleclick')
 %con=pnet('tcpconnect','hostname',port)
  con1=pnet('tcpconnect',csip,30303);
  hello=pnet(con1,'readline'); %Hello 
  pnet(con1,'printf','click\n');
  
  con2=pnet('tcpconnect',csip,30303);
  hello=pnet(con2,'readline'); %Hello 
  pnet(con2,'printf','go\n');
  
  pnet(con1,'close')
  pnet(con2,'close')
  
  return
end
  

%pnet(con,'read' [,size] [,datatype] [,swapping] [,'view'] [,'noblock'])

if strcmp(action,'getstatus')
    con=pnet('tcpconnect',csip,30303);
    pnet(con,'setreadtimeout',10)  % set read time out to 10 sec!! That solves it
    hello=pnet(con,'readline'); %Hell 
    
    pnet(con,'printf','data\n');
    oursamples=pnet(con,'Read',2,'uint32','intel');
    status.active=bitand(oursamples(1),2^31)>0;
    status.sweep = oursamples(2);

    %ourdat=double(pnet(con,'Read',952,'uint8'));
    status.dataS=double(pnet(con,'Read',[6 12],'single','intel'))';
    status.dataC=double(pnet(con,'Read',[6 12],'single','intel'))';
    status.extra=pnet(con,'Read',10,'uint32','intel');
    status.pos=double(pnet(con,'Read',[7 12],'single','intel'))';
    pnet(con,'close')

end
  
  


if strcmp(action,'listen')
con=pnet('tcpconnect',csip,30303);
pnet(con,'setreadtimeout',10)  % set read time out to 10 sec. That solves it
hello=pnet(con,'readline'); %Hell 
%posfig=figure
sens=1:3;

while 1  
%oursamples=double(pnet(con,'Read',8,'uint8'));
%active=(oursamples(4)>127)==1
%sweepnumber = oursamples(5) + (oursamples(6)*(2^8))  + (oursamples(7)*(2^16)) + (oursamples(8)*(2^24))
pnet(con,'printf','data\n');
%pause (0.5)
oursamples=pnet(con,'Read',2,'uint32','intel');
status.active=bitand(oursamples(1),2^31)>0
%active=(bin(fi(tmp))
% c = bitand(a, b)
status.sweepnumber = oursamples(2);
%ourdat=double(pnet(con,'Read',952,'uint8'));
status.dataS=double(pnet(con,'Read',[6 12],'single','intel'))';
status.dataC=double(pnet(con,'Read',[6 12],'single','intel'))';
status.extra=pnet(con,'Read',10,'uint32','intel');
status.pos=double(pnet(con,'Read',[7 12],'single','intel'))';
%hold off
%plot3(pos(1:3,1),pos(1:3,2),pos(1:3,3),'.')
status.pos(sens,:);
status.dataS(sens,:);
status.dataC(:,:);
end
pnet(con,'close');

end

  


