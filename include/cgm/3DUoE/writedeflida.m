function writedeflida(machineuser,outdirUser)

% machine='CS5'
% machine='CS6'
% cd /home/csop/matlab




outdir=pwd;

if nargin==0
    machine='CS60'; % UP
else 
    machine=machineuser;
end

if nargin>1
    outdir=outdirUser;
end
    
% outDir='/media/win-d/myfiles/Matlab/cgm/prompting/prompterAG501-0.1/'



addpath(outdir)

if strcmpi(machine,'CS6')
    lida.host='129.215.204.7';
    lida.port=30303;
    lida.machine='CS6'
    lida.dig='6'
elseif strcmpi(machine,'CS5')
    lida.host='129.215.204.6';
    lida.port=30303;   
    lida.machine='CS5'
    lida.dig='5'
elseif strcmpi(machine,'CS60')
    lida.host='141.89.97.192';
    lida.port=30303;
    lida.name='AG501';
    lida.machine='CS60'
    lida.dig='60'
elseif strcmpi(machine,'CS76')
    lida.host='194.94.12.68';
    lida.port=30303;
    lida.name='AG501';
    lida.machine='CS76'
    lida.dig='76'
elseif strcmpi(machine,'CS79')
    lida.host='141.20.144.42';      
    lida.port=30303;
    lida.name='AG501';
    lida.machine='CS79'
    lida.dig='79'    
end

outfilename=[outdir, '/lida_cfg.mat'];
disp(['saving lida cfg for ', machine, ' to  ', outfilename]);
save (outfilename,'lida');
% disp(['lida cfgs on path: '])
% what lida_cfg

