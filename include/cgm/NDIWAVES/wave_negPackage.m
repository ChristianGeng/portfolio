function [p] = wave_negPackage (s,q,averbose)
% WAVE_NEGPACKAGE - negotiate NDI wave packages with the NDI RT server. 
% 
% Description:
%   send packages to NDI RT server and read back response (if present)
%   This entails 
%       a) sending packets
%       b) read back the reply (if any)
%
% Syntax:
%       Socket s  - see wave_connect
%       package q - Data package
%       package p - 
% Packages p and q are assumed to be structs with at least the following 2 fields:
%  a) p.data: The stram to be sent or received
%  b) p.type: The data type (see NDI docs for more background). 
%  NOTE: the package header (8 bytes) cotaining size (4B) and type (4B) is
%  prepended in this function!
%
% Examples:
%
% 
% q.data='Version 1.0';
% q.type=1;
% p = wave_negPackage (s,q);
% disp(char(p.data'))
% 
% % cString = 'SetByteOrder LittleEndian' 'false'
% q.data='SetByteOrder LittleEndian';
% q.type=1;
% p = wave_negPackage (s,q);
%
% q.data='SendParameters All';
% q.type=1;
% p = wave_negPackage (s,q);
% char(p.data')
% 
% q.data='SendCurrentFrame 3D';
% q.type=1;
% p = wave_negPackage (s,q);
% char(p.data')
% 
% q.data='StreamFrames AllFrames';
% q.type=1;
% p = wave_negPackage (s,q);
% char(p.data')
% 
% TODO: Maybe object oriented tools come in handy
%
% SEE ALSO: WAVE_CONNECT, ASSEMBLESTARTRECORDINGPACKET
%
%  $Date: 2011/10/04 18:22:12 $ CG 

% p should be a struct containing the fields
% Assumption: Endiannes set correctly

verbose=0;
if nargin>2
    verbose=averbose;
end


szData=length(q.data);
% headersize immer 8
RawPacketHeadersize = 8;
totPacketlength=szData+RawPacketHeadersize+1;
header.m_size=typecast(swapbytes(uint32(totPacketlength)),'uint8');
header.m_type=typecast(swapbytes(uint32(q.type)),'uint8');

%copy all packet into send buffer
%		memcpy( pBuffer, &header, sizeof(header) );
%
%
% m_pData  ist ein char ptr: char *m_pData;
%		memcpy( pBuffer + sizeof(header), m_pData, m_nSize - sizeof(header) );


if ~strcmp(get(s,'connected'),'on')    
    error('Socket not connected!');
end
    so = s.getOutputStream;
    so.write(header.m_size);
    so.write(header.m_type);
    
    so.write([abs(q.data) 10]); % nullterminated
    %so.write([abs(q.data)]); % unterminated
    
    if verbose
        disp(['negotiating package: size of data (excluding header):' num2str(length(q.data))]);
    end
so.flush;




%s.getSoTimeout

if (q.type==3); 
    p.size=0;
    p.type=0;
    p.data=0;
        return;
end



si = s.getInputStream;

p.size(1) = si.read;
p.size(2) = si.read;
p.size(3) = si.read;
p.size(4) = si.read;

p.size=swapbytes(typecast(uint8(p.size),'uint32'));

p.type(1) = si.read;
p.type(2) = si.read;
p.type(3) = si.read;
p.type(4) = si.read;
p.type=swapbytes(typecast(uint8(p.type),'uint32'));

p.data=zeros(p.size-RawPacketHeadersize,1);

for iter= 1: p.size-RawPacketHeadersize
    p.data(iter)=si.read;
end
%p.data
% p.data = char( p.data);
 