function [varargout] = rtstream_connect (varargin)
% RTSTREAM_CONNECT --- Connect to the realtime data stream between 
% a lida and a CS on port 30303
%

%%%%%%%%%%%%%
% s = lida_connect(timeout) returns Java Object of class Socket
% [s,si] = lida_connect(timeout) additionally returns the socket's Java
% InputStream
% [s,si,so] = lida_connect(timeout) additionally returns the socket's Java
% OutputStream
% The optional parameter timeout maybe used to specify a timout interval
% in milliseconds for subsequent reading operations of the socket.
%
% The welcome string "200 Welcome" will be read so that the InputStream
% will be empty thereafter
%
% Assumptions:
%    ssh tunneling open for port 30303 or port open
%    Cs5recorder running
%
% Per default, the IPS Munich settings are used for connection, i.e.
% IP=141.84.138.216 PORT=30303
% Alternatively, if a struct named "lida" with the fields "host" (IP / hostname
% of lida) and port (TCP/IP port to connect to) exists in a file
% "lida_cfg.mat", these values will be taken to override the default.



if nargin > 1
    error('specified too many input arguments');
end


if nargout > 1
    error('Too many output arguments');
end


if (nargin == 0)
  deflida.host='129.215.204.7';
  deflida.port=30303;
  matname='lida_cfg.mat';
  if exist(matname,'file')
    lida=mymatin(matname, 'lida', deflida);
  else
    lida=deflida;
  end
  lida.con=pnet('tcpconnect',lida.host,lida.port);
  pnet(lida.con,'setreadtimeout',10);
  hello=pnet(lida.con,'readline'); %Hell
  varargout{1}=lida;
elseif (nargin==1)
  mycon=varargin{1}
  mycon.con=pnet('tcpconnect',varargin{1}.host,varargin{1}.port);
  pnet(mycon.con,'setreadtimeout',10);  % set read time out to 10 sec. That solves it
  hello=pnet(mycon.con,'readline'); %Hell 
  varargout{1}=mycon;
end


% evalversion
% varargin{1}
% con=varargin{1}.name
% evalstring=[con,'=', 'pnet(''tcpconnect'',',varargin{1}.host,',', num2str(varargin{1}.port),')']
% %eval(evalstring)
% 
% evalstring=['pnet(',con,',','''setreadtimeout''',',10)']
% %eval(evalstring)
% 
% 
% %pnet(con,'setreadtimeout',10)
% 
% %evalstring=['hello=pnet(', con,'''readline''', );
% %varargout{1}=con;
% 
% %pnet(con,'close');
% 
% 
