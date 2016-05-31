function sonaadj(myclim,mypreemp,axesname);
% SONAADJ Adjust MT sonagram display
% function sonaadj(myclim,mypreemp,axesname);
% sonaadj: Version ???
%
%   Syntax
%       myclim: 2-element vector with lower and upper dB limit for display
%       mypreeemp: If scalar, high frequency emphasis in dB
%           If length of mypreemp == 2, treat as timeinfo over which
%           to average the spectral data from current trial
%           The negative of the average spectrum is then used as the spectral shaping vector
%	            i.e spectrum can e.g be relative to noise floor
%       axesname: Optional, default to 'SONA'. Necessary if multiple
%           sonagram-style displays are being used


%hh=mt_gfigh('mt_sona');
%hha=findobj(hh,'type','axes','tag','SONA');

dopreemp=1;
if nargin==1
   dopreemp=0;
else
   if isempty(mypreemp) dopreemp=0; end;
end;

myaxes='SONA';
if nargin>2 myaxes=axesname;end;

if dopreemp
   if length(mypreemp)==1   
      y1=mt_gsigv(myaxes,'data_size');
      
      tt=interp1([1 y1(1)],[0 mypreemp],1:y1(1));
      
      mt_ssonaad(myaxes,'shape_vector',tt);
   end;
   if length(mypreemp)==2
      xx=mt_gdata(myaxes,mypreemp);
      xx=mean(xx');
      tt=-xx;
      mt_ssonaad(myaxes,'shape_vector',tt);
   end;
end;


if length(myclim)==2
   mt_ssonaad(myaxes,'clim',myclim);
end;

