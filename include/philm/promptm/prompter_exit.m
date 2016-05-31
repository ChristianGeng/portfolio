function prompter_exit


P=prompter_gmaind;
S=prompter_gstimd;
A=prompter_gwaved;
AG=[];
if findstr('TRIGAG',P.function_name)
    AG=prompter_gagd;
end;


status=fclose(P.logfilefid);


comment='prompter data structures';
infofile=P.logfile;
infofile=strrep(infofile,'.txt','');
infofile=[infofile '_' P.function_name '_info'];
save(infofile,'P','S','A','AG','comment');

figure_names=P.figure_names;
nf=size(figure_names,1);
figure_positions=ones(nf,4)*NaN;

for ifi=1:nf
hf=findobj('type','figure','name',deblank(figure_names(ifi,:)));
figure_positions(ifi,:)=get(hf,'position');
close(hf);
end;
save([P.function_name '_figpos'],'figure_names','figure_positions');
