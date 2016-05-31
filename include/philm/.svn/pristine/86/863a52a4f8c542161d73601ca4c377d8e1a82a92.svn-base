function mt_restorefigpos(positionfile)
% MT_RESTOREFIGPOS Restore figure positions to those at last program end
% function mt_restorefigpos(positionfile)
% mt_restorefigpos: Version 16.4.03
%
%   Description
%       Examines mat file mtxfigpos for variables figlist and figpos
%       and positions figures accordingly
%       mtxfigpos is generated at every normal termination of mtnew
%       but can be set up by hand if desired
%       positionfile is optional; can used as alternative to mtxfigpos
%       The function must be called by hand (or include in a command file)
%

myfile='mtxfigpos';
if nargin myfile=positionfile; end;

try
figlist=mymatin(myfile,'figlist');
catch
    disp('no figure position file?');
    return;
end;

figpos=mymatin(myfile,'figpos');

if isempty(figlist)| isempty(figpos)
    disp('missing variables in figure position file?');
    return;
end;

if size(figlist,1)~=size(figpos,1)
    disp('In figure position file figlist and figpos do not match');
    return;
end;

nf=size(figlist,1);

%keyboard;
for ii=1:nf
    htmp=mt_gfigh(deblank(figlist(ii,:)));
    if ~isempty(htmp)
        set(htmp,'position',figpos(ii,:));
    end;
end;
