function cd=mt_gcufd(iwant);
% mt_gccud Get cut file data
% function cd=mt_gcufd(iwant);
% mt_gcufd: Version 12.4.98
%
% Syntax
%   Input arg specifies field in struct in cutfile axis
%        currently: 'filename','data','label','trial_label';
%   No input arg: Returns 'data' field, i.e cutstart, cutend, cuttype, trial_number
%                 (Actually returns all cut data: may be more elements in future)
%				Note: this is different from some similar routines which return complete struct as default
%   If input arg is 'start', 'end', 'length', 'type', or 'trial_number' returns a column vector with only this information
%			from within the 'data' field
%
% See also
%   mm_gccud for current cut data

        %
	cd=[];
	figorgh=mt_gfigh('mt_organization');
   caxh=findobj(figorgh,'tag','cut_file_axis');
   
        
   mydata=get(caxh,'userdata');
   if nargin==0 iwant='data'; end;
   
   if strcmp(iwant,'n')
      cd=size(mydata.data,1);
      return;
   end;
   
   
   
        fieldlist=fieldnames(mydata);
        
        vi=strmatch(iwant,fieldlist);
        
        if isempty(vi)
           
           specialfield=str2mat('start','end','length','type','trial_number');
           vis=strmatch(iwant,specialfield);
           if isempty(vis)
           
           
           
              disp(['mt_gcufd: Bad field name? ' iwant]);
              
              return;
           else
              
              tt=getfield(mydata,'data');
              if strcmp (iwant,'start') cd=tt(:,1);end;
              if strcmp (iwant,'end') cd=tt(:,2);end;
              if strcmp (iwant,'length') cd=tt(:,2)-tt(:,1);end;
              if strcmp (iwant,'type') cd=tt(:,3);end;
              if strcmp (iwant,'trial_number') cd=tt(:,4);end;
              
           end;
           
              
        else
           
        
        cd=getfield(mydata,iwant);
        
     end;
     
   
