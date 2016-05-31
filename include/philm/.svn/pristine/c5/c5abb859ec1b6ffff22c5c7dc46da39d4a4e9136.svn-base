function viewmtgraph
% VIEWMTGRAPH Show mt graphics objects and userdata structures
% function viewmtgraph
% viewmtgraph: Version ??

hf=findobj('type','figure');
nf=length(hf);
identinc=5;
for ifig=1:nf
   figtag=get(hf(ifig),'tag');
   if any(findstr('mt_',figtag)==1)
      ident=1;
      myshow(hf(ifig),ident,identinc,3)
      
      ha=findobj(hf(ifig),'type','axes');
      na=length(ha);
      for iax=1:na
         mylevel=1;
         myshow(ha(iax),1+(identinc*2*mylevel),identinc,2)
            
            
            hc=get(ha(iax),'children');
            nc=length(hc);
            for ich=1:nc
               mylevel=2;
               myshow(hc(ich),1+(identinc*2*mylevel),identinc,1)
            end;	%loop (children)
            
            
      end;	%axis loop
      
   end;	%figure tag
end;	%figure loop



function myshow(hf,ident,identinc,nline)

figtag=get(hf,'tag');
if ~isempty(figtag)
	mytype=get(hf,'type');
   disp([rpts([nline ident],' ') rpts([nline 30],'-')]);
   disp([rpts([1 ident],' ') mytype ' "' figtag '"']);
   figdat=get(hf,'userdata');
   if isstruct(figdat)
      tmpdent=ident+identinc;
      myfields=char(fieldnames(figdat));
      [nfields,nfchar]=size(myfields);
      %         disp([rpts([nfields ident+identinc],' ') myfields]);
      tmpchar=rpts(tmpdent-5,'_');
      tmpchar2=rpts(10,'+');
      eval(['figdat.x' tmpchar 'userdata_end=tmpchar2;']);
      disp(' ');
      disp([rpts([1 tmpdent],' ') 'userdata_start ' tmpchar2]);
      disp(figdat);   
%      disp([rpts([1 tmpdent],' ') '+++++  userdata end  +++++']);
      disp(' ');
   end;
end;

