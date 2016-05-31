function outstring=showcutfile(cutfilename,reclist,extendflag)
% SHOWCUTFILE Display cutfile data and labels
% function outstring=showcutfile(cutfilename,reclist,extendflag)
% showcutfile: Version 24.4.09
%
%   Description
%       outstring: Optional. If not present, list is displayed in help
%           window
%       reclist: Optional. List of records to display (default is complete
%           file)
%       Extendflag: Optional. If present and > 0, show extended variables.
%           Any that are all NaN are omitted. 
%           Values of extended flag control the formatting:
%               1: Dates in days (rounded to nearest integer )relative to earliest date used
%               2: Dates in days relative to earliest date used

load(cutfilename)

n=size(data,1);

nb=(blanks(n))';

nn=(1:n)';

vv=1:n;
if nargin>1
    if ~isempty(reclist)
        reclist(reclist>n)=[];
        vv=reclist;
    end;
end;

extendmode=0;
if nargin>2 extendmode=extendflag; end;




nn=nn(vv);
nb=nb(vv);
data=data(vv,:);

ss=[int2str(nn) nb num2str(data(:,1:2)) nb int2str(data(:,3:4))];


columstr=strm2rv(descriptor(1:4,:),'|');
columstr=['Rec#|' columstr];

P=desc2struct(descriptor);

addstr='';
if extendmode
    xcol=[];
    
    xcol=getxcol(data,P,'link_type',xcol);
    xcol=getxcol(data,P,'link_target',xcol);
    xcol=getxcol(data,P,'link_targetn',xcol);
    xcol=getxcol(data,P,'link_id',xcol);
    
    if ~isempty(xcol)
        xdata=data(:,xcol);
        ss=[ss nb int2str(xdata)];
        xstr=strm2rv(descriptor(xcol,:),'|');
        columstr=[columstr xstr];
    end;
    
    xcol=[];
    
    xcol=getxcol(data,P,'creation_date',xcol);
    xcol=getxcol(data,P,'modification_date',xcol);
    
    if ~isempty(xcol)
        xdata=data(:,xcol);
        
        if extendmode==1 | extendmode==2
            datemin=min(floor(xdata(:)));
            xdata=xdata-datemin;
            
            addstr=['Dates in days re. ' datestr(datemin) ' 00:00:00'];
            
            if extendmode==1 ss=[ss nb int2str(round(xdata))];end;
            if extendmode==2 ss=[ss nb num2str(xdata)];end;
            
        end;
        
        xstr=strm2rv(descriptor(xcol,:),'|');
        columstr=[columstr xstr];
    end;
    
end;




ss=[ss nb label(vv,:)];

%    keyboard;
ss=str2mat(addstr,columstr,ss);

if nargout
    outstring=ss;
else
    helpwin(ss,cutfilename);
end;

function xcolout=getxcol(data,P,myfield,xcol);
xcolout=xcol;
if isfield(P,myfield);
    if ~all(isnan(data(:,P.(myfield))))
        xcolout=[xcolout P.(myfield)];
    end;
end;
