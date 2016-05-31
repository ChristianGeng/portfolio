function [oscidata,oscitype]=mt_getmm(channame,datatime,displaylength)
% mt_getmm Get maxmin oscillogram
% function [oscidata,oscitype]=mt_getmm(channame,datatime,displaylength)
% mm_getmm: Version 15.4.98
%
% Syntax
%    Input: datatime is time in trial (2-element vector)
%			displaylength: length if display (in s.) for which oscillogram is required
%    Output:
%			oscidata: Time in column 1, amplitude values in column 2
%			oscitype: Currently either 'maxmin' or 'timewave'
%        If type is maxmin samples 1-4 etc. have same time value
%					max amp is at sample 2, min amp at sample 3


%   When the number of samples to be displayed exceeds (currently) 4096
%   a maxmin algorithm is applied. Otherwise all samples are displayed.

        %apply maxmin algorithm when number of data per plot exceeds
        %this threshold:
        mmlim=4096;
        %mmnum is number of maxmin elements per plot
        %it should probably be about equal to the number of horizontal pixels
        %it does not necessarily have to be dependent on mmlim
        %currently 4 data per maxmin element
        mmdat=4;
        mmnum=mmlim/mmdat;


           
           
           
           
           
           sf=mt_gsigv(channame,'samplerate');
           
        sampinc=1./sf;
	screendat=displaylength*sf;
           
           
 

[scratch,actualtime]=mt_gdata(channame,datatime);

            nread=size(scratch,1);

	     if (nread <= 0)
		disp ('mt_getmm: No more data');
      oscidata=[];
      oscitype='';
      return;
      
   end

	     %split depending on whether maxmin required

	     %code for maxmin

	     if screendat>mmlim
		%maxmin frame must be an integer number of samples
		%to make best use of matrix arithmetic
		%so first determine appropriate values to match
		%number of data to be displayed as closely as possible

		indinc=screendat/mmnum;
		indinc=ceil(indinc);
                mmloop=floor(nread./indinc);
                ndat=mmloop*indinc;
                if ndat<nread scratch((ndat+1):nread)=[]; end;

		xtemp=0:(mmloop-1);
		xtemp=xtemp*sampinc*indinc;
                xtemp=xtemp+actualtime(1);

		%set up complete x axis vectors
		%each of the 4 values in each maxmin element has same x position

		xtemp=[xtemp;xtemp;xtemp;xtemp];

		%input data is reshaped to a indinc*mmloop matrix
		% output data is initially stored in a 4*mmloop matrix
		%i.e one column per pass thru the loop
		%then resulting matrix is converted to a column vector for
		%display
		scratch=reshape(scratch,indinc,mmloop);
		mmbuf=zeros(mmdat,mmloop);
		mmbuf(1,:)=scratch(1,:);
		mmbuf(mmdat,:)=scratch(indinc,:);
		%max and min function store result per column as row vector
		mmbuf(2,:)=max(scratch);
		mmbuf(3,:)=min(scratch);

		%convert from matrix to column vector
		nn=mmloop*mmdat;
		oscdat=reshape(mmbuf,nn,1);

		xctl=reshape (xtemp,nn,1);
      oscitype='maxmin';
      
		clear scratch;
		% end of maxmin calculation----------------------

	     else
	         %straightforward display
	         %set up x control vector
	         %this is actually only necessary when time parameters have been
	         %changed.
	         %note it would be preferable to choose t0 so it corresponds
	         %to an actual sample position for each channel
	         %i.e it should be a multiple of sampinc of the channel with
	         %the lowest sampling rate
	         %otherwise there may be slight discrepancies between
	         %xctl vectors for differnt channels

                 %could check if samplerate=lastsamplerate

	         xtemp=0:nread-1;
	         xtemp=xtemp*sampinc;
                 xtemp=xtemp+actualtime(1);
	         %store xctl vector, converting to column vector
	         xctl=xtemp';
	         oscdat=scratch;
            oscitype='timewave';
                 clear scratch;
	  %end of maxmin choice
	  end;
     oscidata=[xctl oscdat];
     
