function mt_ssig(siglist)
% MT_SSIG Set up access to signals
% function mt_ssig(siglist)
% mt_ssig: Version 22.03.2012
%
%	Description
%		Currently, calling this function resets all displays and signal buffers
%		In future, it should be possible to add signals to the signal list
%		Parses the signal list, then sets up signal description data structures
%		in signal axes of figure mt_organization
%
%	Syntax
%		siglist: matname.descriptor[.signame[.mem_mode]]
%			"matname" is the non-common part of the filename of the mat file
%				containing the signals
%			"descriptor" is the label of the column in variable "data" containing the signal
%			"signame" is the internal name to use to refer to the signal
%				Defaults to "descriptor"
%			"mem_mode". If present, (i.e if this field is set to any non-blank string) 
%				then data is stored in memory in the same format in which it
%				is stored in the mat file. If absent, all non-double data is converted to double
%				when loaded into memory.
%				Using this feature can save vast amounts of memory, e.g for 8-bit video data
%
%	See also
%		MT_ORG MT_GCSID MT_GSIGV MT_SCSID MT_LOADT


global MT_DATA

sampincmax=0;

%removed 5.2001
%maxchan=24;


nchan=size(siglist,1);
%if nchan>maxchan
%   disp ('Too many signals');
%   return
%end;


%reset data
%figures not yet rest

MT_DATA=[];
for ii=1:nchan MT_DATA{ii}=[]; end;


gcaold=gca;

figorgh=mt_gfigh('mt_organization');
axh=findobj(figorgh,'tag','signal_axis');

myS=get(axh,'userdata');
%        keyboard;
mypath=myS.signalpath;
reftrial=myS.ref_trial;
matpartlist='';
signamelist='';
alldescrip='';
allunit='';

maxsampinc=0;
for ichan=1:nchan
   tempstr=deblank(siglist(ichan,:));
   [matpartname,tempstr]=strtok(tempstr,'.');
   [sigdescrip,tempstr]=strtok(tempstr,'.');
   [signame,tempstr]=strtok(tempstr,'.');
   [memmode,tempstr]=strtok(tempstr,'.');
   if isempty(signame) signame=sigdescrip; end;
   
   
   memflag(ichan)=0;
   if ~isempty(memmode)
      if ~isempty(deblank(memmode))
         memflag(ichan)=1;
      end;
   end;
   
   
   %accumulate matpartnames and signal names
   matpartlist=str2mat(matpartlist,matpartname);
   signamelist=str2mat(signamelist,signame);
   
   sigstruct=struct('signal_name',signame,'mat_name',matpartname,'descriptor',sigdescrip,'flatflag',0);
   
   
   
   matname=[mypath matpartname reftrial];
   desclist=mymatin(matname,'descriptor');
   ndesc=size(desclist,1);
   unitlist=mymatin(matname,'unit',' ');
   sigstruct.dimension=[];
   if not(isempty(whos('-file',matname,'dimension')))
   sigstruct.dimension=mymatin(matname,'dimension');
   end;
   

   dataS=whos('-file',matname,'data');

   %this refers to the whole mat file, not just the signal
   %for scalar data set second dimension to 1 (see below)
   sigstruct.data_size=dataS.size;
   

   %this is the criterion for identifying data with sensor as third
   %dimension
   %This kind of data will be flattened to 2 dimensions
   
   if ndesc>1 & length(dataS.size)>2
        if isempty(sigstruct.dimension)
            disp('Sensor-style data requires dimension variable');
            return;
        end;
        
       sigstruct.flatflag=1;
        nsensor=dataS.size(3);
        unitlist=repmat(unitlist,[nsensor 1]);
        sensorlist=sigstruct.dimension.axis{3};

        if size(sensorlist,1)~=nsensor
            disp('Sensor list in dimension variable does not match data size');
            return;
        end;
        
        desctmp=repmat(desclist,[nsensor 1]);
        descnew=[];
        for isi=1:nsensor
            tmptmp=repmat(sensorlist(isi,:),[ndesc 1]);
            descnew=[descnew;tmptmp];
        end;
        
            descnew=strcat(descnew,'_',desctmp);
            desclist=descnew;
            ndesc=size(desclist,1);
   end;
   
   
   vi=strmatch(sigdescrip,desclist,'exact');
   if length(vi)~=1
      disp('!! Problem in mt_ssig !!');
      disp(['The following signal descriptor was not found in MAT file' matname ' :']);
      disp(sigdescrip);
      disp('It must match one of the items in the following list:');
      disp(desclist);
      disp('Check the following line in the signal list for clerical errors:');
      disp(siglist(ichan,:));   
      
      delete([mt_gfigh('mt_organization') mt_gfigh('mt_f(t)')]);
      
      error('!! Terminating program !!');
   end;
   alldescrip=str2mat(alldescrip,sigdescrip);   
   
   %Will be changed back to zero to flag multidimensional data
   %see below
   sigstruct.mat_column=vi;
   
   warning off;		%suppress warning messages from mymatin
   sigstruct.unit=deblank(unitlist(vi,:));
   allunit=str2mat(allunit,sigstruct.unit);   
   
   sigstruct.samplerate=mymatin(matname,'samplerate',1);
   maxsampinc=max(maxsampinc,1./sigstruct.samplerate);
   sigstruct.t0=mymatin(matname,'t0',0);
   %could be done better. See mt_loadt
   sigstruct.scalefactor=1;
   sigstruct.signalzero=0;
   sigstruct.signal_number=ichan;
%   if ~isempty(sigstruct.dimension) sigstruct.mat_column=0;end;

		warning on;
sigstruct.class_mat=dataS.class;
   
   
   
   %is this the only/best criterion for identifying
   %multidimensional data??
   
   if ndesc==1 & sigstruct.data_size(2)>1
      sigstruct.mat_column=0;
      if ~isempty(sigstruct.dimension)
         %check dimension specs are ok
         %may be able to eventually allow default dimension specs
         %for multidimensional data
         ndim=length(sigstruct.data_size);
         %for multidimensional data time must currently be the last dimension
         timdim=strmatch('time',lower(sigstruct.dimension.descriptor),'exact');
         if isempty(timdim)
            disp('mt_ssig: No time dimension?');
            disp(siglist(ichan));
         	timdim=0;   
         	%try and proceed anyway   
         else
            if timdim~=ndim
               disp('mt_ssig: Time must be last dimension for multidimensional data');
               disp(siglist(ichan));
               return;
            end;
         end;
               
         
         for idim=1:ndim
            axspec=sigstruct.dimension.axis{idim};
            if ~isempty(axspec)
%03.2012 workaround to handle colorplane specificiation like
%str2mat('red','green','blue')
                if ischar(axspec)
                    axspec=axspec(:,1);
                end;
               if length(axspec)~=sigstruct.data_size(idim)
                  disp('mt_ssig: Dimension specification does not match data');
      				disp(siglist(ichan,:));   
                  return;
               end;
            else
               if idim~=timdim 
                  disp('mt_ssig: Unexpected empty dimension axis specification');
                  disp(siglist(ichan,:));   
                  return;
               end;
            end;
         end;
         
      else
         disp('mt_ssig: Dimension specification required for multidimensional data');
         disp(siglist(ichan));
         return;
      end;

         
   else
      %cf. mt_loadt for scalar data
        %i.e now refers to the signal, not the original data variable (ever
        %used?? what makes sense for sensor data??)
      sigstruct.data_size(2)=1;
   end;
   
   
   sigstruct.class_mem='double';
   
   %allow non-double class in memory
   %only possible if no scaling will be required (or scaling has to done by mt_gdata)
   if memflag(ichan)
      if (sigstruct.scalefactor~=1) | (sigstruct.signalzero~=0)
         disp('mt_ssig: signal must be stored as double (scaling required)');
      	disp(siglist(ichan,:));   
      else
         sigstruct.class_mem=sigstruct.class_mat;
      end;
      
   end;
   
   
   %keyboard;
   axes(axh);
   %string done properly later
   ht(ichan)=text(0,ichan,'dummy','interpreter','none','fontname','courier');
   set(ht(ichan),'tag',signame,'userdata',sigstruct,'clipping','off');
   
   
   
   
end;

set(axh,'ylim',[0 nchan]);        
%elimate empty first item (str2mat)
matpartlist(1,:)=[];
signamelist(1,:)=[];
alldescrip(1,:)=[];  
allunit(1,:)=[];

for ichan=1:nchan
   set(ht(ichan),'string',[' ' signamelist(ichan,:) '==' matpartlist(ichan,:) '.' alldescrip(ichan,:) ' (' deblank(allunit(ichan,:)) ')']);
end;

%set up a unique list of mat files, with links to signals to
%allow efficient loading

unilist=unique(matpartlist,'rows');
lu=size(unilist,1);
mycell=cell(lu,1);
for ii=1:lu
   vi=strmatch(unilist(ii,:),matpartlist,'exact');
   mycell(ii)={vi};
end;

%store in userdata of signal axis

myS.signal_list=signamelist;
myS.unique_matname=unilist;
myS.mat2signal=mycell;

%max sample inc. could be useful for timesetting
%actually lcm of sample incs may be better

myS.max_sample_inc=maxsampinc;

set(axh,'userdata',myS);

axes(gcaold);

