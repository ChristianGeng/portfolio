function [chn,desc,unit,scalefactor,signalzero,chrange]=sonych(sm)
% SONYCH Get Sony channel info from log file
% function [chn,desc,unit,scalefactor,signalzero,chrange]=sonych(sm)
% sonych: Version 5.1.08
%
%   Description
%       Returns separate variables for the different kinds of channel
%       information for all channels in the log file
%
%   See Also GETSONYF Gets single fields from log file

chstr=getsonyf(sm,'CHANNEL');
nch=size(chstr,1);

rastr=getsonyf(sm,'INPUT_RANGE');
desc='';
unit='';

for ii=1:nch
   st=deblank(chstr(ii,:));
   [sx,st]=strtok(st,',');
   
   chn(ii)=eval(sx);
   [sx,st]=strtok(st,',');
   %skip quotes and blank
   desc=str2mat(desc,sx(3:(end-1)));
   [sx,st]=strtok(st,',');
   unit=str2mat(unit,sx(2:end));	%skip blank
   ix=findstr('*',st);
   st=st((ix+1):end);
   
   tok='+';
   if isempty(findstr(tok,st)) tok='-'; end;
   
   [sx,st]=strtok(st,tok);
   scalefactor(ii)=eval(sx);
   %skip plus/minus
   st=st(2:end);
   
   signalzero(ii)=eval(st);
   
   %can we assume exactly same order as CHANNEL?
   [sx,st]=strtok(deblank(rastr(ii,:)),',');
   %is last character always V?
   %skip comma
   
   [sx,st]=strtok(st(2:end),'V');
   chrange(ii)=eval(sx);
end;
desc=desc(2:end,:);
unit=unit(2:end,:);
