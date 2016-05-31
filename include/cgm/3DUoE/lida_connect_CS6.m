function [s,varargout] = lida_connect_CS6 (varargin)
% LIDA_CONNECT_CS5 --- open a socket to lida host on CS6
% 
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
%	Output of this on the terminal is suppressed if a second input argument
%	is present
%
% Assumptions:
%    ssh tunneling open for port 30303 or port open
%    Cs5recorder running
%
% lbo 19Aug08, phil 12.08 (second input argument)
% Version with a static IP addresss configuration 18 May 2009 CG
% 

if nargout > 3
    error('Too many output arguments');
end

if nargin > 2
    error('Too many input arguments');
end

import java.io.*;
import java.net.*


deflida.host='129.215.204.7';
deflida.port=30303;
% matname='lida_cfg.mat';

%if exist(matname,'file')
%    lida=mymatin(matname, 'lida', deflida);
%else
    lida=deflida;
%end

s=Socket(lida.host, lida.port);
if nargin == 1
    s.setSoTimeout(varargin{1});
end


if nargout >= 2
    varargout{1} = s.getInputStream;
end

if nargout == 3
    varargout{2} = s.getOutputStream;
end

greet=lida_greetings(s);
if nargin<2 
	disp(greet(1:(end-1))); 
end;

