function pcscore=pcscores(data,eigvec,xbar,sd);
% PCSCORES Compute principal component scores
% function pcscore=pcscores(data,eigvec,xbar,sd);
% pcscores: Version 25.7.07
%
%   Syntax
%       data: Input data from which to compute principal component scores
%        eigvec: eigenvector matrix, from PC analysis
%                number of rows must equal number of columns in
%                data. Number of columns determines
%                number of principal component tracks generated:
%                calling program should select desired columns
%                from complete eigenvector matrix generated during PC analysis
%        xbar, sd: means and standard deviations, for normalizing
%              input variables, probably produced during PC analysis
%              vector length must be equal to number of columns in
%              data.
%       Either eigvec or sd can be empty (sd is also optional).
%           empty eigvec simply returns the normalized data
%           empty sd can be used as an alternative to a vector of ones for
%           the case where the covariance method has been used to calculate
%           the eigenvectors (See ELLI)

functionname='pcscores: Version 27.7.2007';

pcscore=[];

%datain=data;

[nrow,ncol]=size(data);

if size(xbar,1)~=1
    xbar=xbar';
end;

if size(xbar,2)~=ncol
    disp('pcscores: length of xbar vector is wrong');
    return;
end;

data=data-repmat(xbar,[nrow 1]);

if nargin>3
    if ~isempty(sd)
        
        if size(sd,1)~=1
            sd=sd';
        end;
        
        if size(sd,2)~=ncol
            disp('pcscores: length of sd vector is wrong');
            return;
        end;
        
        data=data./repmat(sd,[nrow 1]);
        
    end;
end;

if ~isempty(eigvec)
    if size(eigvec,1)~=ncol
        disp('pcscores: length of eigenvectors is wrong');
        return;
    end;
    data=data*eigvec;
end;

pcscore=data;
%keyboard;