function mtxsubcutdis(hcur,orgdat,cutdata,cutlabel,mymessage);
% MTXSUBCUTDIS Display sub-cut boundaries and labels
% function mtxsubcutdis(hcur,orgdat,cutdata,cutlabel,mymessage);
% mtxsubcutdis: Version 12.10.99

axes(hcur);
nsubxy=size(cutdata,1);
maxt=get(hcur,'ylim');
maxt=maxt(1);
tchar=orgdat.sub_cut_marker;
if size(tchar,1)==2
   tline=orgdat.sub_cut_linestyle;
   
   if size(tline,1)~=2 tline=str2mat('none','none');end;
   subtag=str2mat('start','end');
   
   if nsubxy                  
      
      hx(1)=findobj(hcur,'tag','sub_cut_start');
      hx(2)=findobj(hcur,'tag','sub_cut_end');
      for ii=1:2
         ib=cutdata(:,ii);
         xx=([ib ib ones(nsubxy,1)*NaN])';
         yy=([zeros(nsubxy,1) cutdata(:,3) ones(nsubxy,1)*NaN])';
         set (hx(ii),'xdata',xx(:),'ydata',yy(:),'visible','on');
         
         try
            set(hx(ii),'marker',deblank(tchar(ii,:)));
            set(hx(ii),'linestyle',deblank(tline(ii,:)));
         catch
            disp([mymessage ': Bad sub_cut marker or linestyle']);
            disp(lasterr);
         end;
         
         
      end;	%start/end loop
      
      %label position
      ib=cutdata(:,1)+((cutdata(:,2)-cutdata(:,1))*orgdat.sub_cut_labelposition);
      
      %don't bother doing text object if position is nowhere near segment boundaries
      vv=find((ib>min(cutdata(:,1))) & (ib<=max(cutdata(:,2))));
      if ~isempty(vv)
         ib=ib(vv);
         cutlx=cellstr(cutlabel(vv,:));		%eliminate trailing blanks for better  center alignment		
         mytype=cutdata(vv,3);
         hlt=text(ib,mytype,cutlx);
         set (hlt,'tag','sub_cut_label','visible','on');
         %vertical orientation?, horizontal orientation??   
         %this won't be best choice for all label position values
         set(hlt,'horizontalalignment','center'); 
         set(hlt,'verticalalignment','top');		%keeps label out of way of markers 
         
      end;
   end;	%nsubxy                  
   
end;	%sub_cut_marker

