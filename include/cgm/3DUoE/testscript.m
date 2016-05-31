function testscript


%doubleclick('cs5')
%doubleclick('cs6')
%pause(2)
%doubleclick('cs5')
%doubleclick('cs6')

% Connetc to cs6 serving on default port:
cs6ip='129.215.204.7';
cs5ip='129.215.204.6';

% 
% cs6rt.host=cs6ip
% cs6rt.port=30303
% cs6rtrt=rtstream_connect(cs6rt)
% cs6rtrt
% 
% rtstream_close(cs6rt)

% use ziggys notebook instead of cs5:
% cs5ip='129.215.204.8';
% eddies notebook instead of cs6:

% does not work:
%con=pnet_remote('connect',cs6ip,5678)
cs7ip='129.215.204.10'; % which ip or machine?? Eddie
cs7ip='129.215.204.8'; % susie maroon


% works:
concs5remote=pnet_remote('connect',cs5ip)
concs6remote=pnet_remote('connect',cs6ip)
concs7remote=pnet_remote('connect',cs7ip)

pnet_remote(concs5remote,'BREAK')
pnet_remote(concs6remote,'BREAK')
pnet_remote(concs7remote,'BREAK')
 
pnet_remote(concs6remote,'PUTSCRIPT','prompter_doubleEMAtcpip.m')
pnet_remote('closeall')

% returns 'ready' if connection open 
stat=pnet_remote(concs6remote,'status')
stat=pnet_remote(concs5remote,'status')
% works

rr=0;
for rr=1:1000
pause(3)
pnet_remote(concs5remote,'eval','plot(rand(5,5),''linewidth'',4)')
pnet_remote(concs6remote,'eval','plot(rand(5,5),''linewidth'',4)')
pnet_remote(concs7remote,'eval','plot(rand(5,5),''linewidth'',4)')

doubleclick('cs6')
doubleclick('cs5')
pause(3)
doubleclick('cs6')
doubleclick('cs5')
end



  pnet_remote(concs6remote,'close')
% pnet_remote(con,'close')
  pnet_remote(concs7remote,'close')