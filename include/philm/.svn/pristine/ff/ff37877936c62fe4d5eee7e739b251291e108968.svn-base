function mt_ssurfad(axisname,varargin)
% MT_SSURFAD set surf axis data
% function mt_ssurfad(axisname,varargin)
% mt_ssurfad: Version 26.08.2013
%
%	Syntax
%		axisname: name of axes in surf figure
%			(currently multiple axes must be set one at a time)
%		varargin: Pairs of field names and values
%			see mt_inisurf for list of fields and possible values
%
%	See Also
%		MT_GXYAD, MT_INIXY, MT_SVIDEOAD, MT_GSURFAD etc.
%
%	Remarks
%		Currently no checks that settings are appropriate to the field.
%		New settings will only take effect at next call of the surf display routine
%       Special cases: currently any change to gamma and colormap of any
%       axes will be applied to all axes (treated as a figure property).
%       Settings to 'xlim', 'ylim' and 'zlim' are applied directly to the
%       axes (they do not exist as fields in the axes userdata). i.e. this
%       is different from the procedure for clim which is stored in the
%       userdata and does not take effect until mt_surf is called.

myS=[];
figh=mt_gfigh('mt_surf');
if isempty(figh);
    disp('mt_ssurfad: No surf figure');
    return;
end;

if nargin==0
    help mt_ssurfad;
    return;
end;

saxh=findobj(figh,'tag',axisname,'type','axes');
if isempty(saxh)
    disp(['mt_ssurfad: Axes not found > ' axisname]);
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
        disp('mt_ssurfad: Bad input arguments');
    else
        
        %special cases, gamma and colormap: put in figure userdata
        if strcmp(myfield,'gamma')
            figS=get(figh,'userdata');
            figS.gamma=varargin{ipos+2};
            set(figh,'userdata',figS);
        end;
        if strcmp(myfield,'colormap')
            figS=get(figh,'userdata');
            figS.colormap=varargin{ipos+2};
            set(figh,'userdata',figS);
        end;
        %special cases xlim, ylim, zlim: apply directly as axes property
        if ismember(myfield(1),'xyz') & strcmp(myfield(2:4),'lim')

            try
                set(saxh,myfield,varargin{ipos+2});
            catch
                disp(['mt_ssurfad: unable to set ' myfield ' for ' axisname]);
            end;
            
            
        else
            
            
            vi=strmatch(myfield,fieldlist);
            
            if isempty(vi)
                disp(['mt_ssurfad: Bad field name; ' myfield]);
            else
                if length(vi)~=1
                    disp(['mt_ssurfad: Ambiguous field name; ' myfield]);
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

%if iset
%hall=get(saxh,'children');
%maybe a better solution???
%temporarily disabled??
%set(hall,'visible','off');
%call display routine???
%end;
