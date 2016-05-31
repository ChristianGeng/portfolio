function greet = lida_greetings(s)
% LIDA_GREET --- get greeting from lida
% greet = lida_greetings(s) where s is a java socket connected to lida
%       must be run immediately after opening the socket
% Assumptions
%     cs5recorder running, 
%
% lbo 20Aug08

import java.io.InputStream

si = s.getInputStream;
greet = [];
k=0;
while k~= 10
    k = si.read;
    greet(end+1) = k;
end

greet = char(greet);
