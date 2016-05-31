function [s] = wave_connect (timeoutin)
% WAVE_CONNECT --- establish socket connection to NDI RT Server 
% 
% Description: 
%   WAVE_CONNECT mimics the behavior of "Client::bConnect" which is part
%   of C3FRAME. (see test-serverclient.sln shipped by NDI). 
%   
%   a) open connection
%   b) set socket to blocking for the moment 
%       nSetSocketBlocking( m_socket, true );
%   c) turn off Nagle algorithm
%			nSetNagle( m_socket, false );
% The Connection Function in RTC3DClient, Client::bConnect(DWORD dwAddress, int nPort)
% in addition sets byteorder to "default". We do not have do this here!
% m_bNetworkByteOrder = true;
%
% Syntax: 
%       timeout (optional)
%       s: Handle to socket connection
%
% See also WAVE_NEGPACKAGE, assembleStartRecordingPacket
%
%  $Date: 2011/10/04 17:35:51 $ CG 
%


import java.io.*;
import java.net.*;
import java.lang.String;
import java.io.InputStream;

timeout=2000;	%possibly higher value sometimes useful to prevent apparent lost connection?
if nargin
    timeout=timeoutin; 
end;

clear s;

% hardwired:
ip='141.89.97.193';
port=3030;

% a) Open Connection
s=Socket(ip,port);

% b) auf Blocking setzen
s.setSoTimeout(timeout);

% c)  Nagling off
% This means that there are no TCP buffer flushing delays
s.setTcpNoDelay(false);
%Die Option tcpnodelay gibt an, ob kleine Transaktionen an den Server gesendet werden, 
%ohne sie vorher in einen Buffer zu stellen. Eine "kleine Transaktion" ist kleiner als der 
%in der Option txnbytelimit definierte Bytegrenzwert. Die Angabe tcpnodelay yes kann die 
%Leistung in Netzen mit hoher Übertragungsgeschwindigkeit verbessern.

