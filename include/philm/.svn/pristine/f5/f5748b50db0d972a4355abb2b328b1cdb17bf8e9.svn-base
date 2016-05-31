function mt_ssonafd(varargin)
% MT_SSONAFD set sona figure data
% function mt_ssonafd(varargin)
% mt_ssonafd: Version 25.9.98
%
%	Syntax
%		varargin: Pairs of field names and values
%			see mt_inisona for list of fields and possible values
%
%	See Also
%		MT_SSONAAD
%
%	Remarks
%		Currently no checks that settings are appropriate to the field.
%		New settings will only take effect at next call of the sona display routine  

figname='sona';
funcname=['mt_s' figname 'fd'];
myS=[];
figh=mt_gfigh(['mt_' figname]);
if isempty(figh);
   disp([funcname ': No ' figname ' figure']);
   return;
end;

if nargin==0
   help(funcname);
   return;
end;



myS=get(figh,'userdata');

fieldlist=fieldnames(myS);
narg=floor(length(varargin)/2);
if narg==0
   disp(fieldlist)
   return;
end;

iset=0;
ipos=0;
for ii=1:narg
   myfield=varargin{ipos+1};
   
   
   if ~ischar(myfield)
      disp([funcname ': Bad input arguments']);
      else
      vi=strmatch(myfield,fieldlist);
      
      if isempty(vi)
         disp([funcname ': Bad field name; ' myfield]);
      else
         if length(vi)~=1
            disp([funcname ': Ambiguous field name; ' myfield]);
         else
            
            myS=setfield(myS,fieldlist{vi},varargin{ipos+2});
         	iset=1;   
         end;
      end;
   end;
   
   ipos=ipos+2;
   
end;

set(figh,'userdata',myS);

