function showtrial_visibset(siglist,visspec)
% SHOWTRIAL_VISIBSET Set visibility of channels in show_trialox
% function showtrial_visibset(siglist,visspec)
% showtrial_visibset: Version 26.0.5.2013
%
%   Description
%       For use with show_trialox, e.g. from lida_rtmon2file
%       siglist: list of channels for which visibility is to be set
%           can be a substring of the full name, e.g. 'T' matches T_TIP,
%           T_BACK etc. Set up the list using str2mat (e.g.
%           str2mat('tip','ref','jaw')), or as cell string (e.g
%           {'tip','ref','jaw'}
%       vissspec: 'on', or 'off'. All channels in siglist are set to this
%           value. All other channels are set to the opposite value.
%       If there are no input arguments visiblity of all channels is set to
%           'on'
%   
%   Note
%       In the trajectory display of the current trial (usually fig. 2) it
%       is not currently possible to turn the mean orientation vectors in
%       the position display on and off

%normally fig 1 (trial timewaves)
hf=findobj('type','figure','tag','showtrial_cbfig');

udata=get(hf,'userdata');

lineh=udata.lines;
signames=char(get(lineh(:,1),'tag'));
nsig=size(signames,1);

%if no input arguments just set all channels to visible on, and return
if nargin==0
    myvis='on';
    
    for ii=1:nsig
        hh=findobj('type','line','tag',deblank(signames(ii,:)));
        set(hh,'visible',myvis);
    end;
    
    return;
end;



%first set all channels to the opposite visibility setting

myvis='on';
if strcmp(visspec,'on') myvis='off'; end;

for ii=1:nsig
    hh=findobj('type','line','tag',deblank(signames(ii,:)));
    set(hh,'visible',myvis);
end;

%now set any signals matching the specification in siglist to visspec

siglist=char(siglist);      %can be a cell string
    
for ii=1:size(siglist,1)
    myspec=deblank(siglist(ii,:));
    vc=strmatch(myspec,signames);
    nvc=length(vc);
    for jj=1:nvc
        hh=findobj('type','line','tag',deblank(signames(vc(jj),:)));
        set(hh,'visible',visspec);
    end;
end;

