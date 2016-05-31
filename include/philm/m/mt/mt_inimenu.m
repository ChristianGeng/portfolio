function mt_inimenu(listflag)
% MT_INIMENU Show menu structure in organization figure
% function mt_inimenu(listflag)
% listflag: Optional. If present and true, output list of commands
%					on screen, rather than generating uimenus
%					Note: Can only be done if function has already been called in the normal way

load mt_skey

outflag=0;
if nargin outflag=listflag; end;

iparent=mt_gfigh('mt_organization');
imain=iparent;

myprefix='';

%not very elegant
if outflag
   oldtag=get(iparent,'tag');
   set(iparent,'tag','main');
end;

K=k_m;
do1menu(k_m,iparent,myprefix,outflag);

if outflag
   set(iparent,'tag',oldtag);
end;
%special case for common commands; only inserted at top level

if ~outflag
   hm=uimenu(iparent,'label','<Common>','tag','common','userdata','common','callback','mtxmenucb');
end;


iparent=findobj(imain,'type','uimenu','tag','common');
do1menu(k_common,iparent,myprefix,outflag);

%%%%%%%

myprefix='main>';

iparent=findobj(imain,'type','uimenu','tag','i_o');
do1menu(k_mi,iparent,myprefix,outflag);

iparent=findobj(imain,'type','uimenu','tag','cursor');
do1menu(k_mc,iparent,myprefix,outflag);


iparent=findobj(imain,'type','uimenu','tag','timeshift');
do1menu(k_mt,iparent,myprefix,outflag);

iparent=findobj(imain,'type','uimenu','tag','show');
do1menu(k_ms,iparent,myprefix,outflag);


iparent=findobj(imain,'type','uimenu','tag','display_settings');
do1menu(k_md,iparent,myprefix,outflag);

%%%%%%%%next level
myprefix='main>display_settings>';

iparent=findobj(imain,'type','uimenu','tag','settime');
do1menu(k_mdt,iparent,myprefix,outflag);

iparent=findobj(imain,'type','uimenu','tag','setxy');
do1menu(k_mdx,iparent,myprefix,outflag);

iparent=findobj(imain,'type','uimenu','tag','setorganization');
do1menu(k_mdo,iparent,myprefix,outflag);

myprefix='main>cursor>';

iparent=findobj(imain,'type','uimenu','tag','marker');
do1menu(k_mcm,iparent,myprefix,outflag);

iparent=findobj(imain,'type','uimenu','tag','sound');
do1menu(k_mcs,iparent,myprefix,outflag);

iparent=findobj(imain,'type','uimenu','tag','edit');
do1menu(k_mce,iparent,myprefix,outflag);





function do1menu(K,iparent,myprefix,outflag)
ff=fieldnames(K);
lf=length(ff);
   ffc=char(ff);


if outflag
   
   
   ffv=struct2cell(K);
   for ii=1:lf
      tmp=ffv{ii};
      if tmp>=32 
         tmp=setstr(tmp);
      else
         if tmp>3
            tmp=['<' int2str(tmp) '>'];
         end;
         %not strictly correct for all systems
         if tmp==1
            tmp='<left_button>';
         end;
         if tmp==2
            tmp='<middle_button>';
         end;
         if tmp==3
            tmp='<right_button>';
         end;
      end;
      ffv{ii}=tmp;   
   end;
   ffv=char(ffv);
%   keyboard;
   %some submenus may have same tag
   %assume first one is the one we want
   mypref=[myprefix get(iparent(1),'tag')];
   
   disp(' ');
   disp(['[' mypref ']']);
   disp([ffv (blanks(lf))' ffc]);
   return;
   
   
   
end;





for ii=1:lf
   mylabel=ffc(ii,:);
%   mylabel=ff{ii};
myval=setstr(getfield(K,mylabel));
myval=strrep(myval,char(1),'left_button');
myval=strrep(myval,char(2),'middle_button');
myval=strrep(myval,char(3),'right_button');


mylabel2=deblank(mylabel);
mylabel2=[mylabel2 ' .. ' myval '  '];

%mylabel2=mylabel;
%   vv=findstr(myval,mylabel);
%   if ~isempty(vv)
%      mylabel2=strrep(mylabel,myval,['&' myval]);
%      %cancel multiple ampersand
%      vvv=findstr('&',mylabel2);
%      if length(vvv)>1 mylabel2(vvv(2:end))='';end;
%   else
%      mylabel2=[mylabel ' &' myval];
%      
%   end;

hm=uimenu(iparent,'label',mylabel2,'tag',deblank(mylabel),'userdata',myval,'callback','mtxmenucb');
end;

mytype=get(iparent,'type');
if strcmp(mytype,'uimenu') set(iparent,'callback',''); end;
