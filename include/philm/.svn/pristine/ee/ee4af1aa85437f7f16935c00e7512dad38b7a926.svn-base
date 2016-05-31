function mt_cmark(iwant,mvec);
% mt_cmark Clear markers
% function mt_cmark(iwant,mvec);
% mt_cmark: Version 16.10.98
%
% Syntax
%   iwant: 'start','end','kill'
%   mvec: List of markers, defaults to current marker.
%         'start' and 'end' reset the corresponding marker time to NaN.
%                 If 'start' is rest and a label
%                 is present this is retained, but displayed at t=0,
%                 so it may not be visible
%         'kill' resets both start and end marker, and clears the label.
%
% See also
%   mm_imark: initialize markers; mm_smark: Set markers; mm_cmark: clear markers; mm_lmark: log markers to disk; mm_gmark: get markers
%
% Graphics
%   1. Cursor axis of the main figure
%   line 'markerstart'
%        userdata markertype (1..nmark)
%   line 'markerend'
%        userdata markertype (1..nmark)
%        linetype '--'
%   text 'markerlabel'
%        position(1) follows xdata of markerstart
%   2. Current cut axis of the organization figure
%   text 'marker_org'
%        position [0 currentmarker]
%        string filename of output cut file
%        userdata [nmarker currentmarker]

orgdat=mt_gmarx;
if isempty(orgdat) return; end;
maxmark=orgdat.n_markers;
curmark=orgdat.current_marker;



    if nargin<2 mvec=curmark; end;

    %check marker list in range
    if any(mvec<1)|any(mvec>maxmark)
       disp('mt_cmark: markers out of range');
       return
    end;


if strcmp(iwant,'start')
   mt_smark(iwant,mvec,NaN);
end;
if strcmp(iwant,'end')
   mt_smark(iwant,mvec,NaN);
end;
if strcmp(iwant,'kill')
   mt_smark('label',mvec,'');
   mt_smark('start',mvec,NaN);
   mt_smark('end',mvec,NaN);
end;


