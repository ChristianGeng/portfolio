function buf=mtxxydis(ntraj,mymode,myspec,timspec,sf,ndatin);
% mtxxydis Auxiliary function for mt_xydis. Retrieve multiple data channels
% function buf=mtxxydis(ntraj,mymode,myspec,timspec,sf,ndatin);
% mtxxydis: Version 2.9.98
%
% Description
%   Currently most convenient way of retrieving multiple channels
%   but also used by to generate data for special cases (e.g time axis) for xy display
%   Input argument ndatin is optional. If absent the number of rows in the
%   returned data matrix will be determined from the time spec. and the sample rate
%
%   See also mt_gdata

buf=[];
sampinc=1./sf;
if nargin<6
   ndat=diff(round(timspec*sf));
else
   ndat=ndatin;
end;

if ndat>0
   if strcmp(mymode,'time')
      timeaxis=((0:(ndat-1))')*sampinc;
      myone=ones(1,ntraj);
      buf=timeaxis*myone;
      return;
   end;
   if strcmp(mymode,'constant')
      if ~ischar(myspec)
         disp('Specification in constant mode must be a string that evaluates to a scalar');
         disp('Set to 1');
         myspec='1';
      end;
      try
         myval=eval(myspec);
      catch
         disp('Unable to evaluate specification in constant mode');
         disp('Set to 1');
         myval=1;
      end;
      
      if length(myval)~=1
         disp('Specification in constant mode must be a string that evaluates to a scalar');
         disp('Set to 1');
         myval=1;
      end;
         
      myval=ones(1,ntraj)*myval;
      myone=ones(ndat,1);
      buf=myone*myval;
      return;
   end;
   if strcmp(mymode,'sensor_number')
      myval=1:ntraj;
      myone=ones(ndat,1);
      buf=myone*myval;
      return;
   end;
   
   if strcmp(mymode,'signal_data')
      
      buf=ones(ndat,ntraj)*NaN;
      somedata=0;
      %get data
      for ii=1:ntraj
         [scratch,actualtime]=mt_gdata(deblank(myspec(ii,:)),timspec);
         nin=length(scratch);
         if nin~= ndat
            %probable cause is bad signal name or incomplete signal
            disp (['mtxydis: ' myspec(ii,:)]);
            disp (['Unexpected read length ' int2str(nin) ' ' int2str(ndat)]);
            disp('Skipping this signal');   
         else
            buf(:,ii)=scratch;
            somedata=1;   
         end;
         
      end;
      
      if ~somedata buf=[];end;   
   end;
   
   if isempty(buf)
      disp('mtxxydis: No data or unknown mode?');
   end;
   
   
   
end;	%ndat