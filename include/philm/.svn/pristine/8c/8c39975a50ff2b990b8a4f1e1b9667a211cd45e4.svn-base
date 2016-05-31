function FIXPRAATTEXTGRIDLONG2SHORT(mypath)
% fixpraattextgridlong2short Convert praat textgrids from long to short
% function fixpraattextgridlong2short(mypath)
% fixpraattextgridlong2short: Version 03.07.2013
%
%   Syntax
%       specify mypath without path character
%       Note: For Windows the the location of
%       praatcon should be specified in praatpath.mat (which should
%       contain a variable 'praatpath' (ommit final pathchar))
%
%   Notes
%       In the working directory it will be necessary to first create a text file
%       called fixgridlong2shortbase.txt containing the following lines (omitting
%       '%' at start of each line):
%           Read from file... 'P2''P1'
%           Write to short text file... 'P2''P1'
%           Remove

praatcall='"c:\program files\praat\praatcon"';

            if exist('praatpath.mat','file')
                praatpath=mymatin('praatpath','praatpath');
                praatcall=[praatpath pathchar 'praatcon'];
                if any(isspace(praatcall)) praatcall=['"' praatcall '"']; end;
            end;
            



%TextGrid written as it appear on unix systems
mypath=[mypath filesep];
ss=dir([mypath filesep '*.TextGrid']);

nfile=length(ss);

for ii=1:nfile
    myfile=ss(ii).name;
    disp(myfile);
    paramsub('fixgridlong2shortbase.txt','fixgridlong2shortpraat.txt',myfile,mypath);
        [status,result]=system([praatcall ' fixgridlong2shortpraat.txt']);
        if status
            disp('Unable to use praat to modify textgrid');
            disp(result);
            return;
        end;
end;

