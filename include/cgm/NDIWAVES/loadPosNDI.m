function data =  loadPosNDI(PosFileNameNDI,myformat,skipB)
%insheet='c:/ndigital/collections/MySession_12/MySession_12_002_sync.tsv'
fid=fopen(PosFileNameNDI);
if fid == -1,
    disp([msg ' Filename: ' PosFileName]);
    return;
end

[RawData, DSize] = fread(fid, 1, 'ulong');	% read raw data

%ncol=39;
ncol=38;
%DSize

dat=length(RawData);


%for rr=1:40
%   disp([num2str(rr)   '     ' num2str(length(RawData)/rr)])
   %[rr data-round(data)]
%end


%round(length(RawData)/39)


fclose(fid);%

data=RawData