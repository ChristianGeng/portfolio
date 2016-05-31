function trimpalate(myfile,mysensor,tracename,tracecomment)
% function trimpalate(myfile,mysensor,tracename,tracecomment)
% TRIMPALATE: View palate contours, smooth and trim
% trimpalate: Version 07.12.2012
%
%   Syntax
%       myfile: Input file
%       mysensor: Sensor to use
%       tracename: appended to myfile to form output file name
%       tracecomment: Free comment to describe task on which trace is based
%
%   Notes:
%       Set the variables trimstart and trimend by hand in keyboard mode to
%       trim the trace to the desired portion.
%       Input coordinates are assumed to be
%       x: left-right
%       y: anterior-posterior
%       z: vertical

functionname='trim palate: Version 07.12.2012';

%myfile='DFG9_S2_ema_head_0757';
%tracename='_fingerpalate';
%tracecomment='Sagittal finger trace';
%mysensor=7;

trimstart=1;
trimend=[];

decifac=4;
decifac2=decifac*2; %length of moving average filter
load(myfile);
datad=data(:,1:3,mysensor);
plot(datad(:,2),datad(:,3))
xlabel('Y'); ylabel('Z');
title('sagittal');
disp('hit any key to continue');
pause
plot(datad)
ylabel('x, y, z')
xlabel('raw samples');
title('Time plot');
disp('hit any key to continue');
pause
mycoff=ones(1,decifac2)*1/decifac2;
datad(:,1)=decifir(mycoff,datad(:,1));
datad(:,2)=decifir(mycoff,datad(:,2));
datad(:,3)=decifir(mycoff,datad(:,3));
datad=datad(1:decifac:end,:);
plot(datad);
title('Time plot');
xlabel('smoothed samples');
ylabel('x, y, z');

grid on
disp('Define trimstart and trimend from smoothed samples. Contour will be trimmed after ''return''')
keyboard;

if isempty(trimend) trimend=size(datad,1); end;
datad=datad(trimstart:trimend,:);
plot(datad)
title('Time plot (trimmed data)');
xlabel('smoothed samples');
ylabel('x, y, z');

grid on
disp('hit any key to continue');
pause
plot(datad(:,2),datad(:,3));
title('Sagittal (trimmed data)');
xlabel('Y'); ylabel('Z');
axis equal
disp('hit any key to continue');
pause

data=datad;
descriptor=str2mat('palate_x','palate_y','palate_z');
unit=repmat('mm',[3 1]);

tmpc=['Input file: ' myfile crlf 'Trace comment: ' tracecomment crlf 'Trim start, end: ' int2str([trimstart trimend]) crlf];
comment=[tmpc comment];
comment=framecomment(comment,functionname);
samplerate=samplerate/decifac;
save([myfile tracename],'data','descriptor','unit','comment','samplerate');


