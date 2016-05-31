function [E,BB,chanchk,nblist,byteslist,offsetlist,buffernumlist,firstlastblist]=getxmxeventhead(fid,myoffset,chanspec,filelenbyte);
% GETXMXEVENTHEAD Get event header of Sony EX xmx file
% function [E,BB,chanchk,nblist,byteslist,offsetlist,buffernumlist,firstlastblist]=getxmxeventhead(fid,myoffset,chanspec,filelenbyte);
% getxmxeventhead: Version 06.08.08
%
%   Description
%       Reads the event header (returned in E), as well as all data headers
%       in the event (returned in BB), as well as parsing this information
%       for further use
%       (Trigger information is to be found in the data header structures,
%       returned in BB)
%
%   Syntax
%       Input:
%       fid: file handle
%       myoffset: Position in the file from which to start reading the event header
%       chanspec: List of channel id's of the channels present in the xmx
%       file (must be in the same format as for output argument chanchk
%       (see below)
%       filelenbyte: Length of xmx file in bytes (used to check that each
%       data chunk is complete)

%       Output:
%       E: The event header (structure)
%       BB: Cell array of data header structures (each element in the array
%       is the data header for one buffer of one channel)
%           Some elements of BB may be empty if the total number of data
%           blocks in the file is less than number of channels * total
%           buffers (as given in the event header); this seems to happen
%           occasionally.
%       chanchk: Channel id for the channel of each element of BB
%            calculated from the data header as: B.mgnum*100 + B.imnum*10 + B.channum;
%       The size of the remaining output arguments is determined by the
%       number of channels. These variables consist of information taken
%       from the individual data headers in BB and rearranged and grouped
%       for each channel.
%       nblist: vector (size 1*nchan). Number of buffers for each channel
%       byteslist: vector (size 1*nchan). Number of bytes in each data
%       block of each channel
%       offsetlist: cell array (size nchan*1). Each element contains the byte offsets to
%       the start of each data block of one channel
%       buffernumlist: cell array (size nchan*1). Each element contains the
%       buffer numbers of the corresponding entry in offsetlist
%       firstlastblist: Matrix (size 2*nchan). First row contains first
%       data block, 2nd row contains last data block of each channel
%           This is firstly for information: It gives a quick way of seeing
%           if not all channels cover exactly the same time.
%           Secondly, the calling program should use it to determine the
%           overall time-span of the data in the file
%
%   See also GETXMXDATAHEAD

id=[99 1 1 99];
E=[];
nchan=length(chanspec);
%position file
status=fseek(fid,myoffset,'bof');

[tmp,count]=fread(fid,4,'int32');

tmpid=tmp';
if all(tmpid==id)
    E.eventheadid=tmpid;

    [tmp,count]=fread(fid,2,'int64');

    E.offsetnexteventhead=tmp(1);
    E.offsetdata=tmp(2);

    [tmp,count]=fread(fid,8,'int32');

    E.eventnum=tmp(1);
    E.numprehistbuffers=tmp(2);
    E.buffernumlastprehist=tmp(3);
    E.buffernumdatastart=tmp(4);
    E.totalbuffers=tmp(5);

    %next 3 longs are spare

    %This is probably the normal number of blocks actually present, i.e every
    %buffer present for every channel, but there seem to be some situations
    %where some channels may be missing the last buffer

    totalblocks=E.totalbuffers*nchan;

    BB=cell(totalblocks,1);
    boff=ones(totalblocks,1)*NaN;
    chanchk=boff;
    databytesb=boff;
    buffernumberb=boff;

    for ib=1:totalblocks
        currentoffset=ftell(fid);
        %    disp([ib currentoffset]);
        B=getxmxdatahead(fid);
        BB{ib}=B;

        if ~isempty(B)
            currentoffset=ftell(fid);


            nbyte=B.databytes;
            if currentoffset+nbyte <= filelenbyte

                %check divisible by 4, and that data actually is single????

                boff(ib)=ftell(fid);            %same as currentoffset????
                databytesb(ib)=nbyte;
                buffernumberb(ib)=B.buffernumber;
                chanchk(ib)=B.mgnum*100 + B.imnum*10 + B.channum;



                fseek(fid,nbyte,'cof');
                %            nsingles=nbyte/4;
                %    dd=fread(fid,nsingles,'*single');
            else
                disp('xmx: not enough data in file for current data block');
            end;
        else
            disp(['GETXMXEVENTHEAD: Empty data header at block ' int2str(ib) ' of ' int2str(totalblocks) '. File offset ' int2str(currentoffset)]);

        end;
    end;

    %do summary for each channel

    offsetlist=cell(nchan,1);
    buffernumlist=cell(nchan,1);

    %If it turns out that for a given channel the number of bytes per block is
    %not necessarily equal than use the following line
    %byteslist=cell(nchan,1);

    byteslist=ones(1,nchan);
    nblist=ones(1,nchan);
    totalblist=ones(1,nchan);
    firstlastblist=ones(2,nchan);
    %should be worked out beforehand
    %chanlist=unique(chanchk);

    for ichan=1:nchan
        mychanid=chanspec(ichan);
        vp=find(chanchk==mychanid);

        nblist(ichan)=length(vp);
        totalblist(ichan)=sum(databytesb(vp));
        btmp=buffernumberb(vp);
        bofftmp=boff(vp);
        dbtmp=databytesb(vp);
        %probably only necessary for triggered data
        [btmp,sorti]=sort(btmp);

        firstlastblist(:,ichan)=[btmp(1);btmp(end)];
        offsetlist{ichan}=bofftmp(sorti);
        buffernumlist{ichan}=btmp;

        if any(dbtmp~=dbtmp(1))
            disp(['Unequal block lengths for ' int2str(mychanid)]);
            disp('If this is not an error, rewrite the program');
            return;
        end;

        byteslist(ichan)=dbtmp(1);

        %if the more complicated case is necessary
        %    dbtmp=dbtmp(sorti);
        %    byteslist{ichan}=dbtmp;

    end;

    disp('GETXMXEVENTHEAD: Overview');
    disp('channel ids, n buffers, first blocks, last blocks, bytes per buffer, total bytes');
    disp(chanspec);
    disp(nblist);
    disp(firstlastblist);
    disp(byteslist);
    disp(totalblist);

else
    disp(['GETXMXEVENTHEAD: Bad ID? ' int2str(tmpid)]);
    disp('File will not be processed further');
    keyboard;
end;

%keyboard;
