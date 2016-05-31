function p=wave_assembleStartRecordingPacket(startStop)
% ASSEMBLESTARTRECORDINGPACKET --- generate the command that starts/stops
% the NDI wave system via TCP/IP
% 
% Description: 
%
% Assemble the start recording packet. 
% NOTE: The header is NOT part of the output of
% assembleStartRecordingPacket, it is created in WAVE_NEGPACKAGE!
% 
%
% Syntax: 
%       startStop: 1=start, 0=stop
%       p: See WAVE_NEGPACKAGE for package format
%       
%
% See also WAVE_NEGPACKAGE, WAVE_CONNECT
% TODO: Documentation of NDI package architecture!
%
%  $Date: 2011/10/04 17:50:44 $ CG 
%


StartStopUse=1; % by default start aquisition
if nargin
    StartStopUse=startStop;
end

p.type=3;
% header information ()
%m_size=typecast(swapbytes(uint32(60)),'int8');
m_type=typecast(swapbytes(uint32(p.type)),'int8');

ncomp=typecast((uint32(1)),'int8');
compsize=typecast((uint32(48)),'int8');
comptype=typecast((uint32(5)),'int8');


%frameNo=uint8([255 255 255 255]);
frameNo=int8([-1 -1 -1 -1]);

%typecast(ausgangsmat,'uint32')
% das hier gibt in der Tat die -1:
%tmp=(typecast(tmp,'int32'))
%frameNo=(typecast(tmp,'int8'))

% char(frameNo)
% das stimmt wohl nicht: 
% frameNo=typecast((uint32(-1)),'uint8'); % =0 0 0 0
% fuer einen einzigen bekommet man die -1 raus:
% typecast(swapbytes(uint8(255)),'int8')
% Warum signed in MSC++??

% -1 y** 0xff

timeStamp=typecast((uint64(0)),'int8'); % =0 0 0 0 0 0 0 0 

%pack=[m_size m_type ncomp compsize comptype frameNo timeStamp];
pack=[ncomp compsize comptype frameNo timeStamp];

% Anordnung koennte falsch sein!
m_nevent=typecast((uint32(1)),'int8');

m_eventID=typecast((uint32(StartStopUse)),'int8'); % 1 for start, 0 for Stop

m_timeStamp=typecast((uint64(0)),'int8');

%tmp=hex2dec('FFFFFFFF');
%tmp=typecast(uint32(swapbytes(tmp)),'uint8'); 

%  default values (empty)
tmp=int8(repmat(-52,1,4));
 
C3DPack=[m_nevent m_eventID m_timeStamp tmp tmp tmp];
p.data=[pack C3DPack];

disp(['size of data (excluding header):' num2str(length(p.data))]);


%p.data'