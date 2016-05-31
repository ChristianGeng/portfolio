function mt_epgdis(epgframe,epgpos,hl)
% MT_EPGDIS Show frame of epg data
% function mt_epgdis(epgframe,epgpos,hl)
% MT_EPGDIS: Version 11.10.02
%
%	Syntax
%		epgframe: one frame of epg data
%		epgpos and hl are optional arguments that can be used to speed up display.
%			They contain the position of the electrodes and the handle of the line object to show active electrodes
%			If absent they are retrieved first

if nargin<3
   myax='EPG';
   if nargin==2 myax=epgpos; end;
   hf=mt_gfigh('mt_epg');
   axh=findobj(hf,'tag',myax,'type','axes');
   myS=get(axh,'userdata');
   
   epgpos=myS.sensor_position;
	hl=findobj(axh,'tag',[myax '_data']);
end;

v=find(epgframe);
%ev. also zdata
% and eventually also allow for patch or surface with facecoloring

%keyboard


set(hl,'xdata',epgpos(v,1),'ydata',epgpos(v,2),'zdata',epgpos(v,3));

