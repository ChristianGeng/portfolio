function mtkmdx
% MTKMDX mt user commands main_display_xy
% function mtkmdx
% mtkmdx: Version 26.08.02
%
%	Description
%		User interface for setting up xy display. See mt_xydis and mt_inixy for details
%		Note that the xy figure can be subdivided into any number of axes, each with its
%		own display settings
%
%	See also
%		MT_INIXY initialize xy figure
%		MT_XYDIS does the actual display
%		MT_GXYAD MT_SXYAD get/set xy axes data
%		MT_GXYFD MT_SXYFD get/set xy figure data

persistent K axesname
kname='mdx';
if isempty(K)
   myS=load('mt_skey',['k_' kname]);
   K=getfield(myS,['k_' kname]);
   clear myS;
   axesname=[];
   mlock;   
end;
[abint,abnoint,abscalar,abnoscalar]=abartdef;
command=-1;
axeslist=mt_gxyad;
%if ~isempty(axeslist) axesname=deblank(axeslist(1,:));end;

while command~=K.return
   mystring=philinp([kname '> ']);
   if isempty(mystring)
      command=K.return;
   else
      command=abs(mystring(1));
   end;
   commandback=mtkcomm(command,K,'return');
   if commandback command=commandback; end;
   
   if command==K.initialize
      oldax=mt_gxyad;
      iok=1;
      if ~isempty(oldax)
         myrep=upper(abartstr('Initializing xy display. Are you sure?','n'));
         if ~strcmp(myrep,'Y') iok=0;end;
      else
         oldax='xy';
      end;
      if iok
         axislist=rv2strm(abartstr('Enter list of axes names as blank-separated list',oldax));
         nax=size(axislist,1);
         subp=[1 1];
         if nax>1
            subp=abart('Subplot arrangement (2-element vector)',[nax 1],1,nax,abint,abnoscalar);
         end;
         mt_inixy(axislist,subp);
         axesname=deblank(axislist(1,:));
      end;
   end;	%initialize
   
   
   %next two should be under figure settings
   
   if command==K.figure_settings
      userfields=str2mat('display_flag','sub_cut_flag');
      
      myfield=abartstr('Choose field',deblank(userfields(1,:)),userfields,abscalar);
      myv=mt_gxyfd(myfield);
      
      switch myfield
      case 'display_flag'
         
         [axesname,axi]=aname(axesname);
         myv(axi)=1-myv(axi);
         disp(['New display_flag setting for ' axesname ' ' int2str(myv(axi))]);
         mt_sxyfd('display_flag',myv);
         
      case 'sub_cut_flag'
         myv=abart('Sub_cut control; 0=off, 1=all on, vector=selected on',myv,-1000,1000,abint,abnoscalar);
         disp(['New sub_cut setting: ' int2str(myv)]);
      end;
      mt_sxyfd(myfield,myv);
      
   end;		%figure setting
   
   
   
      if command==K.axes_settings
      axesname=aname(axesname);
      
      
      
      %These are not all the fields, just the ones it makes sense to modify interactively
      
      userfields=str2mat('n_trajectories','trajectory_names','hold_mode','contour_order','surface_mode','sub_cut_marker','sub_cut_linestyle','sub_cut_labelposition');
      
      myfield=abartstr('Choose field',deblank(userfields(1,:)),userfields,abscalar);
      myv=mt_gxyad(axesname,myfield);
      
      switch myfield
      case 'n_trajectories'
         newv=abart('New value',myv,1,size(mt_gsigv,1),abint,abscalar);
      case 'hold_mode'
         mymodes=str2mat('off','on');
         newv=abartstr('Enter hold mode for trajectories',myv,mymodes,abscalar);
         
      case 'surface_mode'
         mymodes=str2mat('off','both','row','column');
         newv=abartstr('Enter grid mode for xy surface object',myv,mymodes,abscalar);
         
      case 'sub_cut_marker'
         hl=findobj('type','line');
         mymodes=set(hl(1),'marker');
         newv=myv;
         tmp1=abartstr('Enter marker type for sub_cut start',myv(1),mymodes,abscalar);
         tmp2=abartstr('Enter marker type for sub_cut end',myv(2),mymodes,abscalar);
      	newv=str2mat(tmp2,tmp2);
      case 'sub_cut_linestyle'
         hl=findobj('type','line');
         mymodes=set(hl(1),'linestyle');
         newv=myv;
         tmp1=abartstr('Enter linestyle for sub_cut start',myv(1),mymodes,abscalar);
         tmp2=abartstr('Enter linestyle for sub_cut end',myv(2),mymodes,abscalar);
      	newv=str2mat(tmp2,tmp2);
      case 'sub_cut_labelposition'
         newv=abart('New value',myv,-10000,10000,abnoint,abscalar);
      case 'contour_order'
         mylist=mt_gxyad(axesname,'trajectory_names');
         newv=myv;
         if isempty(mylist)
            disp('Trajectory names must be defined before contour order can be chosen');
         else
            mylist=str2mat('<default>','<line_break>',mylist);
            %note: if abartstr calls listdlg abitrary ordering and multiple use of same trajectory doesn't work 
            disp('Contour order: Enter blank-separated list of trajectory names');
            newv=abartstr('>',myv,mylist,abnoscalar);
         end;
      case 'trajectory_names'
         newv=abartstr('Enter blank-separated list of trajectory names',myv);
			newv=rv2strm(newv);
         %	otherwise???
         
      end;	%switch
      
      mt_sxyad(axesname,myfield,newv);
      
      
   end;	%axes settings
   if command==K.get_settings
      
      %choice of figure or axes.....
      
      axesname=aname(axesname);
   myS=mt_gxyad(axesname);
   disp(myS);
end;

if command==K.axis_settings
   
   %%something for xlabel etc.????
   
   axesname=aname(axesname);
   modelist=str2mat('signal_data','time','constant','sensor_number');
   axislet=abartstr('Axis letter','x',str2mat('x','y','z','c'),abscalar);
   mymode=mt_gxyad(axesname,[axislet '_mode']);
   newmode=abartstr('New Mode',mymode,modelist,abscalar);
   
   defaultlabel='';
   %note: need to choose new mode to change signal list
   
   if strcmp(newmode,'signal_data')
      trajlist=mt_gxyad(axesname,'trajectory_names');
      oldspec=mt_gxyad(axesname,[axislet '_spec']);
      if isempty(trajlist)
         disp('Please define trajectory names before defining axis modes');
         newmode=mymode;
      else
         ntraj=size(trajlist,1);		
         allsigs=mt_gsigv;
         
         quickchar=upper(abartstr('Generate signal list from trajectory names?','n'));
         if strcmp(quickchar,'Y')
            sigsuff=abartstr('Signal suffix',axislet);
            newlist=strmdebl([trajlist rpts([ntraj 1],sigsuff)]);
            %should check these are valid signal names
            myunits=mt_gsigv(newlist(1,:),'unit');	%assume units are same; should check!!
            defaultlabel=[sigsuff ' (' myunits ')'];   
         else
            newlist=abartstr('Choose signals',oldspec,allsigs,abnoscalar);
            %	check right number of signals???
         end;
         
         if ntraj==1 
            myunits=mt_gsigv(newlist(1,:),'unit');
            defaultlabel=[deblank(newlist(1,:)) ' (' myunits ')'];
         end;
         
         if isempty(defaultlabel)
            disp('Please set axis label by hand');
         end;
         
         
         %	set n_traj and samplerate
         sigok=1;
         
         sf=unique(mt_gsigv(newlist,'samplerate'));
         
         if length(sf)~=1
            sigok=0;
            disp('Inconsistent sample rates??');
         end;
         
         
         oldn=mt_gxyad(axesname,'n_trajectories');
         newn=size(newlist,1);
         if newn~=ntraj
            disp('No. of signals does not match number of trajectories');
            sigok=0;
         end;
         
         
         
         if sigok
            mt_sxyad(axesname,'samplerate',sf);
            if oldn~=newn
               disp(['Changing n_trajectories from ' int2str(oldn) ' to ' int2str(newn)]);
               mt_sxyad(axesname,'n_trajectories',newn);
            end;
            
            mt_sxyad(axesname,[axislet '_spec'],newlist);
            
         end;	%sigok
         
      end;		%traj names defined
      
      
   end;		%signal data mode
   
   if strcmp(newmode,'constant');
      oldspec=mt_gxyad(axesname,[axislet '_spec']);
      newspec=abartstr('Constant expression',oldspec);
      mt_sxyad(axesname,[axislet '_spec'],newspec);
      defaultlabel=newspec;
      
   end;
   
   if strcmp(newmode,'time') defaultlabel='Time (s)'; end;
   if strcmp(newmode,'sensor_number') defaultlabel='Sensor'; end;
   
   
   mt_sxyad(axesname,[axislet '_mode'],newmode);
   
   %colour axis will need handling differently : colorbar (cf. sona display)
   if ~strcmp(axislet,'c')
   hoho=findobj(mt_gfigh('mt_xy'),'type','axes','tag',axesname);
   hoho=get(hoho,[axislet 'label']);
   set(hoho,'string',defaultlabel);
	end;

   
end;	%axis settings

end;		%while not return


function [axesname,axi]=aname(olda);
%prompt for axes name if more than one axis

abscalar=1;
axeslist=mt_gxyad;
if size(axeslist,1)>1
   axesname=abartstr('Choose axes',olda,axeslist,abscalar);
else
   axesname=axeslist;
   
end;
axesname=deblank(axesname);

if nargout>1
   axi=strmatch(axesname,axeslist);
end;
