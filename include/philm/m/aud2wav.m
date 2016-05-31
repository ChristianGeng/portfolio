function aud2wav(myname,maxtrial,mychan,myfac);
% AUD2WAV Convert matlab files of audio data to WAV
% function aud2wav(myname,maxtrial,mychan,myfac);
% aud2wav: Version 17.01.2012
%
%   Description
%       myname: common part of input file name (including path)
%           output is placed in directory wav'mychan' below the working
%           directory (this directory is created if necessary)
%       maxtrial: Trial number of last trial to process. N.B this
%           determines the number of digits in trial number to add to 'myname'
%           to form full file name. May need leading zeroes in 'myname'
%       mychan: Number of the column in the data variable of the input that
%           is to be exported (i.e currently output files are always mono)
%       myfac: Data is multiplied by this value before output. Output data
%           must be in the range +/- 1.
%           Normally the input data is first scaled by the program to
%           correspond to the input range of the acquisition hardware.
%           So if the data was recorded with an input range of +/- 5V then
%           myfac should be 1/5 (actually may need to be slightly smaller
%           for Sony DAT and Sony Ex as they have a small amount of
%           headroom above the nominal input range)
%           If myfac is missing then each trial is scaled individually to the
%           full range and the scaling factor used is printed out. So a first
%           pass of the program can be used to determine an appropriate scaling
%           factor for all trials (some statistics on the factors are printed at the end)
%   Updates
%       remove need for stats toolbox to be present


ndig=length(int2str(maxtrial));

wavpath=['wav' int2str(mychan)];
mkdir(wavpath);

ipin=1;
ipi=findstr(pathchar,myname);
if ~isempty(ipi) ipin=ipi(end)+1; end;

facbuf=ones(maxtrial,1)*NaN;

for ii=1:maxtrial
    try
        namein=[myname int2str0(ii,ndig)];
        scalefactor=1;
        signalzero=0;
        load(namein);
        dataout=double(data(:,mychan));
        nchan=size(data,2);
        if length(scalefactor)>=nchan
            dataout=dataout*scalefactor(mychan);
        else
            dataout=dataout*scalefactor(1);
        end;

        if length(signalzero)>=nchan
            dataout=dataout+signalzero(mychan);
        else
            dataout=dataout+signalzero(1);
        end;




        if nargin>3
            myfacuse=myfac;
        else
            myfacuse=1/(max(abs(dataout))*(32768/32767));
            disp(['Trial ' int2str(ii) ', factor ' num2str(myfacuse)]);
        end;

        dataout=dataout*myfacuse;

        facbuf(ii)=myfacuse;
        nameout=[wavpath pathchar namein(ipin:end) '.wav'];
        wavwrite(dataout,samplerate,16,nameout);
    catch
        disp(ii)
        disp('trial missing?');
        disp(lasterr);
    end;

end;
vnon=find(~isnan(facbuf));
facbuf=facbuf(vnon);

disp(['Factor mean, std, max and min : ' num2str([mean(facbuf) std(facbuf) max(facbuf) min(facbuf)])]);
