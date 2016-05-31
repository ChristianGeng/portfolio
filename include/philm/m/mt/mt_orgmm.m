function mt_orgmm(taxh,maxminsig)
% mt_orgmm Plot maxmin envelope in axis of organization figure
% function mt_orgmm(taxh,maxminsig)
% mt_orgmm: Version 16.4.98


if ~strcmp(maxminsig,'<none>')
   displaytime=get(taxh,'xlim');
   displaylength=diff(displaytime);
   amplim=get(taxh,'ylim');
   
   hmax=findobj(taxh,'tag','osci_max');
   hmin=findobj(taxh,'tag','osci_min');
   
   
   
   
   [oscidata,oscitype]=mt_getmm(maxminsig,displaytime,displaylength);
   if ~isempty(oscitype)
      oscimax=max(oscidata(:,2));oscimin=min(oscidata(:,2));
      osciamp=oscimax-oscimin;
      oscidata(:,2)=(oscidata(:,2)-oscimin)./osciamp;
      oscidata(:,2)=(oscidata(:,2)*diff(amplim))+amplim(1);
      if strcmp(oscitype,'timewave')
         %fiddling about with scaling could be avoided by having another overlapping axis
         
         set(hmax,'xdata',oscidata(:,1),'ydata',oscidata(:,2));
         set(hmin,'xdata',[],'ydata',[]);
      end;
      if strcmp(oscitype,'maxmin')
         mymax=oscidata(2:4:end,:);
         mymin=oscidata(3:4:end,:);
         set(hmax,'xdata',mymax(:,1),'ydata',mymax(:,2));
         set(hmin,'xdata',mymin(:,1),'ydata',mymin(:,2));
      end;
   else
         set(hmax,'xdata',[],'ydata',[]);
         set(hmin,'xdata',[],'ydata',[]);
      
   end;
end;
