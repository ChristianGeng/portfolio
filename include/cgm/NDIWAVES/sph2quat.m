function sph2quat()

% from http://www.flipcode.com/documents/matrfaq.html#Q58
% Q58. How do I convert spherical rotation angles to a quaternion?
% ----------------------------------------------------------------
% 
%   A rotation axis itself may be defined using spherical coordinates
%   (latitude and longitude) and a rotation angle
% 
%   In this case, the quaternion can be calculated as follows:
% 
%     -----------------------
%     sin_a    = sin( angle / 2 )
%     cos_a    = cos( angle / 2 )
% 
%     sin_lat  = sin( latitude )
%     cos_lat  = cos( latitude )
% 
%     sin_long = sin( longitude )
%     cos_long = cos( longitude )
% 
%     qx       = sin_a * cos_lat * sin_long
%     qy       = sin_a * sin_lat
%     qz       = sin_a * sin_lat * cos_long
%     qw       = cos_a
%     -----------------------
% 
% 
% The radial distance is also called the 
% - radius or 
% - radial coordinate, and 
% 
% The inclination may be called 
% - colatitude, 
% - zenith angle
% - normal angle
% - or polar angle.
% 
% elevation can be called 
% - latitude
% 
% azimuth 
% - longitude


% sin_a    = sin( angle / 2 )
% cos_a    = cos( angle / 2 )