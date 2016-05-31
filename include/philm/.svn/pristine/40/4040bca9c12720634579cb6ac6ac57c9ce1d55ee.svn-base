function showz(mypath,mytrial,mychans,campflag)
% SHOWZ z-plane plot of AG500 signals
% function showz(mypath,mytrial,mychans,campflag)
% showz: Version 14.07.08
%
%   Description
%       Assumes raw data of real and imaginary part of signal as stored by
%       mcdiag (Windows system) or by getrawdata | sincosdemod (Linux system).
%       mypath: common part of file name
%           Windows: data assumed to be in [mypath 'amps\' mytrial '.amp'] and [mypath 'img\' mytrial '.img'];
%           i.e mypath will normally need to be specified with final backslash
%           Linux: data assumed to be in [mypath mytrial '.camp']
%       mytrial: Normally a numeric value. Will be expanded to 4 digits
%           with leading zeros.
%           Linux: Can also be empty, allowing camp files with name rather
%           than trial number to be loaded
%       mychans: Vector of channel numbers; no defaults
%       campflag: Flag to load linux-style camp files.
%           Default to true (1) on linux and false (0) on windows
%
%       Ideally all data should lie on the real axis
%       Prints various stats on deviation from ideal case, and plots each
%       sensor-transmitter combination (angle in z-plane and intercept with
%       imaginary axis printed in figure title)

functionname='showz: Version 14.07.08';

ndig=4;
ntran=6;
nchan=12;

trialstr='';
if ~isempty(mytrial)
    trialstr=int2str0(mytrial,ndig);
end;

campuse=0;

if isunix campuse=1; end;
if nargin>3 campuse=campflag; end;

if campuse
    tmpdata=loadcampb([mypath trialstr '.camp']);
    rr=imag(tmpdata); %!!!
    ii=real(tmpdata);
else

rr=loadampb([mypath 'amps' pathchar trialstr '.amp']);
ii=loadampb([mypath 'imgs' pathchar trialstr '.img']);
end;

phaseb=ones(nchan,ntran)*NaN;
rmsb=ones(nchan,ntran)*NaN;
imagxab=ones(nchan,ntran)*NaN;
imagsdb=ones(nchan,ntran)*NaN;

phaserb=ones(nchan,ntran)*NaN;
phaserbc=ones(nchan,ntran)*NaN;
intercb=ones(nchan,ntran)*NaN;
intercbc=ones(nchan,ntran)*NaN;


for iki=mychans
    hf(iki)=figure
    for iti=1:ntran
        ha(iti)=subplot(2,3,iti);
        rx=rr(:,iti,iki);
        ix=ii(:,iti,iki);
        plot(rx,ix);
        line(0,0,'marker','o','markersize',12,'linewidth',2);
        grid on;
        
        sigma=2.5;np=4;nscore=1;covflag=1;
        [xbar,sdev,com,eigval,eigvec,outind,eli,rmserror]=elli([rx ix],sigma,np,nscore,covflag);

        [bcof,bint]=regress(ix,[ones(length(rx),1) rx]);
        
        intercb(iki,iti)=bcof(1);
        intercbc(iki,iti)=abs(diff(bint(1,:)));
        phaserb(iki,iti)=atan(bcof(2))*180/pi;
        phaserbc(iki,iti)=abs(diff(bint(2,:)));
        
        disp(bcof);
        disp(bint);
%keyboard;
myphase=angle(complex(eigvec(1,1),eigvec(2,1)))*180/pi;
myphasex=angle(complex(xbar(1),xbar(2)))*180/pi;
disp([iki iti myphase rmserror]);
phaseb(iki,iti)=myphase;
rmsb(iki,iti)=rmserror;
imagxab(iki,iti)=mean(abs(ix));
imagsdb(iki,iti)=std(ix);
ht=title(str2mat(['S' int2str(iki) ' T' int2str(iti)],['Icpt. ' int2str(round(intercb(iki,iti))) ' Ang. ' num2str(phaserb(iki,iti),2)]));
drawnow
    
    end;
end;

disp('Phase');
disp(phaseb);
disp('rmserror');
disp(rmsb);
disp('average magnitude of imaginary part');
disp(imagxab);
disp('sd of imaginary part');
disp(imagsdb);

disp('phase from regression');
disp(phaserb);
disp('confidence interval of phase from regression');
disp(phaserbc);

disp('intercept from regression');
disp(intercb);
disp('confidence interval of intercept from regression');
disp(intercbc);

keyboard;

close all
