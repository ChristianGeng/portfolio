function [m,s,n]=meansdpr(data,printstr);
% MEANSDPR Compute mean sd and n of matrix with printing of results
% function [m,s,n]=meansdpr(data,printstr);
% meansdpr: Version 24.4.97
%
% Remarks
%     handles NaNs column by column
%     so slower than simply doing "mean(data)" etc., but more
%     informative if NaNs are expected.
%     Prints results with printstr as caption
%     expand to do pretty printing....??
%     suppress printing if nargin==1 ????
%     for n=0 returns NaN for mean and sd
%     note: print n_missing rather than n

        [nrow,ncol]=size(data);
        %return if zero....?????
        m=ones(1,ncol)*NaN;
        s=ones(1,ncol)*NaN;
        n=zeros(1,ncol);

        for ii=1:ncol
            vv=find(~isnan(data(:,ii)));
            n(ii)=length(vv);
            if n(ii) >0
               temp=data(vv,ii);
               m(ii)=mean(temp);
               s(ii)=std(temp);
            end;
        end;
        disp ([printstr ' Total n = ' int2str(nrow)]);
%        disp ('  Column       mean      std        n_missing');
%        disp ([(1:ncol)' m' s' (nrow-n)']);

         disp (num2stre(1:ncol));
%         disp ('Means');
         disp (num2stre(m));
%         disp ('Standard Deviations');
         disp (num2stre(s));
%         disp ('n_missing');
         disp (num2stre(nrow-n));
