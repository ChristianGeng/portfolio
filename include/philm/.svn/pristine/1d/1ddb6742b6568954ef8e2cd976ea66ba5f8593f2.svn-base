function mtkmcs(inflag)
% mtkmcs mt user commands main_cursor_sound
% Syntax
%    If inflag is present input is taken from philinp, otherwise from mmginput
%		If inflag is "true" cursor is animated during playback
%		this also means function does not return until playback is complete (but see below)
%		For normal cursor-level usage cursor is animated during playback
%		but animation can be teminated by pressing <space>

persistent K
kname='mcs';
if isempty(K)
   myS=load('mt_skey',['k_' kname]);
   K=getfield(myS,['k_' kname]);
   clear myS;
   mlock;   
end;
[abint,abnoint,abscalar,abnoscalar]=abartdef;
command=-1;

if ~nargin
   disp([kname '> ']);
   if philcomempty
      [mousepx,mousepy,mousepz,command]=mmginput;
   else
      command=philinp('');
      mousepx=[];				%may need to watch for this
         if length(command)~=1 command=-1; end;
   end;
   
   if isempty(command) command=-1;end;
else
   
   mystring=philinp([kname '> ']);
   if ~isempty(mystring)
      command=abs(mystring(1));
   end;
end;

commandback=mtkcomm(command,K,'cursor');
   if commandback command=commandback; end;

%this assumes fieldnames defined in mt_skey are basically identical
%to the sound specification understood by mt_audio

mysound=findfield(K,command);

if ~isempty(mysound)
   if strcmp(mysound,'current_marker')
      mysound='marker';
   end;
   
   if strcmp(mysound,'numbered_marker')
      mysound='marker';
      if ~nargin
         typekeys='123456789';
         
         if philcomempty
            [dodox,dodoy,dodoz,tmpchar]=mmginput;
            if isempty(tmpchar) tmpchar='0'; end;
            tmpchar=setstr(tmpchar);
         else
            tmpchar=philinp('');
         if length(tmpchar)~=1 tmpchar='0'; end;
         end;
         
         if findstr(tmpchar,typekeys) mysound=[mysound tmpchar]; end;
      else
         mymark=abart('Marker number',mt_gmarx('current_marker'),1,mt_gmarx('n_markers'),abint,abscalar);
         mysound=[mysound int2str(mymark)];   
      end;
   end;
   
   
   usedtime=mt_audio(mysound);
   aniflag=1;
   if nargin aniflag=inflag; end;
   if aniflag
   myanim(usedtime);   
	end;   
   
end;		%mysound not empty


function myanim(usedtime)
%%%%%%%%
%skeleton animated cursor support

%get handles of time movie cursors....
%skip if none found
%cancel if keypressed???
%if philinp mode 2nd arg. to suppress movie
%allow for altered sample rate.....

tic;
figure(gcf);
hmc=mt_gfigd('time_cursor_handles');
hmc=hmc(:,3);
%eliminate NaNs???

set(hmc,'visible','on');
drawnow;
lasttoc=-1;
itoc=-2;
mylength=diff(usedtime);
%set(gcf,'windowbuttondownfcn','butcb');
gcfx=gcf; %just a chance it may get changed while sound output is in progress??
lastchar=get(gcf,'currentcharacter');
while ((itoc<=mylength)& (strcmp(get(gcf,'currentcharacter'),lastchar)));
%while ((itoc<=mylength)& (~isempty(get(gcf,'windowbuttondownfcn'))));
%   disp(get(gcf,'currentcharacter'));
   itoc=toc;
   if itoc~=lasttoc
      if itoc<=mylength
         xtime=usedtime(1)+itoc;
         set(hmc,'xdata',[xtime;xtime]);
      		drawnow;   
      end;
      
      lasttoc=itoc;
   end;
end;

%disable the callback function

%set(gcfx,'windowbuttondownfcn','');

%set lasttoc as "bookmark"

set(hmc,'visible','off');

myS=mt_getft;
myS.bookmark=lasttoc;
set(mt_gfigh('mt_f(t)'),'userdata',myS);





function myfield=findfield(myS,myval)
%findfield Find field of struct set to target value
%function myfield=findfield(myS,myval)
%findfield: Version 21.10.98

myfield='';
mynames=fieldnames(myS);
nf=length(mynames);
for ii=1:nf
   fv=getfield(myS,mynames{ii});
   if fv==myval
      myfield=mynames{ii};
   end;
end;

