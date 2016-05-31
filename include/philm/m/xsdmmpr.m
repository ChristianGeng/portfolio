function [m,s,xmax,xmin,n]=xsdmmpr(data,printstr);
% XSDMMPR Compute mean, sd, max, min and n of matrix with printing of results
% function [m,s,xmax,xmin,n]=xsdmmpr(data,printstr);
% xsdmmpr: Version ??? (obsolete??, use statistics toolbox functions)
%
%handles NaNs column by column
%so slower than simply doing "mean(data)" etc., but more
%informative if NaNs are expected.
%Prints results with printstr as caption
%expand to do pretty printing....??
%suppress printing if nargin==1 ????
%for n=0 returns NaN for mean, sd, max and min
%note: print n_missing rather than n

[nrow,ncol]=size(data);
%return if zero....?????
m=ones(1,ncol)*NaN;
s=ones(1,ncol)*NaN;
xmax=ones(1,ncol)*NaN;
xmin=ones(1,ncol)*NaN;
n=zeros(1,ncol);

for ii=1:ncol
    vv=find(~isnan(data(:,ii)));
    n(ii)=length(vv);
    if n(ii) >0
        temp=data(vv,ii);
        m(ii)=mean(temp);
        s(ii)=std(temp);
        xmax(ii)=max(temp);
        xmin(ii)=min(temp);
    end;
end;
if nargin < 2 return; end;
disp ([printstr ' Total n = ' int2str(nrow)]);
%        disp ('  Column       mean      std        n_missing');
%        disp ([(1:ncol)' m' s' (nrow-n)']);

disp ('Means');
disp (m);
disp ('Standard Deviations');
disp (s);
disp ('Max');
disp (xmax);
disp ('Min');
disp (xmin);
disp ('n_missing');
disp (nrow-n);
