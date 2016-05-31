function [data,numinfo,strinfo,datatype]=getoptof(optofile);
% GETOPTOF Get data from Optotrak file
% function [data,numinfo,strinfo,datatype]=getoptof(optofile);
% getoptof: Version 1.10.2001
%
%	Description
%		Read optotrak 3D floating point files (also analog files)
%		Also reads unconverted (integer) data. Useful for analog files (e.g o1#....)
%		phil, originally written 10.96
%		this is the arrangement of the informational data:
%		numinfo=[nitems nsubitems nframes samplerate Fc];
%		strinfo=str2mat (user_comments,coll_time,coll_date);

dataoffset=256
%files originate on PC, lowendian
architecture='l';
	filename=optofile;
	fid=fopen(filename,'r',architecture);


	if fid < 3 error ('getoptof: Fopen failed'); end;

%read through the header

filetype=fread (fid,1,'uchar');
if (filetype ~= 32) disp ('Wrong file type?');end;

nitems=fread (fid,1,'ushort');
nsubitems=fread (fid,1,'ushort');
nframes=fread (fid,1,'ulong');
disp ('Number of items, subitems, frames');
disp ([nitems nsubitems nframes]);
samplerate=fread(fid,1,'float');
disp (['Samplerate ' num2str(samplerate)]);
format long;
disp (samplerate);
format short;
ts=fread (fid,60,'uchar');
s1=ts;
ts=setstr(ts');
ts=strtok(ts,0);
user_comments=ts;
disp ('User comments');
disp (user_comments);
%sys-comment
dummy=fread (fid,60,'uchar');
dummy=fread (fid,30,'uchar');

Fc=fread(fid,1,'ushort');

ts=fread (fid,10,'uchar');
s2=ts;
ts=setstr(ts');
ts=strtok(ts,0);
coll_time=ts;
disp ('Collection time');
disp (coll_time);




ts=fread (fid,10,'uchar');
s3=ts;
ts=setstr(ts');
ts=strtok(ts,0);
coll_date=ts;
disp ('Collection date');
disp (coll_date);



%various other stuff


%not used??
frame_start=fread (fid,1,'long');
extended_header=fread (fid,1,'ushort');
char_subitems=fread (fid,1,'ushort');
int_subitems=fread (fid,1,'ushort');
double_subitems=fread (fid,1,'ushort');

item_size=fread (fid,1,'ushort');
disp (['Item size ' int2str(item_size)]);
disp ('char_subitems int_subitems double_subitems');
disp ([char_subitems int_subitems double_subitems]);

datatype='float';
if nsubitems==0

	if char_subitems
		nsubitems=char_subitems;
		datatype='char';
	end;
	if int_subitems
		nsubitems=int_subitems;
		datatype='short';
	end;
	if double_subitems
		nsubitems=double_subitems;
		datatype='double';
	end;
end;


status=fseek (fid,dataoffset,'bof');
if (status~=0) disp ('Bad seek');end;
data=fread (fid,[nitems*nsubitems,nframes],datatype);
if size(data,1)*size(data,2)~=nitems*nsubitems*nframes disp ('read incomplete'); end;
%transpose, so time runs down the columns
data=data';

	status=fclose (fid);
	numinfo=[nitems nsubitems nframes samplerate Fc];
	strinfo=str2mat (user_comments,coll_time,coll_date);
















