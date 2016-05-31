function mt_sxyfd(varargin)
% mt_sxyfd set xy figure data
% function mt_sxyfd(varargin)
% mt_sxyfd: Version 25.9.98
%
% Syntax
%	varargin: Pairs of field names and values
%		see mt_inixy for list of fields and possible values
%
% See Also
%     mt_gxyad and (for graphics settings) mt_sxyap, mt_sxytp etc.
%
% Remarks
%     Currently no checks that settings are appropriate to the field.
%     New settings will only take effect at next call of the xy display routine  

myS=[];
figh=mt_gfigh('mt_xy');
if isempty(figh);
   disp('mt_gxyad: No xy figure');
   return;
end;

if nargin==0
   help mt_sxyfd;
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
      disp('mt_sxyfd: Bad input arguments');
      else
      vi=strmatch(myfield,fieldlist);
      
      if isempty(vi)
         disp(['mt_sxyfd: Bad field name; ' myfield]);
      else
         if length(vi)~=1
            disp(['mt_sxyfd: Ambiguous field name; ' myfield]);
         else
            
            myS=setfield(myS,fieldlist{vi},varargin{ipos+2});
         	iset=1;   
         end;
      end;
   end;
   
   ipos=ipos+2;
   
end;

set(figh,'userdata',myS);

