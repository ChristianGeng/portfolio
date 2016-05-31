function sesscfg=NDIWaveParseSessionFile(infile)

% sessionDir="C:\\ndigital\\collections"
% sessionName="MySession"
% recLength=1000
% volumeId=2
% autoExport=0
% sensorNames=["Sensor 1","Sensor 2","Sensor 3","Sensor 4"]
% usedPorts=[1,2]
% portSROM=["C:\\Program Files (x86)\\Northern Digital Inc\\NDI WaveFront\\Wave5D.rom","C:\\Program Files (x86)\\Northern Digital Inc\\NDI WaveFront\\Wave5D.rom"]
% selectedSpeed=2

% A) The selectedSpeed Field: 
%
% NOTE: Altering the speed AFTER the first trial has been recorded is NOT
% reflected in used.cfg
% Coding: 
% 100Hz:  selectedSpeed: 1
% 200Hz:  selectedSpeed: 2
% 400Hz:  selectedSpeed: 4

% B) volumeId
%   300mm Cube      - volumeId: 2
%   500mm Cube      - volumeId: 3
% Other 500mm Cube  - volumeId: 1 % What is this??
%infile='HeadTest0\MySession_56\rawdata\used.cfg';

fid = fopen(infile);

tline = fgetl(fid);
evalstring=[strrep(tline,'"','''') ';'];
%disp(evalstring)
eval(evalstring);

while ischar(tline)
    %disp(tline)
    evalstring=['sesscfg.',strrep(tline,'"',''''),';'];
  %  disp(evalstring)
 %   disp(tline)
    eval(evalstring);
    tline = fgetl(fid);
end
fclose(fid);
clear ('fid','infile','tline')

if (sesscfg.selectedSpeed==1),
    sesscfg.samplerate=100;
elseif (sesscfg.selectedSpeed==2)
    sesscfg.samplerate=200;
elseif (sesscfg.selectedSpeed==4)
    sesscfg.samplerate=400;
else, warning(' sesscfg.samplerate not adequately defined!!');
end



    



