REM ADD PATHS AND START MATLAB
set ADRIVE=D:

set PATH=%ADRIVE%\PortableApps\OtherProgs\MinGW\bin;%PATH%
set PATH=%ADRIVE%\myfiles\Matlab\cgm\mex\libs;%PATH%

REM libmx etc.
set PATH=C:\Program Files (x86)\MATLAB\R2011b\bin\win32;%PATH%
REM GPSVC etc. 
set PATH=C:\Windows\System32;%PATH%

PATH
REM CHOOSE THE MATLAB VERSION!
REM 32bit
REM "C:\Program Files (x86)\MATLAB\R2011b\bin\matlab.exe"
REM 64bit
REM "C:\Program Files\MATLAB\R2011b\bin\matlab.exe"

