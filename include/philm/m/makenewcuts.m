function makenewcuts(infile,outsuffix,grouptype,newtype,newlabel,starttype,startboundary,startinc,endtype,endboundary,endinc);
% MAKENEWCUTS Combine old cuts to form new cuts
% function makenewcuts(infile,outsuffix,grouptype,newtype,newlabel,starttype,startboundary,startinc,endtype,endboundary,endinc);
% makenewcuts: Version 18.11.2011
%
%	Syntax
%		grouptype: Data is only processed for trials that have a segment of
%			grouptype, and where the segments defined in starttype and endtype
%			are contained within the grouptype segment. (grouptype can be a
%			vector of values)
%		newtype: vector of types for the new segments. All following
%			arguments must have the same length (newlabel: corresponding
%			character array of labels for the new types)
%		starttype: existing segment type from whos boundaries the start
%			boundary of the new segment is calculated
%		startboundary: Normally an m*2 array specifying the weighting of
%			the start and end boundaries to calculate the new boundary
%			[1 0] gives new boundary same as old start boundary
%			[0 1] gives new boundary same as old end boundary
%			[0.5 0.5] gives new boundary at midpoint of old segment
%			This is the same syntax as used in mulpf_t
%			For backward compatibility startboundary can also be a column vector (or scalar, if only one new type).
%			Only the values 1 and 2 are allowed. 1 = use start boundary, 2
%			2 = use end boundary
%		startinc: fixed increment (in seconds) to add to the new boundary
%			calculated as above
%		endtype etc: corresponding specs to determine new end boundary

%10.09 start implementing new cutfile structure
%11.11 allow vector for grouptype

functionname='makenewcuts: Version 18.11.2011';

copyfile([infile '.mat'],[infile outsuffix '.mat']);

load(infile);
oldfield=0;

%store updated old style as well as valuelabel
if exist('cut_type_label','var') oldfield=1; end;


[cut_type_label,cut_type_value]=getvaluelabel(infile,'cut_type');

if size(newtype,2)>size(newtype,1) newtype=newtype'; end;

cut_type_label=str2mat(cut_type_label,newlabel);
cut_type_value=[cut_type_value;newtype];

valuelabel.cut_type.value=cut_type_value;
valuelabel.cut_type.label=cut_type_label;


ndo=length(newtype);

%convert old style start/end boundary specs if necessary
startboundary=fixbound(startboundary,ndo);
if isempty(startboundary) return; end;
endboundary=fixbound(endboundary,ndo);
if isempty(endboundary) return; end;




%bstr={'start','end'};
grouptype=(grouptype(:))';  %row vector
newstr=['Group type(s) : ' int2str(grouptype) crlf];

%Any rubbish in the input arguments should show up here
for ido=1:ndo
	tmps=[newlabel(ido,:) ': New type ' int2str(newtype(ido)) '; start at type ' int2str(starttype(ido)) ', boundary weights [' num2str(startboundary(ido,:)) '] + ' num2str(startinc(ido)) '; end at type ' int2str(endtype(ido)) ', boundary weights [' num2str(endboundary(ido,:)) '] + ' num2str(endinc(ido))];
	disp(tmps);
	newstr=[newstr tmps crlf];
end;



datanew=[];
labelnew='';

grouplist=find(ismember(data(:,3),grouptype));

misslist=[];

disp(['makenewcuts: ' int2str(length(grouplist)) ' grouping segments found']);

for igi=grouplist'
	grouplabel=deblank(label(igi,:));
	mytrial=data(igi,4);
	vu=find(data(:,4)==data(igi,4) & data(:,1)>=data(igi,1) & data(:,2)<=data(igi,2));
	disp(grouplabel);
	tmpdat=data(vu,:);
	allok=1;
	for ido=1:ndo
		vt=find(starttype(ido)==tmpdat(:,3));
		if length(vt)==1
			startdat=sum(tmpdat(vt,1:2).*startboundary(ido,:))+startinc(ido);
			vt=find(endtype(ido)==tmpdat(:,3));
			if length(vt)==1
				enddat=sum(tmpdat(vt,1:2).*endboundary(ido,:))+endinc(ido);

				datanew=[datanew;[startdat enddat newtype(ido) data(igi,4)]];
				if isempty(labelnew)
					labelnew=grouplabel;
				else
					labelnew=str2mat(labelnew,grouplabel);
				end;
			else
				disp(['No end boundary for new type ' int2str(newtype(ido)) ' in trial ' int2str(mytrial)]);
				allok=0;
			end;
		else
			disp(['No start boundary for new type ' int2str(newtype(ido)) ' in trial ' int2str(mytrial)]);
			allok=0;

		end;
	end;
	if ~allok misslist=[misslist mytrial]; end;
end;

if ~isempty(misslist)
	disp('makenewcuts: Overall list of trials with missing segment boundaries');
	disp(misslist);
end;

%temporary allow for new cut file structure

oldcol=size(data,2);
if oldcol>4
    nantmp=repmat(NaN,[size(datanew,1) oldcol-4]);
    datanew=[datanew nantmp];
end;


data=[data;datanew];
label=str2mat(label,labelnew);

[data,label]=sortcut(data,label);

comment=[newstr comment];
comment=framecomment(comment,functionname);

save([infile outsuffix],'data','label','comment','valuelabel','-append');
if oldfield
save([infile outsuffix],'cut_type_value','cut_type_label','-append');
end;

function outbound=fixbound(mybound,ndo);
outbound=mybound;

if size(mybound,2)>2 & size(mybound,1)==1 mybound=mybound'; end;

if size(mybound,2)>2 | size(mybound,1)~=ndo
	disp('Bad format of boundary specification');
	disp(mybound);
	outbound=[];
	return;
end;

if size(mybound,2)==1
	if any(mybound<1) | any(mybound>2)
		disp('Bad old style boundary specification');
		disp(mybound);
		outbound=[];
		return;
	else
		outbound=zeros(ndo,2);
		vv=find(mybound==1);
		outbound(vv,1)=1;
		vv=find(mybound==2);
		outbound(vv,2)=1;
	end;
end;

