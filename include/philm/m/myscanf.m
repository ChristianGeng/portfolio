function [data,labels]=myscanf(myname,labgo,nlab,nvar,nskip,nmax);
% MYSCANF Scan in a file with character and numeric variables, e.g from SAS output
% function [data,labels]=myscanf(myname,labgo,nlab,nvar,nskip,nmax);
% myscanf: Version 14.5.97
%
% Syntax
%   myname: File name of ASCII file
%   labgo: Column where label data starts
%   nlab:  Length of label data
%   nvar:  Number of numeric variables
%   nskip: Number of lines to skip at start of file
%   nmax:  Maximum number of records to read. Optional. Default is 1000
%
% Note
%   Currently numeric variables must be to the right of the label field in each input line
%
% See also
%   mmnew log cursor function (mm_clog)

      fid=fopen(myname);
      if nargin<6 nmax=1000; end;
      il1=labgo;il2=il1+nlab-1;iv1=il2+1;
      if nskip
         for ii=1:nskip dodos=fgetl(fid);end;
      end;

      labels=zeros(nmax,nlab);
      labels=setstr(labels);
      data=zeros(nmax,nvar);
      nlin=0;
      for ii=1:nmax
            linin=fgetl(fid);
            if ~isstr(linin) break;end;
            nlin=nlin+1;
            linlen=length(linin);
            label=linin(il1:il2);
            labels(nlin,:)=label;
            x=sscanf(linin(iv1:linlen),'%e');
            data(nlin,:)=x';
      end;
      data=data(1:nlin,:);
      labels=labels(1:nlin,:);
      status=fclose(fid);

