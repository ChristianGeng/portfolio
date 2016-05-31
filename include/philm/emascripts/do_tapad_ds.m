% do_tapad_ds.m MATLAB-Script to perform position calculation.
%           revised by andi 2007 
%  
%
%           see  tapad_ph_rs

warning('off','MATLAB:dispatcher:InexactMatch'); % switch off warnigs concerning case-sensitive OS  
clear variables; use_startpos = false;

%--------------------------------------------------------------------
%         E D I T  T H I S  P A R T  B E F O R E  R U N N I N G
%--------------------------------------------------------------------
% Comment the next line, if this is the first run of do_tapad_ds
% and there are no start values available. For any other case uncomment it!
use_startpos = true;			

% Edit lists of channels
chanlist=[1:10];

% Edit list of trials, to compute startpositions, less trials are needed
if use_startpos
	triallist=1:229;
else
	triallist=10:30:229;
end
%--------------------------------------------------------------------

% Normally this part has not to be edited
basepath = pwd;
startpos_path = ''; 							% e.g. use '..' for upper dir
startpos_filename = fullfile(startpos_path, 'startpos_v1');

startpos_is_available = exist(startpos_filename, 'file');
if startpos_is_available
	if use_startpos	
		load(startpos_filename);
		if ~exist('startpos', 'var')	
			error([startpos_filename ' must contain a variable ''startpos''!']);
		end
	else
		warning('do_tapad_ds.m runs without using the available Startpositions!') 
	end
else
	if use_startpos	
		error(['No such file: ' startpos_filename]);
end
		
% Decide which data variant to be processed.
% Assume that if adjusted amps exist, they should be processed. 
if exist('ampsfiltdsadja', 'dir')
	amppath='ampsfiltdsadja';
	if ~use_startpos	
		warning('do_tapad_ds.m run on ''ampsfiltdsadja'' without using start positions!') 
	end	
else
	amppath='ampsfiltds';
end
%amppath='ampsfiltdsadja'; % uncomment to change automatic choice

outpath = fullfile(amppath, 'beststartl', 'rawpos');
mkdir(fullfile(outpath, 'posamps'));
tapad_options='-l';							% use Levenberg method

if use_startpos
	stats = tapad_ph_rs(basepath, fullfile(amppath, 'amps'), outpath,...
								triallist, chanlist, tapad_options, startpos);
else % without startpos
	stats = tapad_ph_rs(basepath, fullfile(amppath, 'amps'), outpath,...
								triallist, chanlist, tapad_options);
	disp(stats); stats2start; 
	if startpos_is_available
		warning('existing start positions are not automatically overwritten!');
	else
		save startpos_v1 startpos, stats, triallist, comment;
	end
end
