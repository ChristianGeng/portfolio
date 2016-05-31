function newdata=deinterlacep(data,firstfield);
% DEINTERLACEP Deinterlace a grayscale or truecolor image
% function newdata=deinterlacep(data,firstfield);
% deinterlacep: Version 14.05.2012
%
%   Description
%       Input data must be a grayscale image (2 dimensions) or truecolor image
%       with color planes as the third dimension. 
%       Input is assumed to be uint8.
%       Output (newdata) will also be uint8. It has 2 rows less than the
%       input because the first and last rows are discarded after
%       interpolation.
%       (If number of rows in input is odd then an additional row at the
%       end is discarded.)
%       The output will have one more dimension than the input, with time
%       (earlier/later field) forming the last dimension.
%       firstfield (optional) can have possible values of 1 or 2 to control which
%       field is regarded as earlier in time. Default to 1
%
%   See Also
%       DEINTERLACE handles a time series of single-plane images

ifirst=1;
if nargin>1
    if ~isempty(firstfield)
        ifirst=firstfield;
        %check range is ok?    
    end;
end;



poff=[1 2];
if ifirst==2 poff=[2 1]; end;

%as last line of first field, and first line of second field are outside
%the interpolation region, and as cubic interpolation uses a 4x4
%neighbourhood trim off rows and columns at end
mytrim=2;

nrow=size(data,1);

if mod(nrow,2)
    nrow=nrow-1;
end;

ncol=size(data,2);

nplane=size(data,3);


%to store fields after interpolating up to full frame size
%If there is only one plane (grayscale) this will be squeezed out at end
newdata=repmat(uint8(0),[nrow ncol nplane 2]);

%set up vectors for interp2
%note: haven't yet managed to work out how to use imresize so it leaves the
%original lines unchanged

% x1=interp2(1:6,1:2:11,x,(1:6)',(2:2:12),'*cubic')
xv=1:ncol;
yv=1:nrow;
yv1=1:2:nrow;
yv2=2:2:nrow;

for iplane=1:nplane
%    disp(ii);
    x1=data(yv1,:,iplane);
    x2=data(yv2,:,iplane);
    newdata(yv1,:,iplane,poff(1))=x1;
    newdata(yv2,:,iplane,poff(2))=x2;
    
    x1=double(x1);
    x2=double(x2);
    

	%note: imresize does not work appropriately, i.e in effect introduces
    %noise in the time domain
    
    x1=interp2(xv,yv1,x1,xv',yv2,'*cubic');
    x2=interp2(xv,yv2,x2,xv',yv1,'*cubic');
    
    
    %change order of first and second field if necessary
    newdata(yv2,:,iplane,poff(1))=uint8(round(x1));
    newdata(yv1,:,iplane,poff(2))=uint8(round(x2));
    
end;


newdata=squeeze(newdata((mytrim+1):(end-mytrim),(mytrim+1):(end-mytrim),:,:));

