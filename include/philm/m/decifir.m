function odata = decifir(b,idata,r)
% DECIFIR FIR filtering and downsampling (from decimate)
% function odata = decifir(b,idata,r)
% decifir: Version 8.01.2002
%
%	Description
%		Variation of DECIMATE, for use with FIR filter only
%		Phil, first version 11.96
%		Filter coefficients must be provided by calling program
%		Unlike DECIMATE, filtering is also carried out even if r==1
%		so can be used for general purpose FIR filtering
%		Advantage over FILTFILT is that
%		mirroring of data to avoid startup effects is more appropriate
%		for FIR filters - less likely to have problems with short sequences.
%		(The input sequence must be at least (nfilt-1)/2 in length, otherwise result is empty.)
%		Also if input contains NaNs output is appropriate for
%		FIR filter whereas output of FILTFILT will always be all NaNs.
%		If length of filter is even, then the output data will be delayed by half a sample:
%		add half the sample interval to the MAT file's t0 variable if desired, to compensate.
%		Input data should be a column vector (multiple column input will be available shortly).
%		(Note: The length of the output sequence is given by: length(1:r:length(idata));
%		this may be different from the result of DECIMATE.)
%
%	See Also DECIMATE FILTFILT

odata=[];

if nargin < 2
   error('Not enough input arguments.')
end
if nargin < 3
   r=1;
end
if abs(r-fix(r)) > eps
   error('Resampling rate R must be a positive integer.')
end
if r <= 0
   error('Resampling rate R must be a positive integer.')
end

if size(idata,1)==1 idata=idata'; end;	%normally allow multiple columns, but assume this is a special case

%nout = ceil(nd/r); (may no longer be correct. 2.02)
[nd,n]=size(idata);

% prepend sequence with mirror image of first points so that transients
% can be eliminated. then do same thing at right end of data sequence.
% phil 2.02 this has been changed from original code in decimate
% in order to minimize the length of the mirrored sequences.


nfilt = length(b);

%this simplifies handling of the mirrored sequences and allowing for group delay
if rem(nfilt,2)==0
   if size(b,1)>=size(b,2)
      b=[0;b];
   else
      b=[0 b];
   end;
	nfilt=nfilt+1;   
end;



nmir=round((nfilt-1)/2);

if nd<nmir+1
   error('Input sequence is too short');
end;

if n>1
   error('Multicolumn input not yet implemented');
end;

%needs working out for multicolumn input
itemp1=2*idata(1)-idata((nmir+1):-1:2);

itemp2=2*idata(nd)-idata((nd-1):-1:(nd-nmir));

odata= filter(b,1,[itemp1;idata;itemp2]);

%keyboard

% finally, select only every r'th point from the interior of the lowpass
% filtered sequence
odata = odata(nfilt:r:end);
