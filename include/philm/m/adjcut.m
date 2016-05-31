function adjcut(cutfile,outsuffix,intype,outtype,segoffset);
% ADJCUT Adjust segment boundaries of desired cut type
% function adjcut(cutfile,outsuffix,intype,outtype,segoffset);
%	Note: Assumes variables cut_type_label and _value present

outname=[cutfile '_' outsuffix];
load(cutfile);
[mystat,msg]=copyfile([cutfile '.mat'],[outname '.mat']);
if ~mystat
   disp(msg);
	return;  
end;

P=desc2struct(descriptor);
vv=find(data(:,P.cut_type)==intype);
if ~isempty(vv)
   data(vv,P.cut_start)=data(vv,P.cut_start)+segoffset(1);
   data(vv,P.cut_end)=data(vv,P.cut_end)+segoffset(2);
   data(vv,P.cut_type)=outtype;
   
   vp=find(cut_type_value==intype);
   cut_type_value(vp)=outtype;
   cl=cellstr(cut_type_label);
   oldlabel=cl{vp};
   oldlabel=[oldlabel '_' outsuffix];
   cl{vp}=oldlabel;
   cut_type_label=char(cl);
   
   save(outname,'data','cut_type_value','cut_type_label','-append');
else
   disp('adjcut: No cuts to change??');
end;
