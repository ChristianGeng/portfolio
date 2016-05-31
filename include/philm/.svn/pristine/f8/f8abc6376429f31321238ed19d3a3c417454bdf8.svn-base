function newdata=deinterlace(data,firstfield,flipflag);
% DEINTERLACE Deinterlace a series of images
% function newdata=deinterlace(data,firstfield,flipflag);
% deinterlace: Version 25.03.10
%
%   Description
%       Input data will normally be a series of grayscale images with time
%       as the third dimension. True color images are currently not handled
%       directly (call separately for each color plane if necessary).
%       Input is assumed to be uint8.
%       Output (newdata) will also be uint8. It has 2 rows less than the
%       input because the first and last rows are discarded after
%       interpolation.
%       (If number of rows in input is odd then an additional row at the
%       end is discarded.)
%       firstfield (optional) can have possible values of 1 or 2 to control which
%       field is regarded as earlier in time. Default to 1
%       flipflag (optional, defaults to true). Controls up-down flipping of
%       the output data

ifirst=1;
if nargin>1
    if ~isempty(firstfield)
        ifirst=firstfield;
        %check range is ok?    
    end;
end;

doflip=1;
if nargin>2
    doflip=flipflag;
end;



poff=[0 1];
if ifirst==2 poff=[1 0]; end;

nrow=size(data,1);

if mod(nrow,2)
    nrow=nrow-1;
end;

ncol=size(data,2);

nframe=size(data,3);


%to store fields after interpolating up to full frame size
%scrapping first and last line
newdata=repmat(uint8(0),[nrow-2 ncol nframe*2]);

%set up vectors for interp1
xv=1:ncol;
yv=1:nrow;
yv1=1:2:nrow;
yv2=2:2:nrow;

ipi=1;
for ii=1:nframe
%    disp(ii);
    x1=data(yv1,:,ii);
    x2=data(yv2,:,ii);
    x1=double(x1);
    x2=double(x2);
    
%image processing deactivated, although it may be more efficient here
%before the interpolation, than doing it on the full resolution after
%deinterlacing
	%    x1=adapthisteq(x1,'NumTiles',[4 8]);
    %    x2=adapthisteq(x2,'NumTiles',[4 8]);
    
    %    x1=wiener2(x1,[3 5]);
    %    x2=wiener2(x2,[3 5]);

	%note: imresize does not work appropriately, i.e in effect introduces
    %noise in the time domain
    
    x1=interp1(yv1,x1,yv,'linear');
    x2=interp1(yv2,x2,yv,'linear');
    
    %maybe input argument to suppress flipping
    if doflip
        x1=flipud(x1);
        x2=flipud(x2);
    end;
    
    
    %change order of first and second field if necessary
    newdata(:,:,ipi+poff(1))=uint8(round(x1(2:end-1,:)));
    newdata(:,:,ipi+poff(2))=uint8(round(x2(2:end-1,:)));
    
    ipi=ipi+2;
end;

