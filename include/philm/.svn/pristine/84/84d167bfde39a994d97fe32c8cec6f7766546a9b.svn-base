function config=pcfsf(xbar,sdev,eigval,eigvec,nscore,facval);
% PCFSF  compute e.g tongue configurations from factor scores
% function config=pcfsf(xbar,sdev,eigval,eigvec,nscore,facval);
% pcfsf: Version 6.5.97
%
% Description
%   Generates modelled data from a set of PC scores, for special
%   case where all scores except one are zero.
%
% Syntax
%   configurations will be generated at +/- facval of each factor
%   output arg config has m=number of raw variables and
%   n = 2*nscore (+facval in 1:nscore; -facval adjcacent )
%   xbar, sdev and eigval assumed to be row vectors

        %the square root of the eigenvalues is the standard deviation
        %of the factor scores
        %multiplying an eigenvector by the square root of the corrensponding
        %eigenvalue gives the correlation coefficients between the
        %factor and each of the raw variables


        %assume rows correspond to raw variables and columns to factors


	factorsd=sqrt(eigval(1:nscore))*facval;

        myscore=diag(factorsd);
        myscore=[myscore;(-myscore)];
        model=pc2model(myscore,eigvec,xbar,sdev);

        config=model';
