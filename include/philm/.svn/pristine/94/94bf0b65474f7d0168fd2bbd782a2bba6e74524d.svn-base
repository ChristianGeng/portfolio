function model=pc2model(pcscore,eigvec,xbar,sdev)
% PC2MODEL Generate modelled data values from PC scores
% function model=pc2model(pcscore,eigvec,xbar,sdev)
% pc2model: Version 02.04.2013
%
%	Description
%		eigenvector matrix assumed organized with each eigenvector as 1 column
%		If pcscore has less columns than eigvec it is padded with zeros
%		xbar and sdev are row vectors
%
%	See also
%		ELLI
%

[m,nscore]=size(pcscore);
n=size(eigvec,2);

%checks on size of xbar and sdev??
%also check nscore not larger than number of eigenvectors (n)?

%compute model
tmpdat=zeros(m,n);
tmpdat(:,1:nscore)=pcscore;
%Note: if eigenvectors have length of 1, transpose corresponds to inverse
model=tmpdat*eigvec';
model=model.*repmat(sdev,[m 1]);
model=model+repmat(xbar,[m 1]);
