function [x,y,z,button] = mmginput
% MMGINPUT Stripped down version of GINPUT for use with MTNEW
%GINPUT Graphical input from mouse.
%   [X,Y] = GINPUT(N) gets N points from the current axes and returns 
%   the X- and Y-coordinates in length N vectors X and Y.  The cursor
%   can be positioned using a mouse (or by using the Arrow Keys on some 
%   systems).  Data points are entered by pressing a mouse button
%   or any key on the keyboard except carriage return, which terminates
%   the input before N points are entered.
%
%   [X,Y] = GINPUT gathers an unlimited number of points until the
%   return key is pressed.
% 
%   [X,Y,BUTTON] = GINPUT(N) returns a third result, BUTTON, that 
%   contains a vector of integers specifying which mouse button was
%   used (1,2,3 from left) or ASCII numbers if a key on the keyboard
%   was used.

%   Copyright (c) 1984-97 by The MathWorks, Inc.
%   $Revision: 5.19 $  $Date: 1997/04/08 06:55:47 $


%set(gcf,'keypressfcn','');

x=[];y=[];z=[];button=[];

validpress=0;

while~validpress

fig = gcf;
    figure(gcf);
	ax=gca;
    fig_units = get(fig,'units');
    
    
    oldcallback=get(fig,'keypressfcn');
    set(fig,'keypressfcn','');
    
    keydown=waitforbuttonpress;
    set(fig,'keypressfcn',oldcallback);
    
        ptr_fig = get(0,'CurrentFigure');
        if(ptr_fig == fig)
            if keydown
                button = abs(get(fig, 'CurrentCharacter'));
                if ~isempty(button)
                scrn_pt = get(0, 'PointerLocation');
                set(fig,'units','pixels')
                loc = get(fig, 'Position');
                pt = [scrn_pt(1) - loc(1), scrn_pt(2) - loc(2)];
                set(fig,'CurrentPoint',pt);
                validpress=1;
                end;
                
            else
                mytype = get(fig, 'SelectionType');
                %unlike ginput return 4 for double click
                %however, this will probably never occur unless the
                %programm waits
                %next line replaces normal, extend, alt, open
                %strcmp in ginput
                
                button=find(abs(mytype(1))==abs('neao'));
                validpress=1;
                
            end				%keydown
            if validpress
            axes(ax);
            pt = get(gca, 'CurrentPoint');

				%note current point has 2 rows : 'front' and 'back'
            x = pt(1,1);
            y = pt(1,2);
            z = pt(1,3);
    			set(fig,'units',fig_units);
            end;
            
          else
             figure(fig);	%make sure same current figure at end
        end

end;        %while
%set(gcf,'keypressfcn','minicb');
