function concs5=connectcs5rt
% connect to rt stream on cs5
% makes sense for follwing reading of data streams 
% by getEmaData
% UoE machines' current ip numbers 
% New cs5 : 129.215.204.6
% New cs6 : 129.215.204.7
% See also GETEMADATA
%    cg 
%  $Date: 2008/10/12 20:55:00 $


concs5.name='cs5';
concs5.host='129.215.204.6';
concs5.port=30303;
concs5.timeout=10;

try,
    concs5=rtstream_connect(concs5);
catch, 
    error('connection failed');
end

