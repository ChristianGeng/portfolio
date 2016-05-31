function concs6=connectcs6rt
% connect to rt stream on cs6
% makes sense for follwing reading of data streams 
% by getEmaData
% UoE machines' current ip numbers 
% New cs5 : 129.215.204.6
% New cs6 : 129.215.204.7
% See also GETEMADATA
%    cg 
%  $Date: 2008/10/12 21:43:00 $


concs6.host='129.215.204.7';
concs6.port=30303;
concs6.timeout=10;
concs6.name='cs6';

try,
    concs6=rtstream_connect(concs6)
catch, 
    error('connection failed');
end


