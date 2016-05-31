function mulsplice(cutname,recpath,reclist,cuttype,exportname,exporttype,exportfmt,exportext);
% MULSPLICE Splice(export) multiple STF and REC files, store as MAT files,
% function mulsplice(cutname,recpath,reclist,cuttype,exportname,exporttype,exportfmt,exportext);
% mulsplice: Version 21.9.99
%
%	Purpose
%		Store all data for each cut in individual MAT or raw files
%           main current use: make old REC or STF files available for use
%           with MT functions
%
%	Syntax
%		recpath: actually the common part of the REC file names
%		reclist: string matrix of REC or STF file names
%		cuttype: currently must be explicitly provided. Only cuts in file cutname with specified cuttype are analyzed
%		exportname: common part of output file name
%		Remaining input arguments are optional
%		exporttype: current choices are 'mat' (default) or 'raw'. ('wav' may be coming)
%		exportfmt: Defaults to 'double'. For 'raw' export specifies data format.
%			For both 'mat' and 'raw', if the format is 'short', any scaling of the input data is ignored
%			and the data is rounded before output.
%			This can save a lot of disk space especially for mat files of typical 16 bit audio data.
%			Note: The most appropriate scaling for all possible output formats has not yet been worked out
%		exportext: specifies extension, for 'raw' export. If not specified, the trial number determines the extension
%			for mat export specifies an optional text file to be included in the comment variable
%
%	Notes
%		Calling program should delete all figures after termination
%
%	Updates
%		4.97. version to use with mm_org setting up access to signal files
%			Raw integer output temporarily disabled
%		10.87 --re-enabled
%		2.98. Output comment variable standardized. descriptor and unit variables
%			generated and returned as output variables
%		4.98	mulsplice separated off from mulpva. Uses trial number not cut number in export file name
%		8.99 Allow matlab single precision storage, if version 5.3 or above
%		9.99 Allow only short, single or double as formats. If storing in mat file short format is actually stored
%				as double, but scaling is cancelled and data is rounded, so matlab will normally use a space-saving format
%				transparently in the disk files

myversion=version;
diary on;
functionname='Mulsplice: Version 21.9.99';
disp (functionname);
namestr=['<Start of Comment> ' functionname crlf];
if myversion(1)>'5'
   namestr=[namestr datestr(now,0) crlf];
end;
%identifier?????

diary off;
[nchan,ncut,sampincmax]=mm_org(cutname,recpath,reclist);
diary on;
nrec=nchan;
%First optional argument
exportarg=6;



databufsize=200000;   %really needed??

cutdata=mm_gcbud;
cutlabel=mm_gcbud('label');
sf=mm_gtagd(1:nchan,'samplerate');
sampinc=1./sf(1);


%cut file should have at least 4 parameters
%watch out for possible future updates to cutfiles

vv=find (cutdata(:,3)==cuttype);
cutdata=cutdata(vv,:);
cutlabel=cutlabel(vv,:);
[ncut,nparc]=size(cutdata);	%nparc should be 3 or 4
if nparc<4
	disp('Inserting dummy trial numbers in cut data');
	cutdata=[cutdata (1:ncut)'];
end;


cutdata(:,1:2)=round(cutdata(:,1:2)*sf(1))./sf(1);

%main loops thru rec files and cuts
namestr=[namestr 'Cut file name: ' cutname crlf];

%include cuttype label if possible?????
cut_type_label='';
cut_type_value=mymatin(cutname,'cut_type_value');
if ~isempty(cut_type_value)
   vvl=find(cut_type_value==cuttype)
   if ~isempty(vvl)
      cut_type_label=mymatin(cutname,'cut_type_label');
      cut_type_label=cut_type_label(vvl,:);
   end;
end;

namestr=[namestr 'Cut type used: ' int2str(cuttype) ' "' cut_type_label '"' crlf];
namestr=[namestr 'Signal file path: ' recpath crlf];
namestr=[namestr 'Signal files: ' strm2rv(reclist,' ') crlf];

%set up complete descriptors and units

descriptor=mm_gtagd(1:nchan,'descriptor');
unit=mm_gtagd(1:nchan,'unit');


%set up export
outformat='double';
%cancelled , 9.99
%[dodo,dodo,outlength,dodo]=stiffdtd(outformat);
outlength=8;
matexport=1;


expnumlength=length(int2str(max(cutdata(:,4))));
%check number string not too long??
if nargin >= exportarg
   if strcmp(exporttype,'raw') matexport=0;end;   
end;

if nargin>= (exportarg+1)
   %allow 'input' as format specification???
   %if outformat is integer cancel any input scaling.....
   outformat=exportfmt;
   outlength=0;
   
   %9.99 only allow these formats:
   if strcmp('double',lower(outformat)) outlength=8;end;
   if strcmp('single',lower(outformat)) outlength=4;end;
   if strcmp('short',lower(outformat)) outlength=2;end;
   
   
   
   %cancelled, 9.99
   %get output length
   %   [dodo,dodo,outlength,dodo]=stiffdtd(outformat);
   
end;
disp (['Output length of each data value (in bytes) ' int2str(outlength)]);

if ~outlength
   disp('Bad format?');
   return;
end;


namestr=[namestr 'Output format: ' outformat crlf];


%3.98
%get comment from 1st signal file
%allow alternative comment????

reccomment=mm_gtagd(1,'comment');

namestr=[namestr '==============================' crlf];
namestr=[namestr 'Comment from first signal file' crlf];
namestr=[namestr '==============================' crlf];
namestr=[namestr reccomment crlf];





if ~matexport              
   %unless extension explicitly  supplied put trial number in extension
   myextension=[];
   if nargin >= (exportarg+2) myextension=exportext; end;
end;

if matexport              
   commentfile='';
   if nargin >= (exportarg+2) commentfile=exportext; end;
   if ~isempty(commentfile)
      morecomment=readtxtf(commentfile);
      if ~ischar(morecomment) commentfile=''; end;
   end;
   if ~isempty(commentfile)
      
      namestr=[namestr '==================================' crlf];
      namestr=[namestr 'Comment from external comment file "' commentfile '"' crlf];
      namestr=[namestr '==================================' crlf];
      namestr=[namestr morecomment crlf];
      
   end;      
   
end;


namestr=[namestr '<End of Comment> ' functionname crlf];

comment=namestr;



%next 2 only needed for export in integer formats
scalefactor=mm_gtagd(1:nchan,'scalefactor',1);
signalzero=mm_gtagd(1:nchan,'signalzero',0);

%i.e output data is correctly scaled
if outlength>2
   scalefactor=ones(nchan,1);
   signalzero=zeros(nchan,1);
end;

%use trial label for item_id if possible
triallabelok=0;
trial_number_value=mymatin(cutname,'trial_number_value');
if ~isempty(trial_number_value)
   trial_number_label=mymatin(cutname,'trial_number_label');
   if ~isempty(trial_number_label) triallabelok=1;end;   
   
end;


diary off;

%main loop, thru cuts
for icut=1:ncut
   disp(cutlabel(icut,:));
   itrial=cutdata(icut,4);
   timspec=cutdata(icut,1:2);
   %read data
   databuf=mmxxydis(1:nchan,timspec,sf(1));
   
   
   %reverse scaling if export required in short format
   %               see scaleit.m (mm_gdata.m)
   %               !!there will be problems if scaleit is ever changed!!
   %               assumes y=(x*scalefactor)+signalzero
   
   if strcmp('short',lower(outformat))
      for idodo=1:nchan
         databuf(:,idodo)=round((databuf(:,idodo)-signalzero(idodo))./scalefactor(idodo));
      end;
   end;
   
   data=databuf;
   
   
   
   
   
   %for mat export include a more complete set of variables
   % to match stf files
   numbstr=int2str0(itrial,expnumlength);
   
   if matexport
      samplerate=sf(1);
      item_id=deblank(cutlabel(icut,:));
      if triallabelok
         vvt=find(trial_number_value==itrial)
         if length(vvt)==1
            item_id=deblank(trial_number_label(vvt,:));
         	disp(item_id);   
         end;
      end;
      
      if strcmp(lower(outformat),'single')
         data=single(data);
      end;
      
      eval (['save ' exportname numbstr ' data descriptor unit samplerate comment scalefactor signalzero item_id']);
   else;
   
   %if raw, transpose matrix??
      %use stf routines as much as possible?????
      outname=exportname;
      if isempty (myextension)
         outname=[outname '.' numbstr];
      else
         outname=[outname numbstr '.' myextension];
      end;
      disp (outname);
      %allow architecture spec.???
      %check result
      
      fidout=fopen(outname,'w');
      if fidout <=2
         error ('Output file error');
      end;
      icheck=fwrite (fidout,data,outformat);
      status=fclose(fidout);
   end;                     %raw export
   
   
end;    %cut loop

status=fclose ('all');
