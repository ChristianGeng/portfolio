function B=getxmxdatahead(fid);
% GETXMXDATAHEAD Read xmx data header from current file position
% function B=getxmxdatahead(fid);
% getxmxdatahead: Version 06.08.08
%
%   Description
%       Designed to return data header to getxmxeventhead
%       Prints a message if any trigger information found, but actually
%       processing of the trigger information has to be done by the calling
%       program from the appropriate fields in B
%       Structure B is returned empty if the read is incomplete (which can
%       happen harmlessly, given the way getxmxeventhead is set up at the
%       moment)
%
%   See Also
%       GETXMXEVENTHEAD

id=[99 11 11 99];

nhead=16;
B=[];
[tmp,count]=fread(fid,nhead,'int32');

if count==nhead
    tmpid=tmp(1:4)';
    if all(tmpid==id)
        B.dataheadid=tmpid;
        B.mgnum=tmp(5);
        B.imnum=tmp(6);
        B.channum=tmp(7);
        B.databytes=tmp(8);
        B.buffernumber=tmp(9);
        B.triggerrelposdatastart=tmp(10);
        B.triggerrelposrecend=tmp(11);
        B.triggerposinbuffer=tmp(12);


        %last 4 longs are spare


        %trigger-related values
        %abs(relposdatastart)+posinbuffer = duration of pretrigger
        %relposdatastart thus gives start of pre-trigger data relative to start of
        %current block (negative values indicate loaction before start of current
        %block

        %abs(relposdatastart)+relposrecend = duration of trigger sequence

        %divide all trigger values by 2?????


        if B.triggerposinbuffer~=0
            disp('GETXMXDATAHEAD: Trigger information found');
            disp('buffer num, trig re datastart, trig re recend, trig posinbuf : ')
            disp([B.buffernumber B.triggerrelposdatastart B.triggerrelposrecend B.triggerposinbuffer]);
        end;

        %
        %This usually appears to be harmless:
        %getxmxeventhead tries to read E.totalbuffers * n_chan, however some
        %channels sometimes seem to have one fewer buffers than others
    else
        disp(['GETXMXDATAHEAD: Bad ID? ' int2str(tmpid)]);
    end;

else
    disp('GETXMXDATAHEAD: Read incomplete');
end;
