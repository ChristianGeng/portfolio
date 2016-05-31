function [xbar,sdev,com,eigval,eigvec,outind,eli,rmserror]=elli(datin,sigma,np,nscore,covflag);
% ELLI Principal Components analysis
% function [xbar,sdev,com,eigval,eigvec,outind,eli,rmserror]=elli(datin,sigma,np,nscore,covflag);
% elli: Version 02.04.2013
%
%	Purpose
%		Do principal component analysis and returns various basic statistics.
%		Also scan for outliers with respect to the principal component axes (up to the nscore'th PC)
%		For 2D input data, return the coordinates of an ellipse enclosing the data
%
%	Syntax
%
%		Input args:
%			datin: Input data, columns correspond to raw variables
%			sigma: Factor by which to multiply standard deviation along the PC axes
%				to give threshold for detecting outliers in the PC space and to
%				determine length of ellipse axes
%			np:    Number of points on circumference of ellipse
%			nscore:Number of PCs to determine. An m*nscore matrix of the PC scores is stored in
%				MAT file PCSCORE
%			covflag:Optional. If present and not zero use covariance rather than correlation method
%				See further notes below
%			Currently no defaults for sigma, np or nscore
%
%		Output args:
%			Mean, sd, correlation or covariance matrix, eigenvalues and eigenvectors
%				Note: Eigenvalues output as row vector, i.e similar to mean and sd
%			outind: Row index of observations containing outliers with respect to any of the first nscore'th PCs
%			eli: 2 column matrix with x and y coordinates of ellipse
%				n.b ellipse will normally have np+1 points, i.e join up 0 and 2pi
%				np=4 will return coordinates at the ends of the axes of the
%				ellipse, i.e at 0, pi*0.5, pi, pi*1.5 (and 2pi)
%				(major axis from index 1 to 3, minor axis from index 2 to 4)
%			rmserror: RMS differnce between original data and model based on nscore PCs
%
%	Remarks
%		On choice of correlation or covariance matrix as input to eig function
%		see SAS handbook on principal components, p.??
%		The two methods may give slightly different results in detecting outliers
%		For input data that is geometrically interpretable (e.g tongue x and y coordinates)
%		then the covariance method is probably better. In particular, for the simple 2-dimensional case
%		the following parameterizations of the ellipse characterizing the distribution are
%		easy to derive:
%			1. Ellipse area: pi*prod(sqrt(eigval))
%			2. Ellipse shape (one possibility): sqrt(eigval(2))/sqrt(eigval(1))
%			3. Ellipse orientation: angle(eigvec(1,1)+i*eigvec(2,1))
%
%	See also
%		PC2MODEL: e.g further analysis of model error; PCFSF and PCFSPLO: e.g plot tongue shapes related to individual PCs

do_cov=0;
if nargin>4 do_cov=covflag; end;
[n,nfac]=size (datin);

%could eliminate NaNs but then e.g indices of outliers will be meaningless
if any(isnan(datin(:)))
    disp('ELLI: unable to proceed because of NaNs in data');
    xbar=[];sdev=[];com=[];eigval=[];eigvec=[];outind=[];eli=[];rmserror=[];
    return;
end;



%compute normalized version of data
%not initially required for PC analysis but needed in subsequent steps if
%factor scores and outliers are determined using the correlation rather than the covariance approach
%for covariance approach use a dummy array of sds=1

xbar=mean(datin);
sdev=std(datin);
if do_cov sdev=ones(1,nfac);end;
%m1=ones(n,1);
anor=datin-repmat(xbar,[n 1]);
anor=anor./repmat(sdev,[n 1]);

%find principal axes
% give choice of covariance or correlation matrix???
%instead of using corrcoef, could also use cov with normalized data

if ~do_cov 
    disp('using correlation method');
    com=corrcoef(datin); 
    
end;

if do_cov 
    disp('using covariance method');
    com=cov(datin);
end;

%note. SAS ellipse routine divides by n, but MATLAB cov function divides by n-1
%cov=(datin'*datin)./n

%get total variance, for correlation matrix this is simply equal to the number of variables

totalvar=sum(diag(com));
%disp (['Total variance: ' num2str(totalvar)]);
[eigvec,valtmp]=eig(com);

%eigenvalues are returned as a diagonal matrix; extract the diagonal to a row vector

eigval=(diag(valtmp))';

%note: When the correlation matrix is used,
%eigenvalues > 1 indicate that the corresponding
%factor explains more of the variance than a single raw variable.
%Variance explained by a factor is equal to eigenvalue/totalvariance;
%thus in correlation case, with two variables, an eigenvalue
%of 2 means 100% of the variance is explained by that factor

%Sort the eigenvalues by size, and then sort the eigenvectors the same way

[dodo,is]=sort(-eigval);
eigval=eigval(is);
eigvec=eigvec(:,is);
%disp ('Eigenvalues');
disp (['Total variance : ' num2str(totalvar) ' , Eigenvalues: ' num2str(eigval(1:min([n nfac])))]);
%disp ('Eigenvectors');
%disp (eigvec);

%The length of the eigenvectors is 1
%Thus, for the 2-D case they represent a point on the unit circle.
%Multiplying by the eigenvector matrix rotates the data to a coordinate system with axes
%defined by the eigenvectors.
%It also corresponds to forming the weighted sum of the n raw variables,
%the weights being given by the n elements of each eigenvector
%Function pc2model is used to transform from PC scores back to
%the space of the original variables.
%This is used below to determine rms error when modelling the data using a limited
%number of principal components, and also to generate ellipses for 2D data.
%(pcfsf also uses this function on a special set of PC scores to get e.g tongue configurations)

%generate factor scores ========================
%for covariance case use non-normalized data?
%A more standard notation might be to think of each observation
% of raw data as a column vector, which is transormed to a column
%vector of PC scores by s=E'*a;
%This computes the inner product of each eigenvector with the vector of coordinates (variables)
% In other words it computes the projection of the coordinate vector on the eigenvector
% see Jordan, p.379 ff.
%Another way of thinking of this in two dimensions is that an xy datapoint is rotated by the negative
% of the angle defined by the eigenvector, i.e a point lying on the first eigenvector will
% end up on the positive x axis


%The following arrangement saves some fiddling around with transposition

score=anor*eigvec;

%Save scores to MAT file, compute RMS error and outliers
%if nscore NE 0

if nscore==0
   outind=[];
end;
if nscore>0
   pcscore=score(:,1:nscore);
   save pcscore pcscore;
   clear score;
   model=pc2model(pcscore,eigvec,xbar,sdev);
   modelerror=datin-model;
   rmserror=modelerror.^2;
   rmserror=sum(sum(rmserror));
   rmserror=rmserror./(n*nfac);
   rmserror=sqrt(rmserror);
   
   %outliers=====================================
   %The variance of each factor is equal to the eigenvalue
   %thus outliers can be detected as e.g those values outside sigma*sqrt(eigenvalue);
   
   eigdev=sqrt(eigval(1:nscore))*sigma;
   outliers=abs(pcscore)>repmat(eigdev,[n 1]);
   outtmp=outliers;
%   disp ('Outliers (per factor)');
%   disp(sum(outtmp));
   outind=find(any(outtmp'));
   %check this special case????
   if (nfac==1) outind=find(outtmp);end
    totaloutliers=length(outind);
    if totaloutliers>0
   disp (['Outliers overall: ' int2str(totaloutliers) ' , Outliers per factor: ' int2str(sum(outtmp))]);
end;

end;

if nfac<2
   eli=[NaN NaN;NaN NaN;NaN NaN];
else
   
   %Ellipse generation=================================
   %Basically the same procedure as generating modelled data from
   %principal component scores.
   %n.b this is only worked out for the 2-D case
   %Thus we generate modelled data with 2 PCs and retain only 2 raw variables from the model
   %it could be expanded to 3 dimensions e.g one ellipse for each pair of dimensions
   %each ellipse having x,y and z coordinates, or use matlab sphere function????
   
   %compute desired size of ellipse radii
   
   a=eigdev(1);
   b=eigdev(2);
   
   %the SAS IML package uses the following
   %if the specification is made in terms of a desired probability level p
   %c=-2*log(1-p)
   %a=sqrt(c*????eigval(1));
   %b=sqrt(eigval(2));
   
   %generate a vector from 0 to 2pi, at which to evaluate the ellipse coordinates
   %NB: this vector will probably have np+1 points
   
   pistep=(2*pi)./np;
   vp=(0:pistep:2*pi)';
   s1=cos(vp)*a;
   s2=sin(vp)*b;
   eliscore=[s1 s2];
   
   model=pc2model(eliscore,eigvec,xbar,sdev);
   
   eli=model(:,1:2);
   %              keyboard;
   
end;




sdev=std(datin);
