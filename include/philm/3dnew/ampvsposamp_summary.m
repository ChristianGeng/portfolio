%myfile='ampvsposampstats_1_200';
myfile='ampvsposampstats_thr2_rep_801_1000';
%myfile='ampvsposampstats_401_600';
%myfile='ampvsposampstats_601_800';
load(myfile);
diary([myfile '_summary.txt']);
disp(myfile);
disp('mean results per sensor');
disp('raw residuals');
disp(nanmean(ad0'))
disp('residuals afer adjustmnt');
disp(nanmean(adp'))

disp('|intercept|')
disp(nanmean(abs(b1')))

disp('|percentage deviation of gradient|')
disp(nanmean(abs(100-(b2'*100))))

disp('mean results per transmitter');
disp('raw residuals');
disp(nanmean(ad0))
disp('residuals afer adjustmnt');
disp(nanmean(adp))

disp('|intercept|')
disp(nanmean(abs(b1)))

disp('|percentage deviation of gradient|')
disp(nanmean(abs(100-(b2*100))))

diary off
