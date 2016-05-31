function mtkmdo
% mtkmdo mt user commands main_display_organization
persistent K
kname='mdo';
if isempty(K)
   myS=load('mt_skey',['k_' kname]);
   K=getfield(myS,['k_' kname]);
   clear myS;
   mlock;   
end;
[abint,abnoint,abscalar,abnoscalar]=abartdef;
command=-1;

figh=mt_gfigh('mt_organization');

while command~=K.return
   mystring=philinp([kname '> ']);
   if isempty(mystring)
      command=K.return;
   else
      command=abs(mystring(1));
   end;
   commandback=mtkcomm(command,K,'return');
   if commandback command=commandback; end;
   
   
   allsigs=mt_gcsid('signal_list');	%may need pruning to scalar signals   
   
   if command==K.maxmin_trial
	myv=mt_gtrid('maxmin_signal');
	mylist=str2mat('<none>',allsigs);
      myv=abartstr('Choose trial maxmin signal',myv,mylist,abscalar);
      
      mt_strid('maxmin_signal',myv);
   end;
   
   if command==K.maxmin_cut
	myh=findobj(figh,'type','axes','tag','current_cut_axis');
	myS=get(myh,'userdata');
	myv=myS.maxmin_signal;
	mylist=str2mat('<none>',allsigs);
      myv=abartstr('Choose cut maxmin signal',myv,mylist,abscalar);
	myS.maxmin_signal=myv;
      set(myh,'userdata',myS);

   end;
   
   
   
end;		%while not return
