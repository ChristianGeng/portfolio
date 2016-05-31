% Mini HOWTO: 
% + Start cmd and potentially also matlab
% + cd to this directory
% + run this file
%

% Dort liegt der libmex.dll bei mir
% libmex, libmx
% C:\Program Files (x86)\MATLAB\R2011b\bin\win32
% C:\Program Files (x86)\MATLAB\R2011b\bin\win32
% Potentiell 32bit Versionen benötigt!
% SYSNTFY.DLL
% IESHIMS.DLL
% SYSNTFY.DLL


% GPSVC.DLL
% C:\Windows\System32
% http://www.microsoft.com/en-us/download/details.aspx?id=29


cd D:/myfiles/Matlab/cgm/mex/gradDemodCpp/manualBuild/
mex  -v  -f  mexoptsmingw01Aug2012_32bit.bat  -Igdi32 -ID:\PortableApps\OtherProgs\MinGW\include ../src/gradDemod.cpp 
% mex  -v  -f  mexoptsmingw01Aug2012_64bit.bat  -Igdi32 -ID:\PortableApps\OtherProgs\MinGW\include ../src/gradDemod.cpp 


mex  -v  -f   mexoptscygwin01Aug2012_64bit.bat  ../src/gradDemod.cpp 

movefile gradDemod.mexw32 ../Debug/
