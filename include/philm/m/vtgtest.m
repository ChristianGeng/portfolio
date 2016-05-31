function vtgtest
% VTGTEST Test delay value is set appropriately in VTGCTRL
% function vtgtest
% vtgtest: Version 31.10.07
%
%   See Also VTGCTRL
%
%   Notes
%       could also be used from keyboard mode for testing other vtg55
%       functions

daqok=1;
try
parport = digitalio('parallel','LPT1');
catch
    daqok=0;
    
    %eventually it should be possible to continue without parallel port
    %functions
    
    disp('Parallel port not available');
    disp('Check you have administrator privileges');
    return;
end;





vtgctrl('ini',parport);

tic;
vtgctrl('trial',99);
mytoc=toc;
disp(['Time for incrementing hours to 99']);
disp(mytoc);

keyboard;

delete(parport);
clear parport;

daqreset;
