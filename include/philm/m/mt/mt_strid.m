function mt_strid(myfield,mydata)
% mt_strid Set trial data
% function mt_strid(myfield,mydata)
% mt_strid: Version 13.4.98

%        trialS=struct('number',0,'label','','cut_data',[],'cut_label','','signal_t0',[],'signal_tend',[],'maxmin_signal','');

figorgh=mt_gfigh('mt_organization');
taxh=findobj(figorgh,'tag','trial_axis');
myS=get(taxh,'userdata');

fieldlist=fieldnames(myS);
vi=strmatch(myfield,fieldlist);
if isempty(vi)
   disp(['mt_strid: Bad field name; ' myfield]);
   return;
end;


myS=setfield(myS,myfield,mydata);

set(taxh,'userdata',myS);

%related graphics etc.

if strcmp(myfield,'cut_data')


			htemp=findobj (taxh,'tag','trial_cut_start');
         
         %y axis is actually signal number. Scale cut type to fit
         
         typeS=get(htemp,'userdata');
         mytype=mydata(:,3)-typeS.min_type;
         mylim=get(taxh,'ylim');
         myfac=mylim(2)./(typeS.max_type-typeS.min_type);
         mytype=mytype*myfac;
         
         set(htemp,'xdata',mydata(:,1),'ydata',mytype);
           htemp=findobj (taxh,'tag','trial_cut_end');
           set(htemp,'xdata',mydata(:,2),'ydata',mytype);
        end;
        
           
        %maybe better if ydata done in mt_ssig
        if strcmp(myfield,'signal_t0')
           
           ll=length(mydata);
           htemp=findobj(taxh,'tag','signal_t0');
                 set(htemp,'xdata',mydata,'ydata',(1:ll)');
              end;
        if strcmp(myfield,'signal_tend')
           
           ll=length(mydata);
                 htemp=findobj(taxh,'tag','signal_tend');
                 set(htemp,'xdata',mydata,'ydata',(1:ll)');
              end;
              
           
           
           
			if strcmp(myfield,'label')           
           htemp=get(taxh,'title');
           set(htemp,'string',mydata);
        end;
        
           
        if strcmp(myfield,'number')
           caxh=findobj(figorgh,'tag','cut_file_axis');
           htemp=findobj(caxh,'tag','current_trial_number');
           set(htemp,'xdata',[mydata;mydata]);
        end;
        