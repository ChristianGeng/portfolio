function mymark=mt_gmark(iwant,mvec);
% mt_gmark Get markers
% function mymark=mt_gmark(iwant,mvec);
% mt_gmark: Version 16.10.98
%
% Syntax
%   Input:
%   iwant: 'start','end','cut','label','type','status','source_cut'
%   mvec: List of markers. If absent or empty defaults to current marker.
%   Output:
%   mymark: Empty if markers not initialized. NaN if initialized but not set
%
% See also
%   mm_imark: initialize markers; mm_smark: Set markers; mm_cmark: clear markers; mm_lmark: log markers to disk; mm_gmark: get markers
%	 mt_gmarx: Returns any complete field from userdata
%			note: for 'label', mt_gmarx returns cell array, mt_gmark returns string matrix
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

mymark=[];
orgdat=mt_gmarx;
if isempty(orgdat) return; end;
maxmark=orgdat.n_markers;
curmark=orgdat.current_marker;





if nargin<2 mvec=curmark; end;
if isempty(mvec) mvec=curmark; end;

%check marker list in range
if any(mvec<1)|any(mvec>maxmark)
   disp('mt_smark: markers out of range');
   return
end;

if strcmp(iwant,'status')
   mymark=orgdat.status(mvec);
   return;
end;

if strcmp(iwant,'source_cut')
   mymark=orgdat.source_cut(mvec);
   return;
end;

if strcmp(iwant,'start')
   mymark=orgdat.start(mvec);
   return;
end;

if strcmp(iwant,'end')
   mymark=orgdat.end(mvec);
return;
end;

if strcmp(iwant,'cut')
   mymark=[orgdat.start(mvec) orgdat.end(mvec)];
   return;
end;

if strcmp(iwant,'label')
   mymark=char(orgdat.label(mvec));	%convert from cell array to string matrix
   return;
end;

%normally use to return current marker, otherwise simply return input vector
%could also now use mt_gmarx('current_marker')

if strcmp(iwant,'type')
   mymark=mvec;
   return;
end;

