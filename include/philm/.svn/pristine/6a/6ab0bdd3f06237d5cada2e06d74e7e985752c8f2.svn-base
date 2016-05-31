function [grad,yinter,xinter]=pcreg(xbar,sdev,eigvec);
% PCREG Express first eigenvector as "regression" equation
% function [grad,yinter,xinter]=pcreg(xbar,sdev,eigvec);
%   result is probably rubbish if eigenvectors have more than two elements

grad=(eigvec(2,1)*sdev(2))./(eigvec(1,1)*sdev(1));
yinter=xbar(2)-(grad*xbar(1));
xinter=(-yinter)./grad;
