function mtkmcm(inflag)
% MTKMCM mt user commands main_cursor_marker
% function mtkmcm(inflag)
% mtkmcm: Version 23.9.99
%
%	Syntax
%		If inflag is present input is taken from philinp, otherwise from mmginput

persistent K
kname='mcm';
if isempty(K)
   myS=load('mt_skey',['k_' kname]);
   K=getfield(myS,['k_' kname]);
   clear myS;
   mlock;   
end;
[abint,abnoint,abscalar,abnoscalar]=abartdef;
command=-1;

if ~nargin
         disp([kname '> ']);
         if philcomempty
            [mousepx,mousepy,mousepz,command]=mmginput;
         else
            command=philinp('');
            mousepx=[];		%may need to watch this
         end;
         
         if length(command)~=1 command=-1;end;
      else
   
         mystring=philinp([kname '> ']);
   if ~isempty(mystring)
      command=abs(mystring(1));
   end;
end;

%default command?
commandout=mtkcomm(command,K);
  if commandout command=commandout;end;
  
   
   
   
   
               %marker commands
            if command==K.set_start mt_smark('start');end;
            if command==K.set_end mt_smark('end');end;
            if command==K.clear_start mt_cmark('start');end;
            if command==K.clear_end mt_cmark('end');end;
            
            if command==K.set_type
		if ~nargin
               %will need changing for large numbers of marker types
               typekeys=abs('123456789');
%allow for command file operation ???              
if philcomempty
   [dodox,dodoy,dodoz,tmpchar]=mmginput;
else
   tmpchar=philinp('');
end;
if length(tmpchar)~=1 tmpchar=0; end;

               curind=find(typekeys==tmpchar);
		else
		curind=abart('New marker type',mt_gmarx('current_marker'),1,mt_gmarx('n_markers'),abint,abscalar);
		end;
               if ~isempty(curind) mt_smark('type',curind); end;


            end;
            
            if command==K.increase_type
               curind=(mt_gmark('type'))+1;
               mt_smark('type',curind);
            end;
            if command==K.decrease_type
               curind=(mt_gmark('type'))-1;
               mt_smark('type',curind);
            end;
            
            if command==K.set_label
		if ~nargin
         %9.99 change to uicommand
         
%allow for command file operation????         
         tmpchar=myuigetstring('Enter label : ');
         %disp('Enter label, type <CR>');
               %input up to CR
%               [dodox,dodoy,tmpchar]=ginput;
%               tmpchar=setstr(tmpchar');
		else
		tmpchar=philinp('Label: ');
		end;

               mt_smark('label',[],tmpchar);
            end;
            
            
