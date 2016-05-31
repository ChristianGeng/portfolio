function cs(seglist,screentime)
% CS Compare sound. Auxiliary function for use with mtnew, e.g for abc demo
% function cs(seglist,screentime)
% cs: Version 30.4.01
%
%   Syntax
%		Screentime is optional, default to complete cut

if ~nargin return; end;
nn=length(seglist);

if nn==0 return; end;

for ii=1:nn
   mt_next(seglist(ii));
   soundcom='c';
   if nargin>1
      mt_sdtim([0 screentime]);
      soundcom='S';
      
   end;
   mt_shoft;
   add2philb(soundcom);
    mtkmcs(1);
	pause;   
%   mt_audio('trial');
end;
