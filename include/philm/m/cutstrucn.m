function [descriptor,unit,valuelabel]=cutstrucn(fullflag)
% CUTSTRUCN Initialize some basic cutfile variables
% function [descriptor,unit,valuelabel]=cutstrucn(fullflag)
% cutstrucn: Version 13.3.2009
%
%	Description
%		fullflag: Optional. If present and true, return descriptor and unit
%			with extended variable set, otherwise just these basic four:
%				descriptor=str2mat('cut_start','cut_end','cut_type','trial_number');
%			extended:
%				descriptor=str2mat(descriptor,'link_type','link_target','link_targetn','link_id','creation_data','modification_date');
%		The link* variables are designed for setting up hierarchical links
%			among segment tiers (with cut_type defining the tier).
%			A lower-level segment can be linked to a higher level segment by
%			setting its link_type and link_target to the cut_type and link_id,
%			respectively, of the higher-level segment.
%			link_targetn is designed for the cases where a lower-level segment
%			needs to be linked to two or more higher-level segments. It is
%			assumed that the latter must be sequential: link_targetn then gives
%			the link_id of the last element in the sequence.
%			(an earlier version of this scheme is used in PARSEMAUS, which may
%			be upgraded one day)
%		creation/modification date are intended to hold matlab serial date
%			numbers (as returned e.g by NOW)
%		valuelabel: returned with field cut_type (value=0, label='trial')
%
%	Updates
%		3.09 Introduction of extended variable set

descriptor=str2mat('cut_start','cut_end','cut_type','trial_number');
unit=str2mat('s','s',' ',' ');

if nargin
	if fullflag
		descriptor=str2mat(descriptor,'link_type','link_target','link_targetn','link_id','creation_date','modification_date');
		unit=str2mat(unit,' ',' ',' ',' ','datenum','datenum');
	end;
end;

valuelabel.cut_type.value=0;
valuelabel.cut_type.label='trial';

