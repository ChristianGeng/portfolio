function cd=mt_gscud(iwant);
% MT_GSCUD Get sub-cut data
% function cd=mt_gscud(iwant);
% mt_gscud: Version 12.4.98
%
%	Syntax
%		Input arg specifies sub-cut data fields in struct in current cut axis
%		currently: 'data','label',; Subsets of 'data' see below
%		No input arg: Returns 'data' field, i.e cutstart, cutend, cuttype, trial_number
%			(Actually returns all cut data: may be more elements in future)
%			Note: this is different from some similar routines which return complete struct as default
%		If input arg is 'start', 'end', 'length', 'type', or 'trial_number' 
%			returns a column vector with only this information from within the 'data' field
%		if input arg is 'n' returns number of subcuts (scalar)
%
%	See also
%   MT_GCCUD for current cut data

        %
	cd=[];
	figorgh=mt_gfigh('mt_organization');
   caxh=findobj(figorgh,'tag','current_cut_axis');
   
        
   mydata=get(caxh,'userdata');
   
   tt=getfield(mydata,'sub_cut_data');
   if nargin==0 iwant='data'; end;
   
   if strcmp(iwant,'n')
      cd=0;
      if ~isempty(tt) cd=size(tt,1);end;
      return;
   end;
   if strcmp(iwant,'label')
      cd=getfield(mydata,'sub_cut_label');
      return;
   end;
   if strcmp(iwant,'data')
      cd=tt;
      return;
   end;
   
           specialfield=str2mat('start','end','length','type','trial_number');
           vis=strmatch(iwant,specialfield);
           if isempty(vis)
           
           
           
              disp(['mt_gscud: Bad field name? ' iwant]);
              
              return;
           else
              
              if strcmp (iwant,'start') cd=tt(:,1);end;
              if strcmp (iwant,'end') cd=tt(:,2);end;
              if strcmp (iwant,'length') cd=tt(:,2)-tt(:,1);end;
              if strcmp (iwant,'type') cd=tt(:,3);end;
              if strcmp (iwant,'trial_number') cd=tt(:,4);end;
              
           end;
           
              
   
