@echo off
rem D:\myfiles\Matlab\cgm\mex\gradDemodCpp\manualBuild\mexoptsmingw01Aug2012_32bit.bat
rem Generated by gnumex.m script in d:\myfiles\matlab\cgm\mex\gnumex
rem gnumex version: 2.04
rem Compile and link options used for building MEX etc files with
rem the Mingw/Cygwin tools.  Options here are:
rem Gnumex, version 2.04                       
rem MinGW linking                              
rem Mex (*.dll) creation                       
rem Libraries regenerated now                  
rem Language: C / C++                          
rem Optimization level: -O3 (full optimization)
rem Matlab version 7.13
rem
set MATLAB=C:\PROGRA~2\MATLAB\R2011b
set GM_PERLPATH=C:\PROGRA~2\MATLAB\R2011b\sys\perl\win32\bin\perl.exe
set GM_UTIL_PATH=d:\myfiles\matlab\cgm\mex\gnumex
set PATH=D:\PORTAB~2\OTHERP~1\MinGW\bin;%PATH%
set PATH=%PATH%;C:\Cygwin\usr\local\gfortran\libexec\gcc\i686-pc-cygwin\4.3.0
set LIBRARY_PATH=D:\PORTAB~2\OTHERP~1\MinGW\lib
set G95_LIBRARY_PATH=D:\PORTAB~2\OTHERP~1\MinGW\lib
rem
rem precompiled library directory and library files
set GM_QLIB_NAME=D:\myfiles\Matlab\cgm\mex\libs
rem
rem directory for .def-files
set GM_DEF_PATH=D:\myfiles\Matlab\cgm\mex\libs
rem
rem Type of file to compile (mex or engine)
set GM_MEXTYPE=mex
rem
rem Language for compilation
set GM_MEXLANG=c
rem
rem File for exporting mexFunction symbol
set GM_MEXDEF=D:\myfiles\Matlab\cgm\mex\libs\mex.def
rem
set GM_ADD_LIBS=-llibmx -llibmex -llibmat
rem
rem compiler options; add compiler flags to compflags as desired
set NAME_OBJECT=-o
set COMPILER=gcc
set COMPFLAGS=-c -DMATLAB_MEX_FILE 
set OPTIMFLAGS=-O3
set DEBUGFLAGS=-g
set CPPCOMPFLAGS=%COMPFLAGS% -x c++ 
set CPPOPTIMFLAGS=%OPTIMFLAGS%
set CPPDEBUGFLAGS=%DEBUGFLAGS%
rem
rem NB Library creation commands occur in linker scripts
rem
rem Linker parameters
set LINKER=%GM_PERLPATH% %GM_UTIL_PATH%\linkmex.pl
set LINKFLAGS=
set CPPLINKFLAGS=GM_ISCPP 
set LINKOPTIMFLAGS=-s
set LINKDEBUGFLAGS=-g  -Wl,--image-base,0x28000000\n
set LINKFLAGS= -LD:\myfiles\Matlab\cgm\mex\libs
set LINK_FILE=
set LINK_LIB=
set NAME_OUTPUT=-o %OUTDIR%%MEX_NAME%.mexw32
rem
rem Resource compiler parameters
set RC_COMPILER=%GM_PERLPATH% %GM_UTIL_PATH%\rccompile.pl  -o %OUTDIR%mexversion.res
set RC_LINKER=
