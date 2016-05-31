function mt_sxyadv(axisname,varargin)
% MT_SXYADV set xy axis data for vector display
% function mt_sxyadv(axisname,varargin)
% mt_sxyadv: Version 6.12.2000
%
%	Syntax
%		axisname: name of axes in xy figure
%			(currently multiple axes must be set one at a time) 
%		varargin: Pairs of field names and values
%			see mt_inixy for list of fields and possible values
%
%	See Also
%		MY_GXYADV, MT_SXYAD, MT_GXYAD, MT_INIXY etc.
%
%	Remarks
%		Special version of mt_sxyad for vector display settings
%		Sets fields in the v_specs field of the main userdata struct.
%		Currently no checks that settings are appropriate to the field.
%		New settings will only take effect at next call of the xy display routine  

myS=[];
figh=mt_gfigh('mt_xy');
if isempty(figh);
   disp('mt_gxyad: No xy figure');
   return;
end;

if nargin==0
   help mt_sxyadv;
   return;
end;

saxh=findobj(figh,'tag',axisname,'type','axes');
if isempty(saxh)
   disp(['mt_sxyad: Axes not found > ' axisname]);
   return;
end;


myS=get(saxh,'userdata');

mySv=myS.v_specs;

fieldlist=fieldnames(mySv);
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
      disp('mt_sxyadv: Bad input arguments');
      else
      vi=strmatch(myfield,fieldlist);
      
      if isempty(vi)
         disp(['mt_sxyadv: Bad field name; ' myfield]);
      else
         if length(vi)~=1
            disp(['mt_sxyadv: Ambiguous field name; ' myfield]);
         else
            
            mySv=setfield(mySv,fieldlist{vi},varargin{ipos+2});
         	iset=1;   
         end;
      end;
   end;
   
   ipos=ipos+2;
   
end;

myS.v_specs=mySv;
set(saxh,'userdata',myS);

if iset
hall=get(saxh,'children');
%maybe a better solution???
set(hall,'visible','off');
%call display routine???
end;
