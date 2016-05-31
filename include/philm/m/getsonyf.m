function mystring=getsonyf(sm,myfield)
% GETSONYF Returns fields in sony log file
% function mystring=getsonyf(sm,myfield)
% getsonyf: Version 5.1.08
%
%   Description
%       Field contents are returned as a string, so if the field is numeric
%       it will be necessary to use str2num on the result. Also, if the
%       numeric value is followed by units (or other text material) it will
%       be necessary to first extract it with strtok
%
%   See Also SONYCH Gets all information on each channel


mytab=9;

ll=strmatch(myfield,sm);
if isempty(ll)
   disp('Bad field name??');
   return;
end;

ts=sm(ll(1),:);
pp=find(ts==mytab);
ts=deblank(ts((pp+1):end));


if length(ll)==1
   mystring=ts;
   return;
else
   for ii=2:length(ll)
      tts=sm(ll(ii),:);
      pp=find(tts==mytab);
      tts=deblank(tts((pp+1):end));
      ts=str2mat(ts,tts);
   end;
   mystring=ts;
end;
