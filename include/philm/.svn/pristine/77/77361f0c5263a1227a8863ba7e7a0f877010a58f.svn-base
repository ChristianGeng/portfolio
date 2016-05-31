function cut2tag(cutname,matname)
% CUT2TAG Convert CUT file to MAT file
% function cut2tag(cutname,matname)
% cut2tag: Version 1.5.97
%
% Remarks
%   n.b fp. sample rate  not yet implemented


%using dummy tag structure to handle CUT files
%

%currently only data element altered on line is length of data tag
%so this could all be stored as predefined data structures

%use dummy tag "private" to access sample rate power
%use dummy tag "dummy" to access number of entries
%data length is actually unknown until this is read
[stcfid,stccifdo,stcnt,stccdo,stcio,stiffcomlength]=stcomdef;
[stdtc,stdfc,stddl,stddo,stdnc,stdsb,stdtv,stdlength]=stdatdef;
[abint,abnoint,abscalar,abnoscalar]=abartdef;

stiffgo;
tagnamelist=str2mat('data','n_columns','samplerate','labels','dummy','private');


ntag=size(tagnamelist,1);
ifdrec=zeros(ntag,stdlength);
%replace numeric indices with names!!!!
for loop=1:ntag
    ts=tagnamelist(loop,:);
    [tagcode,forcode]=stifftnd(ts);
    ifdrec(loop,1)=tagcode;
    %default code only correct for ascii fields
    ifdrec(loop,2)=forcode;
    ifdrec(loop,5)=1;	%ncol
    ifdrec(loop,stdtv)=NaN;
end;


%treat main body of cut data as uchar to get transcription
%and as ushort to get numeric info


[nn1,forcode,nn2,nn3]=stiffdtd('uchar');

%
ii=getstrin ('labels',tagnamelist);
ifdrec(ii,2)=forcode;
ifdrec(ii,3)=16;        %data length not yet known
ifdrec(ii,4)=16;
%



%cut data is basically ushort
[nn1,forcode,nn2,nn3]=stiffdtd('ushort');
%fill in data type, data length and offset individually
%
ii=getstrin ('data',tagnamelist);
ifdrec(ii,2)=forcode;
ifdrec(ii,3)=8;         %data length not yet known
ifdrec(ii,4)=16;
%
ii=getstrin ('samplerate',tagnamelist);
ifdrec(ii,2)=forcode;
ifdrec(ii,3)=1;
ifdrec(ii,4)=(5*2)-2;
%use this as dummy tag to access samplerate power
%
ii=getstrin ('private',tagnamelist);
ifdrec(ii,2)=forcode;
ifdrec(ii,3)=1;
ifdrec(ii,4)=(6*2)-2;
%
%use this as dummy tag to access n_entries
%
ii=getstrin ('dummy',tagnamelist);
ifdrec(ii,2)=forcode;
ifdrec(ii,3)=1;
ifdrec(ii,4)=(3*2)-2;
%
%
ii=getstrin ('n_columns',tagnamelist);
ifdrec(ii,2)=forcode;
ifdrec(ii,3)=1;
ifdrec(ii,4)=(4*2)-2;
%
%after getting this set datalength (ifdrec(:,3) to 8*nentries
%or 16*nentries


%================================================
%implementation
%
fid=fopen (cutname,'r');
%errors?
taglist=tagnamelist;
stiffcx=zeros(1,stiffcomlength);
stiffcx(stcfid)=fid;
stiffcx(stcnt)=size(ifdrec,1);  %ntags
[stiffcx,sfcut]=strtbn(stiffcx,'samplerate',taglist,ifdrec,1);
[stiffcx,sfpower]=strtbn(stiffcx,'private',taglist,ifdrec,1);
sfcut=sfcut*sfpower;
[stiffcx,nentry]=strtbn(stiffcx,'dummy',taglist,ifdrec,1);
%must be 8
[stiffcx,ncol]=strtbn(stiffcx,'n_columns',taglist,ifdrec,1);


if nentry>0
    
    
    %update labels and data tag
    ii=getstrin ('data',tagnamelist);
    ifdrec(ii,3)=nentry*ncol;
    %
    ii=getstrin ('labels',tagnamelist);
    ifdrec(ii,3)=nentry*ncol*2;
    
    %for data
    [stiffcx,datain]=strtbn(stiffcx,'data',taglist,ifdrec,1);
    %get into proper size matrix
    datain=stfixda(datain,ncol);
    cutdata=zeros(nentry,3);
    cutdata(:,1)=((datain(:,1)*256)+datain(:,2))./sfcut;
    cutdata(:,2)=((datain(:,3)*256)+datain(:,4))./sfcut;
    cutdata(:,3)=datain(:,5);
    %for label
    [stiffcx,datain]=strtbn(stiffcx,'labels',taglist,ifdrec,1);
    %get into proper size matrix
    datain=stfixda(datain,ncol*2);
    
    cutlabel=zeros(nentry,6);
    cutlabel=datain(:,11:16);
    cutlabel=setstr(cutlabel);
    disp (cutdata)
    disp (cutlabel)
    %keyboard
    %use eval
    eval (['save ' matname ' cutdata cutlabel']);
    
    
else
    disp ('Cut file is empty!! No MAT file created')
end;
%close input CUT file


status=fclose(fid);


