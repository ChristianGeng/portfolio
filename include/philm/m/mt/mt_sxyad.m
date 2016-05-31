function mt_sxyad(axisname,varargin)
% MT_SXYAD set xy axis data
% function mt_sxyad(axisname,varargin)
% mt_sxyad: Version 3.4.99
%
%	Syntax
%		axisname: name of axes in xy figure
%			(currently multiple axes must be set one at a time) 
%		varargin: Pairs of field names and values
%			see mt_inixy for list of fields and possible values
%
%	See Also
%		MT_GXYAD, MT_INIXY etc.
%
%	Remarks
%		Currently no checks that settings are appropriate to the field.
%		New settings will only take effect at next call of the xy display routine  

myS=[];
figh=mt_gfigh('mt_xy');
if isempty(figh);
   disp('mt_gxyad: No xy figure');
   return;
end;

if nargin==0
   help mt_sxyad;
   return;
end;

saxh=findobj(figh,'tag',axisname,'type','axes');
if isempty(saxh)
   disp(['mt_sxyad: Axes not found > ' axisname]);
   return;
end;


myS=get(saxh,'userdata');

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
      disp('mt_sxyad: Bad input arguments');
      else
      vi=strmatch(myfield,fieldlist);
      
      if isempty(vi)
         disp(['mt_sxyad: Bad field name; ' myfield]);
      else
         if length(vi)~=1
            disp(['mt_sxyad: Ambiguous field name; ' myfield]);
         else
            
            myS=setfield(myS,fieldlist{vi},varargin{ipos+2});
         	iset=1;   
         end;
      end;
   end;
   
   ipos=ipos+2;
   
end;

set(saxh,'userdata',myS);

if iset
hall=get(saxh,'children');
%maybe a better solution???
set(hall,'visible','off');
%call display routine???
end;
