% MT_SKEY Script to assign commands to keys
% mt_skey
% mt_skey: Version 22.08.2013
%
% Description
%   This script is called when mtnew is started.
%   To redefine keys either edit this script or (safer)
%   use keyboard mode (or command evaluation)
%   to call an alternative script (or load a MAT file with appropriate assignments)
%
% Notes
%   Note the use of the abs function; this is because the variables are numerical
%   Cursor level commands can use control characters
%   except control a,b and c since these have the values used to indicate the mouse buttons
%   i.e 1, 2 and 3 for left, middle and right respectively.
%   Warning: Program does not check for inconsistent assignments
%
% See Also
%   MT_INIMENU MTKCOMM
%
% Updates
%	8.2002 K_names variable added to translate between short name of structure with key definitions
%		and the full command names needed to get to that menu. Used by MTKCOMM for the local help function
%   8.2013 Add surface-related commands

level1=1;level2=2;level3=3;	%dummy variables for identation

%====================================================
%common commands available from all following submenus
%!! This means keys used here cannot be used elsewhere!!

k_common.global_help=abs('H');
k_common.local_help=abs('h');
k_common.what=abs('?');
k_common.keyboard=abs('k');
k_common.eval_command=abs('v');
k_common.eval_variable=abs('+');

k_names.common='common';

%=====================================================
if level1
   
   %main
k_names.m='main';
   k_m.next=abs('n');
   
   
   k_m.i_o=abs('i');
   if level2
      k_names.mi='i_o';

      k_mi.return=abs('r');
      k_mi.audiochannel=abs('a');
      k_mi.plot=abs('p');
      k_mi.quit=abs('q');
   end;      
   
   
   k_m.show=abs('s');  
   
   if level2
k_names.ms='show';
      k_ms.return=abs('r');
      k_ms.timedisplay=abs('t');
      k_ms.xycursor=abs('x');
      k_ms.xyscreen=abs('X');
      k_ms.sonacursor=abs('s');
      k_ms.sonascreen=abs('S');
      k_ms.moviecursor=abs('m');
      k_ms.moviescreen=abs('M');
      k_ms.videocursor=abs('f');		%use f for 'film' as 'v' is needed for common command
      k_ms.videoscreen=abs('F');
      k_ms.surfcursor=abs('p');		%s used for sona. use 'p' for parametric surface. maybe 'u' as most likely to be useful for scan-converted ultrasound 
      k_ms.surfscreen=abs('P');
      k_ms.epgcursor=abs('e');
      k_ms.epgscreen=abs('E');
      
      
   end;
   
   
   
   
   k_m.cursor=abs('c');
   
   if level2
k_names.mc='cursor';
      
      % main_cursor
      %cursor key assignments for use with numeric keypad
      k_mc.slowleft=abs('1');
      k_mc.fastleft=abs('4');
      k_mc.jumpleft=abs('7');
      k_mc.slowright=abs('2');
      k_mc.fastright=abs('5');
      k_mc.jumpright=abs('8');
      k_mc.swap=abs('0');
      
      k_mc.leftcursor2pointer=1;  %left mouse button
      k_mc.rightcursor2pointer=3;  %right mouse button
      
      %move cursor to marker
      k_mc.jumpmstart=abs('[');
      k_mc.jumpmend=abs(']');
      
      k_mc.nextzx=abs('z');
      k_mc.previouszx=abs('Z');
      
      k_mc.nextsubcut=abs('c');
      k_mc.previoussubcut=abs('C');
      k_mc.xyview=abs('w');
      
      k_mc.imageatcursor=abs('i');	%uses mt_video
      k_mc.toggleautoimageupdate=abs('I');
      
        k_mc.zeroxsettings=abs('Y');
      
      k_mc.return=abs('r');
      
      k_mc.sound=abs('s');

      k_mc.edit=abs('e');
      
      if level3
k_names.mcs='cursor sound';
         
         %main cursor sound
         %1. basic commands
         k_mcs.cursor=abs('s');
         k_mcs.screen=abs('S');
         k_mcs.cut=abs('c');
         k_mcs.trial=abs('t');
         
         %2. marker related
         %(set up for keypad)
         k_mcs.current_marker=abs('3');
         k_mcs.numbered_marker=abs('6');
         
         %3. context
         % from screen or cut boundary to nearest cursor
         k_mcs.left_screen=abs('l');
         k_mcs.right_screen=abs('r');
         k_mcs.left_cut=abs('L');
         k_mcs.right_cut=abs('R');
         % "eXtended". from screen or cut boundary to furthest cursor
         %(English keyboard!)
         k_mcs.xleft_screen=abs('[');
         k_mcs.xright_screen=abs(']');
         k_mcs.xleft_cut=abs('{');
         k_mcs.xright_cut=abs('}');
         
      end;	%level3
      
      k_mc.marker=abs('m');
      
      if level3
k_names.mcm='cursor marker';
         
         % main_cursor_marker
         k_mcm.set_start=abs('s');
         k_mcm.set_end=abs('e');
         k_mcm.clear_start=abs('S');
         k_mcm.clear_end=abs('E');
         
         k_mcm.decrease_type=abs('d');
         k_mcm.increase_type=abs('u');
         k_mcm.set_type=abs('t');
         k_mcm.set_label=abs('l');
         
      end; %level 3
      
      if level3
          k_names.mce='cursor edit';
          k_mce.return=abs('q');
          k_mce.deletebetweencursor=abs('d');
          k_mce.deleteatactivecursor=abs('D');
          k_mce.replacebetweencursor=abs('r');
          k_mce.replaceatactivecursor=abs('R');
          k_mce.chooseeditsignal=abs('c');
          k_mce.choosereplacementsignal=abs('C');
          k_mce.usekeyboard=abs('K');
          k_mce.executeequation=abs('e');
          k_mce.defineequation=abs('E');
          k_mce.interpolate=abs('i');
          k_mce.setinterpolationmethod=abs('I');
          k_mce.saveandexit=abs('x');
      end; %level 3
      

      
   end;	%level2      
   
   k_m.timeshift=abs('t');
   
   if level2      
k_names.mt='timeshift';
      
      %main_timeshift
      k_mt.return=abs('q');		%quit!!!, 'r' key needed below
      k_mt.t0=abs('0');
      k_mt.duration=abs('d');
      
      k_mt.skipforwards=abs('s');
      k_mt.skipbackwards=abs('S');
      k_mt.start2left=abs('l');
      k_mt.end2left=abs('L');
      k_mt.start2right=abs('r');
      k_mt.end2right=abs('R');
      k_mt.start2start=abs('b');
      k_mt.end2end=abs('B');
      %20.11.97 skip commands using markers
      k_mt.start2mstart=abs('[');
      k_mt.start2mend=abs(']');
      k_mt.end2mstart=abs('{');
      k_mt.end2mend=abs('}');
      
      %set by audio functions, see mtkmcs
      k_mt.bookmark=abs('m');
      k_mt.zoomin2cursor=abs('z');
      k_mt.zoomout2cut=abs('Z');
		k_mt.centre2cutpos=abs('c');	%uses  organization figure      
		k_mt.startend2cutpos=abs('C');	%uses  organization figure      
      
   end;	%level2      
   
   k_m.display_settings=abs('d');
   
   if level2      
k_names.md='display_settings';
      
      % main_display
      k_md.return=abs('r');
      k_md.foreground=abs('f');
      k_md.plotedit=abs('p');
      
      %Submenus for each figure
      k_md.setxy=abs('x');
      
      if level3
k_names.mdx='display_settings setxy';
         
         %main_display_xy
         k_mdx.return=abs('r');
         k_mdx.initialize=abs('i');
         k_mdx.figure_settings=abs('f');
         k_mdx.axes_settings=abs('a');
         k_mdx.axis_settings=abs('x');
         k_mdx.get_settings=abs('g');
         
      end;	%level 3
      
      k_md.settime=abs('t');
      
      if level3
k_names.mdt='display_settings settime';
         
         % main_display_f(t)
         k_mdt.return=abs('r');
         k_mdt.initialize=abs('i');
         k_mdt.choose_signals=abs('c');
         k_mdt.pair_axes=abs('p');
         k_mdt.cancel_pairing=abs('P');
         k_mdt.sub_cut_control=abs('s');
         k_mdt.get_settings=abs('g');
         k_mdt.up=abs('u');
         k_mdt.down=abs('d');
         k_mdt.extremes=abs('e');
         k_mdt.clipping=abs('x');
         
      end; %level3
      
      k_md.setorganization=abs('o');
      
      if level3
k_names.mdo='display_settings setorganization';
         
         %main_display_organization
         k_mdo.return=abs('r');
         k_mdo.maxmin_trial=abs('t');
         k_mdo.maxmin_cut=abs('c');
         
      end;	%level3
      
   end;	%level2
   
   %
   
   
end;	%level1


%==================================================

save mt_skey k_common k_m k_mi k_ms k_mc k_mt k_md k_mdt k_mdx k_mdo k_mcm k_mcs k_mce k_names

mt_inimenu;