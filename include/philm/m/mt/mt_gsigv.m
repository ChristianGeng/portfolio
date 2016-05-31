function sigvar=mt_gsigv(signames,varname);
% MT_GSIGV Get signal description variables
% function sigvar=mt_gsigv(signames,varname);
% mt_gsigv: Version 18.3.98
%
%	Syntax
%
%		signames
%			List of signal names (as string matrix)
%
%		varname 
%			Name of variable, i.e field in signal structure
%
%		Special cases for input args
%			No args: return list of signals
%			1 arg: return the complete signal structure for that signal
%							(currently restricted to one signal, could upgrade to cell array of structure??)
%
%		sigvar
%			For numeric scalar or vector data, returns with channels moving across columns
%			thus multichannel scalar data results in a row vector
%			For string scalar or vector data, channels move down the rows
%			(string matrices are appended using str2mat)
%
%	Description
%		Stored in userdata of text object corresponding to signal 
%		in axes "signal_axis" of organization figure
%		Fields are:
%
%		signal_name
%			Internal name to identify the signal. Default is same
%			as "descriptor" (see below). See mt_ssig
%
%		mat_name
%			the non-common part of the mat file name
%
%		descriptor
%			The entry in the descriptor variable in the mat file identifying the signal
%
%		mat_column
%			For scalar signals:
%				The column where the signal is located in the data variable in the mat file
%			For multidimensional signals:
%				Set to zero (the signal corresponds to the whole of the data variable)
%
%		unit
%			Copied from corresponding variable in mat file
%
%		samplerate
%			Copied from corresponding variable in mat file
%			Defaults to 1
%			Empty or NaN may be used in future to flag non-timeseries data
%
%		scalefactor
%			Copied from corresponding variable in mat file. Defaults to 1
%
%		signalzero
%			Copied from corresponding variable in mat file. Defaults to 0
%
%		signal_number
%			Internally-used number to identify cell in common variable
%			MT_DATA where data is stored in memory
%			May be used in future to identify disk cache file for very large variables
%
%		dimension
%			Copied from corresponding variable in mat file. Defaults to empty,
%			but must be present for multidimensional data
%			It is itself a structure with the following fields:
%			"descriptor", "unit" and "axis".
%			These specify each dimension of multidimensional data (time must be the last dimension)
%			"descriptor" and "unit" are string matrices with ndim rows
%			"axis" is a cell array with ndim cells. Each cell must be a numeric vector whose length
%			corresponds to the size of the corresponding dimension of the main data variable
%			(or a string variable with a corresponding list of labels)
%
%		class_mat
%			The class of the data variable as stored in the mat file
%
%		class_mem
%			The class of the signal as stored in memory
%			Normally signals that are not stored as double in the corresponding mat file
%			will be converted to double when the trial is loaded (see mt_loadt).
%			However, this is blocked when "class_mem" is set to "class_mat".
%			This is however only allowed when the signals do not require scaling,
%			i.e "scalefactor" and "signalzero" must be 1 and 0, respectively (see above)
%			When data is retrieved from memory by mt_gdata, non-double data is in turn normally
%			also converted to double
%
%		data_size
%			A vector specifying the size of each dimension of the signal
%			(for scalar data the vector has length 2, but the second element is always 1)
%
%	See also
%		MT_ORG MT_SSIG MT_GCSID MT_SCALI MT_LOADT
%		MT_GDATA: returns the signal data itself

sigvar=[];
figorgh=mt_gfigh('mt_organization');
saxh=findobj(figorgh,'tag','signal_axis');
signal_list=mt_gcsid('signal_list');
if nargin==0
   sigvar=signal_list;
   return;
end;

nn=size(signames,1);
%check not empty etc.
if nargin<2 nn=1;end;  %temporary

for ii=1:nn
   myname=deblank(signames(ii,:));
   ht=findobj(saxh,'tag',myname);
   if isempty(ht)
      disp(['mt_gsigv: Bad signal name? ' myname]);
      return;
   end;
   
   sigstruct=get(ht,'userdata');
%   disp(myname)
%   disp(sigstruct)
   if nargin<2
      alldata=sigstruct;
   else
      
      fieldlist=fieldnames(sigstruct);
      
      vi=strmatch(varname,fieldlist);
      
      if isempty(vi)
         
         disp(['mt_gsigv: Bad field name? ' varname]);
         
         return;
      end;
      mydata=getfield(sigstruct,varname);
      
      %assemble into output matrix if sizes are compatible
      if ii==1
         alldata=mydata;
      else
         if isstr(mydata)
            alldata=str2mat(alldata,mydata);
         else
            if size(alldata,1)==size(mydata,1)
               alldata=[alldata mydata];
            else
               disp ('mt_gsigv: incompatible data?');
               return;
            end;
         end;
      end;
      
      
   end;
   
end;
sigvar=alldata;
