function [thoscal,abdscal]=calpro (datin,calchan,calcut,anacut,zerocut);
% CALPRO Analyze Respitrace calibration
% [thoscal,abdscal]=calpro (cal1t,cal1a,cal1s,calcut,icut,icutz1,icutz2,spadth);
% calpro: Version 6.96, (call from mmstf)
%
%datin: should be copy of data buffer, data already scaled in volts
%calchan: vector of the colums for thorax, abdomen and spiro in datin
%calcut: n*2 vector of cut boundaries
%anacut: cut number of analysis data
%zerocut: cut numbers of spiro zero data (i.e can be vector)
%
%Returns factors to convert RIP signals from volts to litres
% No measure of the goodness of fit to the spirometer signal
% is currently returned, but predicted signal can be examined graphically
% Results should also be compared with calibration based on the isovolume
% manoeuvre if possible
%Currently two procedures:
% 1. determine regression coefficients to give best least squares prediction
% of spirometer signal from the 2 differentiated respitrace signals
% this is (probably) the same as the procedure given in Finsterwald p.93ff
% This will work most successfully if the relative contribution of thorax
% and abdomen to the flow exhibits some variety over the measurement
% sequence. It has been suggested in the literature (refs. below)
% that this can
% be achieved by performing measurements in different body positions
% e.g lying, standing. However, it is also possible that
% respiratory cycles in a single posture exhibit sufficient variety
% in relative contributions to give an acceptable solution.
% 2. In order to check the above, a second procedure is carried out
% based on the respiratory literature.
% See Watson et al. (1981) "Calibration procedures for the respiratory inductive
% plethysmograph", in Papers on Respiratory Medicine,
% ISAM-GENT-1981, pp. 269- 284, Academic Press.
% Chadha et al. (1982) "Validation of respiratory inductive
% plethysmography using different calibration procedures" , Am Rev Respir Dis
% 125, 644-649.
% Thorax and abdomen signals are normalized by being divided by the
% spirometer signal. When the normalized signals are plotted against
% each other they should show an observable negative correlation if
% desired variety in relative contributions actually occurs.
% The desired RIP scaling factors are then derived from the intercepts
% with the x and y axes, specifically 1/intercept.
% Reason: When one respiratory component is zero, the other one must
% be scaled to equal the spirometer signal.
% The trouble with this method is that unstable values arise when the
% spirometer signal is close to zero.
% Input parameter spadth allows a band around zero to be eliminated
% This is specified in AD units. Try a value of about 16
% Also a multistage sifting out of outliers is performed.
%
%preliminary
%two possible cuts for spiro zero
%first subtract mean from all signals
%for RIP they are arbitrary anyway
%and for SPIRO overall mean should correspond very closely to
%zero offset in the zero airflow portions of the signal
%for long sequences integrated air flow should be zero
%otherwise something funny is going on
%subject expanding like a balloon?
%
%sort out input arguments
	if (length(calchan)~= 3) error ('Bad channel vector'); end;
	maxchan=max(calchan);
	[datrow,datcol]=size(datin);
	if (maxchan>datcol) error ('Data matrix and channel numbers do not match'); end;

	%threshold for eliminating small spiro values
	% determined from spthcon*std(spirozero)
	spthcon=10;
	%should be input arg
	sf=100;

	lastdat=max(calcut(:,2));
	lastdat=round(lastdat*sf)+1;
	disp (['Last data point ' int2str(lastdat)]);
	cal1t=datin(1:lastdat,calchan(1));
	cal1a=datin(1:lastdat,calchan(2));
	cal1s=datin(1:lastdat,calchan(3));



cal1t=cal1t-mean(cal1t);
cal1a=cal1a-mean(cal1a);
cal1s=cal1s-mean(cal1s);


%get spiro zero data
	nz=length (zerocut);
	disp (['# zero cuts ' int2str(nz)]);
	spiroz=[];
	for nnz=1:nz

?????
		spcut=calcut(nnz,:);
		spcut=round(spcut*sf);
		spcut=spcut+1;
		%disp ('Indices of zero cut');
		%disp ([nnz spcut]);
		i1=spcut(1);i2=spcut(2);
		spiroz=[spiroz;cal1s(i1:i2)];
	end;


	spoff=mean(spiroz);
	spoffsd=std(spiroz);
	
	disp ('Spiro zero and sd');
	disp ([spoff spoffsd]);




n=length(cal1t);
	disp (['Input data ' int2str(n)]);
td=diff(cal1t);
ad=diff(cal1a);
td=td(1:n-2)+td(2:n-1);td=td./2;
ad=ad(1:n-2)+ad(2:n-1);ad=ad./2;
sp=cal1s(2:n-1)-spoff;
sp=sp*(-1);
%scale to physical units
%6.96, cancelled, assume input data already in volts
%advolt=5./2048;
%td=td*advolt;
%ad=ad*advolt;
%sp=sp*advolt;
%spirometer scaling 5V = 4 l/s, see Finsterwald p.32
spscal=4./5;
%temp. scale differntiated RIP to Volt/s
ripscal=sf;
td=td*ripscal;
ad=ad*ripscal;
sp=sp*spscal;
%Determine threshold for eliminating spirometer values close
% to zero, which may cause problems when normalizing RIP signals
%for second method
%obviously division by zero is a problem, but also a constant level
%of noise (and also slight offset drift??)
%will cause the result of the division to fluctuate more for
%low amplitude signals
%use standard deviation of spiro zero signal
%spthcon is a constant, e.g 10, see above
spthresh=spthcon*spoffsd*spscal;
%rip scale factor determined below thus converts RIP in
%V/s to l/s (or Volts to litres)
decfac=5;
td=decimate (td,decfac,'fir');
ad=decimate (ad,decfac,'fir');
sp=decimate (sp,decfac,'fir');
sf=sf./decfac;
sf2=sf./2;
[bcof,acof]=butter (5,2./sf2);
tdf=filtfilt(bcof,acof,td);
adf=filtfilt(bcof,acof,ad);
spf=filtfilt(bcof,acof,sp);

%data is now decimated to 20 Hz and lp filtered at 2 hz
%further processing first extracts desired segment using cut file
%
spcut=calcut(anacut,:);
spcut=spcut*sf;
spcut=spcut+1;
i1=spcut(1);i2=spcut(2);

tde=tdf(i1:i2);
ade=adf(i1:i2);
spe=spf(i1:i2);
%
%for better comparison with second procedure reinsert eliminatio
%of spiro values near zero here


%use PC procedure to examine for outliers
     sigma=2.5;
     neli=4; %point in ellipse, dummy
     nscore=0; %don't store pc scores
     allsig=[spe tde ade];
[xq,s,corrmat,eigval,eigvec,out,eli]=elli(allsig,sigma,neli,nscore);
disp ('Correlation matrix for Spiro, Thorax, Abdomen');
disp(corrmat);
	thor2=corrmat (1,2)^2;
	abdr2=corrmat (1,3)^2;
     spirosd=s(1);
	%this is printed by elli   
	%disp ('Outliers')
	   %disp (length(out))
%           allsig(out,:)=[];
%First procedure
%Prediction of spiro from differntiated thorax and abdomen
%

ll=length(tde);
e=ones (ll,1);
A=[e tde ade];
beta=A\spe;
disp ('Regression coefficients');
%first term should be negligible
disp (beta);
thoscal=beta(2);
abdscal=beta(3);
thoweight=thoscal./abdscal;
disp ('Thorax and abdomen weight, and ratio')
disp ([thoscal abdscal thoweight]);
%compare measured and predicted spirometer signal
spep=A*beta;
cortmp=corrcoef ([spe spep]);
cumr21=cortmp(1,2)^2;
disp ('Variance explained: Thorax, Abdomen, Combined');
disp ([thor2 abdr2 cumr21]);
prederror=abs(spe-spep);
perrorx1=mean (prederror);
perrors1=std(prederror);
disp ('Absolute error: mean, sd. Spiro sd');
disp ([perrorx1 perrors1 spirosd]);

htemp=gcf;
hp=figure;

plot (spe,'w.');hold on;plot(spep,'r.');

pause
%
%now perform 2nd procedure
%eliminate spiro near zero
%This shouldn't be necessary for the first procedure
%but is done to give a better comparison with second procedure
     spzero=find (abs(spe)<spthresh);
     disp ('Number of zero spiro values eliminated');
     disp(length (spzero));
     tde(spzero)=[];
     ade(spzero)=[];
     spe(spzero)=[];

%
tn=tde./spe;
an=ade./spe;
nor=[tn an];
sigma=2.5;
neli=4; %point in ellipse, dummy
nscore=0; %don't store pc scores
nout=2;   %number of passes thru stats procedure with elimination of outliers
[xq,s,corrmat,eigval,eigvec,out,eli]=elli(nor,sigma,neli,nscore);
disp ('Initial correlation coefficient');
disp (corrmat)

	   for outloop=1:nout
	   disp ('Removing outliers')
	   %disp (length(out))
	   nor(out,:)=[];
[xq,s,corrmat,eigval,eigvec,out,eli]=elli(nor,sigma,neli,nscore);
	   disp ('Correlation coefficient')
	   disp (corrmat)
	   [pcgrad,pcyint,pcxint]=pcreg(xq,s,eigvec);
	   disp ('PPC, PXY, PYX')
	   ppc=[pcgrad pcyint pcxint];
	   pxy=polyfit(nor(:,1),nor(:,2),1);
	   pyx=polyfit(nor(:,2),nor(:,1),1);
	disp ([ppc pxy pyx]);
%end of statistics/outliers loop
end

%err1=nor(:,2)-polyval(p,nor(:,1));

%Scaling factors are 1/intercept
% y intercept for abdomen, x intercept for thorax
% ppc contains required values for principle components method
% For regression method (polyfit) use second term of pxy and pyx respectively

abdscal2=1./ppc(2);
thoscal2=1./ppc(3);
thoweight2=thoscal2./abdscal2;
disp ('Thorax and abdomen weight, and ratio (2nd method')
disp ([thoscal2 abdscal2 thoweight2]);
hold off;
plot(nor(:,1),nor(:,2),'o');
axis ([0 5 0 5]);

pause

tds=tde*thoscal2;
ads=ade*abdscal2;
spep=tds+ads;

cortmp=corrcoef ([spe spep]);
cumr22=cortmp(1,2)^2;
disp ('Combined variance explained (2nd method)');
disp (cumr22);
prederror=abs(spe-spep);
perrorx2=mean (prederror);
perrors2=std(prederror);
disp ('Absolute error: mean, sd. Spiro sd');
disp ([perrorx2 perrors2 spirosd]);



plot (spe,'w.');hold on;plot(spep,'r.');hold off;

pause

keyboard

figure(htemp);
