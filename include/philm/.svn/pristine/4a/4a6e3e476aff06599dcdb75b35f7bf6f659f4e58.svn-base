function mt_sdata(signame,data,time);
% MT_SDATA Set signal data; time specified in seconds
% function mt_gdata(signame,data,time);
% mt_sdata: Version 29.05.04
%
%	Syntax
%		Time: normally a 2-element vector (start and end), in seconds
%			Note that the sample directly at the end time is not returned.
%			Thus requesting data for time [0 1] will return 10000 samples when samplerate is 10kHz
%				and not 10001 samples
%			n.b time specified re. signal file, not current cut.
%			Defaults to complete trial
%			If time only has one element, just the sample at that time is returned
%				note: the two-element version of time with start and end equal returns nothing
%		actualtime: Optional. Actual start and end of data returned.
%			This can differ from the input argument time firstly because of rounding to actual sample location
%			and secondly because start and end may have to be clipped if the requested time is outside the
%			range of the data (a warning message is issued in these cases)
%			Note, however, that when only a single sample is requested (length of time ==1) and when the
%			requested time is outside the range of the data, then output data is empty, actualtime is [NaN NaN]
%			and no warning message is issued.
%
%	Remarks
%		Currently restricted to single channel; see mtxxydis. May upgrade to return cell array of multiple channel data?
%		May eventually include a third argument to allow blocking of
%		conversion of non-double data to double
%
%	See also
%		MT_GSIGV, MT_LOADT, MT_SSIG MT_GDATA MT_SHOFT

global MT_DATA

myS=mt_gsigv(signame);
if isempty(myS)
   disp('mt_gdata: No signal information?');
   return;
end;

sf=myS.samplerate;
t0=myS.t0;
signum=myS.signal_number;
mycol=myS.mat_column;	%flags multidimensional data

datasize=myS.data_size;
ndim=length(datasize)-1;

nsamp=datasize(1);
if ~mycol nsamp=datasize(end); end;


%check simple scalar data, e.g mat_column ne 0??????
%can also check with datasize=size(MT_DATA{signum})

if nargin>2
   
   doone=length(time)==1;
   
   mytime=time-t0;
   if mytime(1)<0
      disp('mt_sdata: Start time out of range');
      return;
   end;
   mytime=round(mytime*sf);
   mytime(1)=mytime(1)+1;
   
   if doone mytime=[mytime mytime]; end;
   
   if mytime(2)>nsamp
      disp('mt_sdata: End time out of range');
        return;
      
   end;
   
   if mytime(1)>mytime(2)
      disp('mt_gdata: Bad time spec');
      return;
   end;
   
else		%retrieve whole trial
   mytime=[1 nsamp];
end;

tvec=mytime(1):mytime(2);
nt=length(tvec);

%not yet worked out for multidimensional case
nd=length(data);

if length(tvec)~=length(data)
    disp('mt_sdata: Time spec does not match length of data');
    disp([nt nd]);
    return;
end;

   MT_DATA{signum}(tvec)=data;

   
   return;
  

%relics of mt_gdata for multidiemnsional and non-double handling

%this will be more complicated for multidimensional data
%always ensure time is nth dimension on loading?

if mycol
   mydata=MT_DATA{signum}(mytime(1):mytime(2));
else
   if ndim==1 mydata=MT_DATA{signum}(:,mytime(1):mytime(2));end;
   if ndim==2 mydata=MT_DATA{signum}(:,:,mytime(1):mytime(2));end;
end;

iblock=0;	%temporary???

%normally non-double data in memory should be converted to double
if ~isa(mydata,'double');
   if ~iblock
      mydata=double(mydata);
   end;
end;



