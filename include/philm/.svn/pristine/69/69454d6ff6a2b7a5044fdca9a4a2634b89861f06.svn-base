function bigs=show_valuelabel(valuelabel);
% SHOW_VALUELABEL Show value label pairs for each field in struct
% function bigs=show_valuelabel(valuelabel);
% show_valuelabel: Version ???
% Returns a string suitable for use with SPSS ADD VALUE LABELS command

ff=fieldnames(valuelabel);

nf=length(ff);

bigs='';
for ii=1:nf
   sf=getfield(valuelabel,ff{ii});
   v=sf.value;
   l=sf.label;
   ll=length(v);
   s=[char(9) '/' ff{ii}];
   for jj=1:ll
      s=[s ' '  num2str(v(jj)) ' ' quote deblank(l(jj,:)) quote];
   end;
   bigs=[bigs s crlf];
end;
return;

%old version, quick display only

for ii=1:nf
   sf=getfield(valuelabel,ff{ii});
   
   disp(['VARIABLE: ' ff{ii}])
   disp('---values---')
   disp(sf.value)
   disp('---labels---')
   disp(sf.label)
	disp('==========================')   
end;
