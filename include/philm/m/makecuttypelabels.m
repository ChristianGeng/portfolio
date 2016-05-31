function S=makecuttypelabels(siglist,baselist,typebase,typeinc,addtype);
% MAKECUTTYPELABELS Make list of cut_type values and labels for list of signals and segmentation types
% function S=makecuttypelabels(siglist,baselist,typebase,typeinc);
% makecuttypelabels: Version 6.3.09
%
%	Description
%		Every element of baselist is concatenated with every element of siglist
%			to form cut_type labels like 'tt_nucleus' (both arguments can
%			be string matrix or cell array of strings)
%		typebase: Number of first segment type for first signal
%		typeinc: Segment type increment between signals (default is number of elements in baselist)
%		addtype: optional. must be struct with fields 'label' and 'value'
%			These are added to the main list (and the list is then sorted by
%			value). Currently no checks that this will introduce
%			conflicting or duplicate specifications

%siglist={'tt_','tb_','la_','ll_','tbvow_','jawvow_','tt_anchor_','tb_anchor_','la_anchor_'};
siglist=cellstr(siglist);

nsig=length(siglist);
%baselist={'gesture','maxvel','nucleus','maxcon'};
baselist=cellstr(baselist);
nco=length(baselist);

if nsig~=length(unique(siglist))
	disp('makecuttypelabels: siglist not unique');
	return;
end;

if nco~=length(unique(baselist))
	disp('makecuttypelabels: baselist not unique');
	return;
end;



typebase1=typebase-1;
typeincuse=nco;
if nargin>3
	if ~isempty(typeinc) typeincuse=typeinc; end;
end;
if typeincuse<nco
	disp('makecuttypelabels: typeinc too small!');
	typeincuse=nco;
end;


typeval=[];
typelab='';
for ii=1:nsig
	tmp=strcat(siglist{ii},baselist);
	typelab=strvcat(typelab,char(tmp));
	tmpt=(1:nco) + (typeincuse*(ii-1)) + typebase1;
	%disp(tmpt)
	typeval=[typeval;tmpt'];

end;



if nargin> 4

	try
		tmpval=addtype.value;
		tmpval=tmpval(:);
		tmplabel=addtype.label;

		if length(tmpval)==size(tmplabel,1)
			typeval=[tmpval;typeval];
			typelab=str2mat(tmplabel,typelab);
			[typeval,sorti]=sort(typeval);
			typelab=typelab(sorti,:);
			%also check unique???
		else
			disp('makecuttypelabels: problem with length of addtype fields');
		end;
	catch
		disp('makecuttypelabels: problem with addtype?');
		disp(lasterr);
	end;

end;



S.value=typeval;
S.label=typelab;
