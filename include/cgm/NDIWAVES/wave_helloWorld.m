%% need to close old sessions?

s.close
clear s
clear variables

%
% establish connection and set byte order and version 1.0
[s] = wave_connect(2900)
%s.getSoTimeout


q.data='Version 1.0';
q.type=1;
p = wave_negPackage (s,q);
disp(char(p.data'))


% cString = 'SetByteOrder LittleEndian' 'false'
q.data='SetByteOrder LittleEndian';
q.type=1;
p = wave_negPackage (s,q);
disp(char(p.data'))


%


% data sizes in packets excluding header (add 8 to get full pack size)
% "streamframes allframes all"
% nsensors nschiffchen  ndata()
%   4           2       1x156
%

si = s.getInputStream;
so = s.getOutputStream;

cmd=fpcommand('StreamFrames AllFrames All');
so.write([abs(cmd) 10]); % nullterminated
so.flush;


%for idx2=1:3
%while 1


% read header
sSampsAq=1000;
datrec=zeros(sSampsAq,164);
minTime = Inf;



%% read packets

tic
% for nn=1:sSampsAq
    tStart = tic;
    for idx=1:4
        headerRaw(idx) = si.read;
    end
    
    packSize=swapbytes(typecast(uint8(headerRaw(1:4)),'uint32'));
    packSize=double(packSize);
    % disp(headerRaw)
    %disp(['packsize: ' num2str(packSize)]);
    
    niter=packSize-4;
    
    for idx=1:niter
        try,
            packRaw(idx) = si.read;
        catch,
            disp(idx),
        end
    end
    packet=[headerRaw'; packRaw'];
    %whos packet
    %dat(sSampsAq,:)=packet';
    % disp(packet')
    % tElapsed = toc(tStart);
    %t(nn) = toc;
    tElapsed = toc(tStart);
    minTime = min(tElapsed, minTime);
% end

averageTime = toc/sSampsAq;
1/averageTime;

disp(packet)

whos datrec;
%%

if(1==2)
    
    packet=[headerRaw'; packRaw'];
    header=packet(1:8);
    data=packet(9:end);
    hsize=swapbytes(typecast(uint8(header(1:4)),'uint32'));
    htype=header(8);
    disp(['header type ' num2str(htype), ' hsize ' num2str(hsize)])
    
    
    componentCount=typecast(uint8(data(1:4)),'uint32');
    componentSize=(typecast(uint8(data(5:8)),'uint32'));
    componentType=typecast(uint8(data(9:12)),'uint32')
    FrameNo=typecast(uint8(data(13:16)),'uint32');
    TimeStamp=typecast(uint8(data(17:24)),'uint64');
    
    % Start of 6D data frame component , e.g. ComponentData=data(25:end);
    ToolCount=typecast(uint8(data(25:28)),'uint32');  % is that Nsensors??
    whos data
    tmpData=typecast(uint8(data(29:end)),'single');
    pos=reshape(tmpData,length(tmpData)/ToolCount,ToolCount)';
    pos=[pos(:,5:7)  pos(:,1:4) pos(:,8)];
end


%out=wave_readpacket(packTot);
%whos out
% disp(out)
%pause(0.1)

%end

% out=readpacket([header; packet]);
%
%data=0;
%if packet(4)==3 %data packet
%    data=out.data3d; %can be data3d, data6d or analog
%end

%disp('data')
%disp(data)

%% Stop
cmd=fpcommand('StreamFrames Stop');
so.write([abs(cmd) 10]); % nullterminated
so.flush;



%%
% out.data3d is a vector with all the marker x y z data piled on top
% of each other [x1 y1 z1 r1 x2 y2 z2 r2 ...], see RTC3D protocol. similar
% for out.data6d and out.analog.







%% Starting Stopping
disp(char(p.data'))

qStart=wave_assembleStartRecordingPacket(1);
qStop=wave_assembleStartRecordingPacket(0);


p = wave_negPackage (s,qStart);
pause(1)
p = wave_negPackage (s,qStop);


%%


% SEND CURRENT  FRAME
p.data='SendCurrentFrame'
p.type=3;
pOut = wave_negPackage (s,p);
disp(char(pOut.data'))

% SEND PARAMTERS ALL
p.data='SendParameters All'
p.type=1;
pOut = wave_negPackage (s,p);
disp(char(pOut.data'))



%% Stop Streaming
strFramesStop.data='StreamFrames Stop'
strFramesStop.type=1;
strFramesStopOut = wave_negPackage (s,strFramesStop);
disp(char(strFramesStopOut.data'))



% start.data=
% start.type=3;


% str = 0x00b1ccc0 "StreamFrames AllFrames"


% m_cSendBuffer[0] 0x00
% m_cSendBuffer[1] 0x00
% m_cSendBuffer[2] 0x00
% m_cSendBuffer[3] 0x1f  -> 31
%
% m_cSendBuffer[4] 0x00
% m_cSendBuffer[5] 0x00
% m_cSendBuffer[6] 0x00
% m_cSendBuffer[7] 0x00
% dann StreamFrames AllFrames

% m_nttype=0x00000003