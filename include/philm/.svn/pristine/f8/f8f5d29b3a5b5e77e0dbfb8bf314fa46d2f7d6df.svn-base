function freadcal(calfile, caloutfile)
% FREADCAL Reads e.g MKal calibration file and saves as errormap MAT file
% function freadcal(calfile, caloutfile)
% freadcal: Version ??
%
% with data transformation and scale to cm 


% values for data transformation
scaleinput=1/10;
scaleoutput=1/scaleinput;
r_cen=18.52717;
pifac=2*pi./360;
transa=pifac*[0 120 240];
transx=r_cen*cos(transa)
transy=r_cen*sin(transa)
x_cen=0; y_cen=0;


fid=fopen(calfile,'r')
message=ferror(fid)

while 1
   dum=fgetl(fid);
   [str, dum]=strtok(dum);
   if strcmp(str,'Tilt');
      break
   end;
end;
sensnr=[];
true_xy=[];
meas_xy=[];
while 1
   line=fgetl(fid);
   if line==-1, break; end;
   [str, line]=strtok(line);
   if strcmp(str,'Corr')
      dum=sscanf(line,'%f');
      sensnr=[sensnr dum(1)];
      meas_xy=[meas_xy; dum(2:3)'];
   elseif strcmp(str,'True')
      dum=sscanf(line,'%f');
      true_xy=[true_xy; dum(2:3)'];
   end;
end;
fclose(fid)
sensnr=sensnr';
data=[sensnr true_xy meas_xy];

size(data)
x_col=[2 4];
y_col=x_col+1;
data(:,2:5)=data(:,2:5)*scaleinput;
data(:,x_col)=data(:,x_col)+transx(3);
data(:,y_col)=data(:,y_col)+transy(3);

comment=['Calibration file: ', calfile, ' Data transformation to centre of helmet; scale cm'];

eval(['save ', caloutfile, ' data comment']);

      

