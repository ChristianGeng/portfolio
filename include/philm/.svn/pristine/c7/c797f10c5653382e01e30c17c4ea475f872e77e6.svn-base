function triallist=getrestetc(cutfile,timerange,supstring)
% GETRESTETC Get list of atypical trials (rest, rubbish), also based on duration
% function triallist=getrestetc(cutfile,timerange,supstring)
% getrestetc: Version 10.06.2013
%
%   Description
%       If no cutfile is available one should be created with e.g.
%       makecutfile (assumes some signal files (e.g. audio) already
%       extracted to mat files)
%       e.g myname='dach_fmd3_audio';
%           makecutfile(['mat' pathchar myname '_0'],[myname '_cut'],1:757);
%       timerange: 2-element vector. function looks for trials with duration outside this
%           range
%       supstring: string matrix of additional strings to look for in the
%           segment label ('REST' and '!!' at start of label, and '!!Ru' inside
%           the label are looked for by default)
load(cutfile);

vall=[];
myrange=[];
if nargin>1
    if ~isempty(timerange)
        myrange=timerange;
    end;
end;
if ~isempty(myrange)
    dd=data(:,2)-data(:,1);
    
    vv=find((dd < myrange(1)) | (dd > myrange(2)));
    if ~isempty(vv)
        disp([int2str(length(vv)) ' trials outside time range']);
        vall=[vall;vv];
    end;
end;


vv=strmatch('REST',label);
if ~isempty(vv)
    disp([int2str(length(vv)) ' REST codes found']);
    vall=[vall;vv];
end;

vv=strmatch('!!',label);
if ~isempty(vv)
    disp([int2str(length(vv)) ' !! codes found']);
    vall=[vall;vv];
end;

strlist='!!Ru';     %rubbish
if nargin>2
    strlist=str2mat(strlist,supstring);
end;

ns=size(strlist,1);
for isi=1:ns
    tmpstr=deblank(strlist(isi,:));
vc=strfind(cellstr(label),tmpstr);

vv=find(~cellfun('isempty',vc));

if ~isempty(vv)
    disp([int2str(length(vv)) ' ' tmpstr  ' codes found']);
    vall=[vall;vv];
end;

end;


vu=unique(vall);

triallist=data(vu,4);

