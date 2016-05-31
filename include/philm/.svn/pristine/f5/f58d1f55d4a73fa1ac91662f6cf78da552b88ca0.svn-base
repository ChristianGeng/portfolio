function H=sonix_readheader(fid,helpwinflag)
% SONIX_READHEADER Read header of Sonix bpr, b8 or rf file
% function H=sonix_readheader(fid,helpwinflag)
% sonix_readheader: Version 08.02.2013
%
%   Syntax
%       If fid is numeric read file with this fid.
%       Assume positioned at start of file when called.
%       Leave positioned at end of header (start of data) on return.
%       If fid is string, try and open file with this name, read header and
%       close.
%       helpwinflag: If present and true, display header in help window
%           (default=false)
%
%   Notes:
%       Slightly different field names for b8 data.
%       Not all fields necessarily defined for all data types.
%       Also returns 2 fields calculated from header settings:
%           calculated_depth_mm, and calculated_sectorpercent
%           (n.a. for scan-converted files (.b8))
H=[];
showwin=0;
if nargin>1 showwin=helpwinflag;end;

speedofsound=1540*1000; %(mm/s)
sonheadlen=19; %header length
%ultrasonix file types (bpr is 2)
type_bre=2;
type_bpost=4;
type_bpost32=8;
%rf???

fidcall=1;
if ischar(fid)
    myname=fid;
    fidcall=0;
    fid=fopen(myname,'r');
    if fid==-1
        disp('sonix_readheader: unable to open file');
        return;
    end;
end;



    
    sonhead=fread(fid,sonheadlen,'int32');
if ~fidcall
    fclose(fid);
end;

if length(sonhead)~=sonheadlen
    disp('sonix_readheader: read incomplete?');
    disp(['No. of values returned: ' int2str(length(sonhead))]);
    return;
end;

P.datatype=sonhead(1);

P.nframes=sonhead(2);

%any other differences??
%maybe better to use same field names
if P.datatype==type_bpost
P.imagew=sonhead(3);
P.imageh=sonhead(4);
else
P.nvec=sonhead(3);      %no. of scan lines
P.nsamp=sonhead(4);     %no. of samples per scan line
end;

P.samplesize_bits=sonhead(5);

P.roi=sonhead(6:13);

P.probe_id=sonhead(14);

P.txf=sonhead(15);
P.sf=sonhead(16);       %US internal samplerate, after envelope detetection. This determines pixel resolution

P.framerate=sonhead(17);    %not necessarily completely accurate

P.linedensity=sonhead(18);
P.extra=sonhead(19);

H=P;
%is it zero for scan converted?
if P.sf~=0
    H.calculated_depth_mm=(P.nsamp*speedofsound)/(2*P.sf);
end;

if P.datatype~=type_bpost
    H.calculated_sectorpercent=(P.nvec/P.linedensity)*100;
end;

if showwin
    ss=evalc('disp(H)');
    mytit='sonix header ';
    if ~fidcall mytit=[mytit myname]; end;
    helpwin(ss,mytit);
end;
