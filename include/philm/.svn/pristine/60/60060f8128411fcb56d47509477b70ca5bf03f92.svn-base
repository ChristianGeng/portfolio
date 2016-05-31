function mt_svideoad(axisname,varargin)
% MT_SVIDEOAD set video axis data
% function mt_svideoad(axisname,varargin)
% mt_svideoad: Version 28.08.2013
%
%	Syntax
%		axisname: name of axes in video figure
%			(currently multiple axes must be set one at a time)
%		varargin: Pairs of field names and values
%			see mt_inivideo for list of fields and possible values
%
%	See Also
%		MT_GXYAD, MT_INIXY etc.
%
%	Remarks
%		Currently no checks that settings are appropriate to the field.
%		New settings will only take effect at next call of the video display routine
%       Special case: 'xlim' and 'ylim' are carried out immediately (not
%       stored in userdata struct)

myS=[];
figh=mt_gfigh('mt_video');
if isempty(figh);
    disp('mt_svideoad: No video figure');
    return;
end;

if nargin==0
    help mt_svideoad;
    return;
end;

saxh=findobj(figh,'tag',axisname,'type','axes');
if isempty(saxh)
    disp(['mt_svideoad: Axes not found > ' axisname]);
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
        disp('mt_svideoad: Bad input arguments');
    else
        
        
        %special cases xlim, ylim, zlim: apply directly as axes property
        if ismember(myfield(1),'xy') & strcmp(myfield(2:4),'lim')
            try
                set(saxh,myfield,varargin{ipos+2});
            catch
                disp(['mt_svideoad: unable to set ' myfield ' for ' axisname]);
            end;
        else
            
            vi=strmatch(myfield,fieldlist);
            
            if isempty(vi)
                disp(['mt_svideoad: Bad field name; ' myfield]);
            else
                if length(vi)~=1
                    disp(['mt_svideoad: Ambiguous field name; ' myfield]);
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
