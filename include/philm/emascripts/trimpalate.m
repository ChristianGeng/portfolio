%example for preparation of palate trace for use in mtnew
clear variables
myfile='mat\dfgmj_mm1_ema_palocc_head_0004';
comment=[myfile ' = second midline palate trace'];
palatesensor=10;
outfile='mm1_palate';

figure;
%if no trimming required set trimvec to empty
%otherwise set to indices of portion of contour to retain
%trimvec=[];
%trial 4, second midline palate
trimvec=[3:59];

data=mymatin(myfile,'data');

datad=data(:,1:3,palatesensor);
plot(datad(:,2),datad(:,3))
title('sagittal plot')
pause
plot(datad)
title('xyz vs. time')
pause

%some primitive smoothing and decimation
datad(:,1)=decifir(ones(1,8)*1/8,datad(:,1));
datad(:,2)=decifir(ones(1,8)*1/8,datad(:,2));
datad(:,3)=decifir(ones(1,8)*1/8,datad(:,3));
datad=datad(1:4:end,:);
plot(datad)
grid on
title('xyz vs. time (smoothed)')
pause
disp('Use this display to decide where trimming is required');
disp('Set up variable trimvec by hand here, or edit script');
keyboard;

if ~isempty(trimvec)
%trim unwanted parts
datad=datad(trimvec,:);
plot(datad)
grid on
title('xyz vs. time (smoothed and trimmed)')
pause

end;

plot(datad(:,2),datad(:,3));
axis equal
title('sagittal plot (final version)')
pause

%store so can be used by mtnew
data=datad;
descriptor=str2mat('palate_x','palate_y','palate_z');
unit=repmat('mm',[3 1]);

save(outfile,'data','descriptor','unit','comment');

