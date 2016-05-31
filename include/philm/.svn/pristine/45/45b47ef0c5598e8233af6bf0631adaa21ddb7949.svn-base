function [adatout,delayuse]=mt_praatstretch(adat,delayfac,audiosf);
% MT_PRAATSTRETCH Use praat to stretch audio. See MT_MOVIE or MT_VIDEO for details
% function [adat,delayuse]=mt_praatstretch(adat,delayfac,audiosf);
% mt_praatstretch: Version 24.1.07

%   Updates
%       1.07. For windows use external file with path to praat program, to
%       avoid problems with subversion control

persistent praatcall

adatout=adat;
delayuse=delayfac;

aloopx=log2(delayfac);
aloop=round(aloopx);


%Currently only implemented for cases where delayfac is a power of 2
if aloop>=1 & aloop==aloopx
    
    if isempty(praatcall)
        
        if ispc
            %this will need editing
            
            if exist('praatpath.mat','file')
                praatpath=mymatin('praatpath','praatpath');
                praatcall=[praatpath pathchar 'praatcon'];
                if any(isspace(praatcall)) praatcall=['"' praatcall '"']; end;
            else
                disp('MT_PRAATSTRETCH: Using Praat to stretch audio');
                disp('Please create a file named praatpath.mat somewhere on matlab''s search path.');
                disp('This must contain a variable named praatpath showing the location of the praatcon executable (without final backslash)');
                disp('e.g praatpath=''c:\program files\praat''; save praatpath praatpath');
                disp('Note: do not place this file in any directory that is automatically updated by subversion');
                return;
            end;
            
        else
            %assume no difference between praat and praatcon on unix systems
            %and also assume locaton of praat executable is known to the systen
            praatcall='praat';
            
        end;
    end;
    
    
    
    scriptfile=[pwd pathchar 'praatstretch.txt'];
    if exist(scriptfile,'file') ~=2
        disp('Making praat script');
        fid=fopen(scriptfile,'w');
        if fid<=2
            disp('Problem opening praat script for writing');
            return
        end;
        ss=['Read from file... ' pwd pathchar 'tst.wav' crlf];
        
        ss=[ss 'Lengthen (PSOLA)... 75 600 2' crlf];
        ss=[ss 'Write to WAV file... ' pwd pathchar 'tst_2.wav'];
        
        try
            ccc=fwrite(fid,ss,'uchar');
            fclose(fid);
        catch
            disp('problem writing to praat script');
            disp(lasterr);
            return;
        end;
        
    end;        %script does not exist
    
    for iii=1:aloop
        wavwrite(0.9*(adat/max(abs(adat))),audiosf,16,'tst');    %e.g for manipulation with praat
        
        [status,result]=system([praatcall ' praatstretch.txt']);
        if status
            disp(praatcall);
            disp('Unable to use praat to stretch audio');
            disp(result);
            disp('Try deleting praatstretch.txt in your working directory and trying again');
            if ispc
                disp('Also check the path to praat in praatpath.mat is correct');
                disp('Here is its location:');
                which('praatpath.mat');
            end;
            
            return;
        end;
        
        [adat,tmpsf]=wavread('tst_2');
        
    end;
    delayuse=1;
    adatout=adat;
end;        %aloop>1

