function emmadat=getemmaa(emmafile,ncol,indatatype,databytes);
% GETEMMAA Load multiplexed Carstens emma data
% function emmadat=getemmaa(emmafile,ncol,indatatype,databytes);
% getemmaa: Version 4.7.97
%
%   Description
%       Will actually work for any raw multiplexed data
%       databytes is size of each value in bytes. Defaults to 2
%       should be derived automatically from indatatype

    if nargin<4 databytes=2;end;


	architecture='l';	%data acquired on pc

	fid=fopen(emmafile,'r',architecture);
        if fid<3
           disp (['File open failed' emmafile]);
           emmadat=[];
        end;
	iocode=showferr(fid,'getemmaa: File open');

        status=fseek(fid,0,'eof');
        if status~=0
	   iocode=showferr(fid,'getemmaa: Fseek');
        end;
        filelength=ftell(fid);
        status=fseek(fid,0,'bof');
        if status~=0
	   iocode=showferr(fid,'getemmaa: Fseek');
        end;
        nexpect=floor(filelength./databytes);

	scratch=fread(fid,nexpect,indatatype);
	%error message
	iocode=showferr(fid,'getemmaa: Fread');

	ndat=size (scratch,1);
        if rem(ndat,ncol) ~=0
           disp ('getemmaa: Records incomplete?');
        end;
        nrow=ndat./ncol;
        disp (['getemmaa: Records read: ' num2str(nrow)]);
        emmadat=reshape(scratch,ncol,nrow);
        emmadat=emmadat';
        status=fclose(fid);
