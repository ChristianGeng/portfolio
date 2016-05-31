function mt_ssonaad(axisname,varargin)
% MT_SSONAAD set sona display axis data
% function mt_ssonaad(axisname,varargin)
% mt_ssonaad: Version 27.08.2013
%
%	Syntax
%		axisname: name of axes in xy figure
%			(currently multiple axes must be set one at a time)
%		varargin: Pairs of field names and values
%			see mt_inisona for list of fields and possible values
%
%	See Also
%		MT_GSONAAD, MT_INISONA, MT_SONADIS etc.
%
%	Remarks
%		Currently no checks that settings are appropriate to the field.
%		New settings will only take effect at next call of the sona display routine
%       Special case: 'ylim' (=frequency axis in sonagram display) applied immediately (not stored in the
%       userdata struct)

myS=[];
figh=mt_gfigh('mt_sona');
if isempty(figh);
    disp('mt_ssonaad: No sona figure');
    return;
end;

if nargin==0
    help mt_ssonaad;
    return;
end;

saxh=findobj(figh,'tag',axisname,'type','axes');
if isempty(saxh)
    disp(['mt_ssonaad: Axes not found > ' axisname]);
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
        disp('mt_ssonaad: Bad input arguments');
    else
        
        if strcmp(myfield,'ylim')
            try
                set(saxh,'ylim',varargin{ipos+2});
            catch
                disp('mt_ssonaad: unable to set ylim; check specification is correct');
            end;
        else
            vi=strmatch(myfield,fieldlist);
            
            if isempty(vi)
                disp(['mt_ssonaad: Bad field name; ' myfield]);
            else
                if length(vi)~=1
                    disp(['mt_ssonaad: Ambiguous field name; ' myfield]);
                else
                    
                    myS=setfield(myS,fieldlist{vi},varargin{ipos+2});
                    iset=1;
                end;
            end;
        end;
    end;
    
    ipos=ipos+2;
    
end;

set(saxh,'userdata',myS);

if iset
    hall=get(saxh,'children');
    %maybe a better solution???
    %temporarily disabled??
    %set(hall,'visible','off');
    %call display routine???
end;
