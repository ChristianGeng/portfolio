function cleanmarkerfile(markerfile,grouptype,maxslash);
% CLEANMARKERFILE Tidy up marker files
% function cleanmarkerfile(markerfile,grouptype,maxslash);
% cleanmarkerfile: Version 17.7.07
%
%   Description
%       Tidies up marker files from mt_new marker functions
%           Removes multiple identical grouping cuts (or warns about
%           ambiguities)
%           Reduces multiple copies of the label generated as an edit trace
%               i.e allows a maximum of maxslash '/' characters in the
%               label, replacing any characters in the label beyond this
%               point by a count of the number of additional slash
%               characters found
%           Warns about multiple analyses with same cut type within same
%           grouping segment
%           Note: Currently does not check for segments that do not have a
%           corresponding grouping segment. This means the marker file can
%           have more than one grouping type: the function can be called
%           separately for each grouping type
%   Updates
%       24.8.07 Take care of group cuts containing no segments

functionname='cleanmarkerfile: Version 17.7.07';

slashchar='/';      %character used to separate multiple copies of label

data=mymatin(markerfile,'data');
label=mymatin(markerfile,'label');
comment=mymatin(markerfile,'comment');

vv=find(data(:,3)==grouptype);

datagrp=data(vv,:);
labelgrp=label(vv,:);
grpnum=vv';

data(vv,:)=[];
label(vv,:)=[];

%the mtnew marker functions can often result in the current cut being
%stored more than once in the marker file


labtmp=unique(labelgrp,'rows');
nu=size(labtmp,1);

disp([int2str(nu) ' unique labels for ' int2str(length(vv)) ' grouping segments']);

if nu~=length(vv)
    disp('Checking for multiple grouping segments');
    for iu=1:nu
        mylabel=deblank(labtmp(iu,:));
        vv=strmatch(mylabel,labelgrp,'exact');
        if length(vv)>1
            disp('Multiple group segments');
            disp(mylabel);
            disp(datagrp(vv,:));
            
            if all(datagrp(vv,1)==datagrp(vv(1),1)) & all(datagrp(vv,2)==datagrp(vv(1),2)) & all(datagrp(vv,3)==datagrp(vv(1),3))
                disp('Deleting');
                datagrp(vv(2:end),:)=[];
                labelgrp(vv(2:end),:)=[];
                grpnum(vv(2:end))=[];    
            else
                disp('Segments are not identical');
                disp('Labels must be ambiguous: Please fix in input file!');
                disp(['Segment numbers in input file : ' int2str(grpnum(vv))]);
                disp('Program will continue retaining the first record');
                keyboard;
                datagrp(vv(2:end),:)=[];
                labelgrp(vv(2:end),:)=[];
                grpnum(vv(2:end))=[];    
                
            end;
        end;
    end;
end;

noseglist=[];

labelc=cellstr(label);
nl=length(labelc);

for ili=1:nl
    tmp=labelc{ili};
    vv=findstr(slashchar,tmp);
    if length(vv)>maxslash
        disp(['Edit trace : ' tmp]);
        tmp((vv(maxslash)+1):end)=[];
        tmp=[tmp int2str(length(vv)-maxslash) slashchar];
        labelc{ili}=tmp;
    end;
end;

label=char(labelc);

%assume labels for grouping cuts are no longer ambiguous
%check for multiple analyses

ngrp=size(labelgrp,1);

%allow for nan as one segment boundary
datann=data;
vn=isnan(datann(:,2));
if ~isempty(vn)
    datann(vn,2)=datann(vn,1);
end;
%less likely
vn=isnan(datann(:,1));
if ~isempty(vn)
    datann(vn,1)=datann(vn,2);
end;




for igi=1:ngrp
    disp(labelgrp(igi,:));
    disp(datagrp(igi,:));
    vv=find(datann(:,4)==datagrp(igi,4) & datann(:,1)>=datagrp(igi,1) & datann(:,2)<=datagrp(igi,2));
    nseg=length(vv);
    
    if nseg>0
        nutype=unique(datann(vv,3));
        if nseg~=length(nutype)
            disp(labelgrp(igi,:));
            disp('Multiple analyses? (may be harmless if grouping segments can overlap, and labels are different)');
            disp([label(vv,:) num2str(data(vv,:))]);
            
            %not immediately obvious what the best way of fixing problems is.
            disp('Suggested procedure:');
            disp('Load marker file into workspace. Use array editor to find records to delete');
            disp('Use changematvar to delete records in data AND label');
            keyboard;
        else
            %check if all labels are same; just for information
            tmplab=label(vv,:);
            nlab=size(tmplab,1);
            if any(mean(tmplab)~=tmplab(1,:))
                disp('Just for your information, different labels (grouping segments may overlap):');
                disp(tmplab);
            end;
            
        end;
    else
        disp(['Note: No segments for grouping segment ' labelgrp(igi,:)]);
        disp(datagrp(igi,:));
        disp('This segment will be removed from the output file');
        noseglist=[noseglist;igi];
%        keyboard;
    end;
    
end;

if ~isempty(noseglist)
    disp('Removing grouping segments containing no segment data');
    disp(labelgrp(noseglist,:));
    datagrp(noseglist,:)=[];
    labelgrp(noseglist,:)=[];
end;



%merge group segments with marker segments
%update comment
data=[data;datagrp];
label=str2mat(label,labelgrp);

tmpstr=['cleanmarkerfile grouptype and maxslash : ' int2str([grouptype maxslash])];
comment=[tmpstr crlf comment];
comment=framecomment(comment,functionname);
[data,label]=sortcut(data,label);

disp('Marker file will now be updated; type ''return'' to continue');
keyboard;

save(markerfile,'data','label','comment','-append');
