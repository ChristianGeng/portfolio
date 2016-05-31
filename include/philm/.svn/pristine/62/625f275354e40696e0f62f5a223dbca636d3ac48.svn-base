function mt_fixepg(markersize)
% FIXEPG Typical settings for mt EPG display
% function mt_fixepg
% fixepg: Version 9.5.08
%
%   Description
%       Does some settings that are typically useful for EPG displays
%       Designed to be called from an mtnew command file
%       Handles basic EPG figure (contact pattern), as well as sonagram
%       style display
%       For alternative display customizations make a copy of this function
%       in the working directory under a different name and call it instead
%       after editing
%       It sets the ydir to reverse, i.e it assumes row 1 is the frontmost
%       row, and the front row should be at the top of the display
%       It inserts an ygrid to separate rows in the sona display
%       With the optional input argument markersize the size of the
%       contacts in the basic EPG display can be modified.
%       Any comment in dimension.external is displayed in the help window
%       Assumes name of epg signal is 'EPG'

oldax=gca;

epgname='EPG';      %could be input arg

hf=mt_gfigh('mt_sona');
if ~isempty(hf)

    ha=findobj(hf,'tag',epgname);
    if ~isempty(ha)
        %allow for 'missing' electrodes in first row
        mygrid=[1.5 7.5 8.5:8:64.5];
        set(ha,'ytick',mygrid)
        set(ha,'ygrid','on');
        set(ha,'ydir','reverse');
        set(ha,'layer','top');
    end;
end;


hf=mt_gfigh('mt_epg');
if ~isempty(hf)
    D=mt_gsigv(epgname,'dimension');

    if isfield(D.external,'comment');
        dcomment=D.external.comment;

        helpwin(dcomment,'EPG electrode arrangement');
    end;

    ha=findobj(hf,'type','axes');
    set(ha,'xlim',[0 9],'ylim',[0 9],'xtick',[1:8],'ytick',[1:8]);
    %dcomment=strrep(dcomment,crlf,' / ');

    if nargin
        %default maker size is 10
        hl=findobj(ha,'type','line','tag','EPG_data');
        if ~isempty(hl)
            set(hl,'markersize',markersize);
        end;

    end;

    set(ha,'ydir','reverse');
    %axes(ha);
    %text(0,0,dcomment,'verticalalignment','top');
end;

axes(oldax);
