function [varargout] = rtstream_close (varargin)
%SEE ALSO RTSTREAM_CONNECT
% 
% See Also RTSTREAM_CLOSE, RTSTREAM_CONNECT CONNECTCS5RT CONNECTCS6RT GETEMADATA

if nargin > 1
    error('specified too many input arguments');
end


if nargout > 1
    error('Too many output arguments');
end
varargin{1}
mycon=varargin{1}

%pnet(mycon.con,'close')

if (isfield(mycon, 'con'))
    mycon.con
    try,
    pnet(mycon.con,'close')
    mycon=rmfield(mycon,'con')
    catch, warning(lasterr), end;
else, error(['connection ', varargin{1}.name, ' does not exist'])
end
%mycon.con=con
    
    varargout{1}=mycon;


