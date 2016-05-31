function mat2tif(matfile,tifname,piclist,maxintensity,linelist,collist);
% MAT2TIF Export greyscale video (or MRI) mat files to series of TIFF images
% function mat2tif(matfile,tifname,piclist,maxintensity,linelist,collist);
% mat2tif: Version 21.02.02
%
%	Syntax
%		piclist: Optional. List of frame numbers to export.
%			If empty or absent export all frames
%		maxintensity: Normalize to this intensity value before export
%			Default to full intensity range in the images
%			Most useful for MRI where the maximum intensity value
%			may be much higher than the intensity range of interest
%			linelist and collist: vector of lines or columns to extract. Optional, default to complete image
%	Note: Assumes first line of image is at bottom

load(matfile);

tmplist=1:size(data,3);
if nargin>2
   if ~isempty(piclist)
      tmplist=piclist;
   end;
end;
piclist=tmplist;

tmplist=1:size(data,1);
if nargin>4
   if ~isempty(linelist)
      tmplist=linelist;
   end;
end;
linelist=tmplist;

tmplist=1:size(data,2);
if nargin>5
   if ~isempty(collist)
      tmplist=collist;
   end;
end;
collist=tmplist;


ndig=length(int2str(max(piclist)));

tmpmax=[];

if nargin>3
   tmpmax=maxintensity;
end;

if isempty(tmpmax)
   tmpmax=max(data(:));
   tmpmax=double(tmpmax);
   disp(['Maximum intensity : ' num2str(tmpmax)]);   
end;
maxintensity=tmpmax;




for ii=1:length(piclist)
   ipic=piclist(ii);
%   x=[data(:,:,ipic) data(:,:,ipic) data(:,:,ipic)];
	x=flipud(data(linelist,collist,ipic));
	x=double(x)/maxintensity;
   %what happens with values of x > 1
   imwrite(x,[tifname int2str0(ii,ndig) '.tif'],'TIF');
end;
