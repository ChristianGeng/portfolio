function aa(achan);
% AA Set audio channel
% function aa(achan);
%   If no input arg set to audio

mychan='AUDIO';
if nargin mychan=achan; end;
mt_scsid('audio_channel',mychan);
