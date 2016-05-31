function plotpegelstats(pegelstats,triallist,chanlist);
% PLOTPEGELSTATS Plot statistics of AG500 signal level
% function plotpegelstats(pegelstats,triallist,chanlist);
% PLOTPEGELSTATS: Version 15.2.08
%
%   Description
%       Designed to be used with the output argument of FILTERAMPS
%       triallist should be the input argument to filteramps (can be
%       omitted)
%       chanlist (optional): Channels to display
%       Its a good idea to call this function whenever filteramps is used,
%       e.g in higher level scripts like docopyds and dofilteramps, to
%       check for broken sensor wires or overload of ADC (sensor too close
%       to transmitter)
%
%   See Also
%       FILTERAMPS

maxchan=12;

if nargin<2 triallist=1:size(pegelstats,1); end;
if isempty(triallist) triallist=1:size(pegelstats,1); end;

usersensornames=int2str((1:maxchan)');

if nargin<3 chanlist=1:maxchan; end;

mycols=hsv(length(chanlist)+1);


hf1=figure;
hax=axes;
set(gca,'colororder',mycols);

hold on;

hl1=plot(triallist,squeeze(pegelstats(:,1,chanlist)),'linewidth',2);
hl2=plot(triallist,squeeze(pegelstats(:,2,chanlist)),'linewidth',2,'linestyle','--');

legend(hl1,usersensornames(chanlist,:));

title('Pegel Max-Min');

xlabel('Trial number');
ylabel('RMS signal level (normalized)');

hf2=figure;
hax2=axes;
set(gca,'colororder',mycols);
hold on;
hl3=plot(triallist,squeeze(pegelstats(:,3,chanlist)),'linewidth',2);

title('Pegel Diff')
disp('Type ''return'' to delete figures and continue');
keyboard;
close([hf1 hf2]);
