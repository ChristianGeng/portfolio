%MTCMDHLP: Version 23.08.02
%
% Quickstart
%
%	MTNEW: Version 23.08.02
%	At any program prompt type:
%		?	to get a list of currently available choices
%		h	to get a description of currently available commands
%		H	to open the full on-line documentation
%	Use the menu bar in the mt_organization figure to view
%		the command hierarchy. Click on any terminal member in the 
%		hierarchy to obtain a description of that command.
%	Many cursor movement commands are assigned to numeric keys.
%		Engage the numlock key if you want to use the numeric keypad 
%		for cursor movement (but you will need to disengage it on 
%		Linux systems to move and resize figures).
%   
% Cursor
%
%	Introduction
%		Unlike all other commands, commands at this level are carried
%		out immediately when the command key is pressed. When the
%		cursor level is activated two cursors become visible in the
%		f(t) figure. If a sonagram figure has been activated, linked
%		cursors will be visible here, too. If an xy display has been
%		activated, the time instants corresponding to the two cursors
%		are marked by contours (e.g of the tongue) linking up the time-
%		points on the trajectories. In all these figures, one of the
%		cursors is green and one is red. The green one is referred to
%		as the active cursor. Many commands operate specifically on the
%		active cursor.
%		In order for the cursor commands to work, the mouse pointer
%		must be in the f(t) figure and the figure must be active (i.e
%		title bar is highlighted). In fact, it is possible to designate
%		other figures as the target figure for cursor commands (this is
%		done with the main>display_settings>foreground command). This
%		is most likely to be useful for the sonagram figure, so that
%		the mouse can be moved over the sonagram to position the
%		cursors. It is not recommended to set a non-time-based figure
%		like the xy figure or a video figure to be the foreground
%		figure.
%		Cursor commands are mainly used for moving the cursors around
%		(surprise!). In addition to some miscellaneous commands there
%		are two important submenus, one for sound, and one for defining
%		segment boundaries and labelling the signal (= marker
%		commands).
%		A note on the cursor movement commands: It should be obvious,
%		but don't forget that the right cursor can never be moved to
%		the left of the left cursor, and vice-versa. The default key
%		assignments have been based on use of the numeric keypad with
%		the right hand, and movement of the mouse with the left hand,
%		with left and right buttons positioning left and right cursors
%		respectively.
%
%	leftcursor2pointer
%		Moves the left cursor to the current position of the mouse
%		pointer.
%
%	rightcursor2pointer
%		Moves the right cursor to the current position of the mouse
%		pointer.
%
%	slowleft
%		Moves the active cursor to the left in small steps. One step is
%		defined as 0.001 times the current length in seconds of the
%		f(t) display.
%
%	fastleft
%		Moves the active cursor to the left in large steps. One step is
%		defined as 0.01 times the current length in seconds of the f(t)
%		display, i.e 10 times the size of the slowleft command.
%
%	slowright
%		Moves the active cursor to the right in small steps. One step
%		is defined as 0.001 times the current length in seconds of the
%		f(t) display.
%
%	fastright
%		Moves the active cursor to the right in large steps. One step
%		 is defined as 0.01 times the current length in seconds of the
%		f(t) display, i.e 10 times the size of the slowright command.
%
%	jumpleft
%		Moves both cursors to the left by the time corresponding to the
%		current distance between the cursors. Thus the right cursor
%		moves onto the previous position of the left cursor, and the
%		distance between the cursors does not change.
%
%	jumpright
%		Moves both cursors to the right by the time corresponding to
%		the current distance between the cursors. Thus the left cursor
%		moves onto the previous position of the right cursor, and the
%		distance between the cursors does not change.
%
%	swap
%		Swaps the active cursor, i.e the red cursor turns green and the
%		green one red.
%
%	jumpmstart
%		Move active cursor to current start marker.
%		This command will only have any effect if marker commands have
%		been used to define segment boundaries. See discussion of
%		marker commands for further background. The command will also
%		have no effect if  e.g the active cursor is the left cursor and
%		the current start marker is to the right of the right cursor
%		(and vice-versa).
%
%	jumpmend
%		Move active cursor to current end marker.
%		This command will only have any effect if marker commands have
%		been used to define segment boundaries. See discussion of
%		marker commands for further background. The command will also
%		have no effect if  e.g the active cursor is the left cursor and
%		the current end marker is to the right of the right cursor (and
%		vice-versa).
%	previouszx
%		Move active cursor to previous zero crossing in the audio
%		signal. (Note: In fact any signal can be used as the audio
%		channel. See main>i_o>audiochannel.)
%
%	nextzx
%		Move active cursor to next zero crossing in the audio signal.
%		(Note: In fact any signal can be used as the audio channel. See
%		main>i_o>audiochannel.). Currently, only the positive zero-crossing can be used.
%
%	previoussubcut
%		Moves the left and right cursors onto the start and end
%		boundaries, respectively, of the last subcut whose start
%		boundary is to the left of the current left-cursor position. If
%		no subcuts are completely within the current f(t) display, the
%		cursors are not moved.
%		Subcuts (and how they differ from markers) are explained
%		elsewhere.
%		See main>display_settings>settime>sub_cut_control for
%		information on activating subcut display.
%
%	nextsubcut
%		Moves the left and right cursors onto the start and end
%		boundaries, respectively, of the first subcut whose start
%		boundary is to the right of the current left-cursor position.If
%		 no subcuts are completely within the current f(t) display,
%		the cursors are not moved. Also, the command may not work quite
%		as expected if the next subcut is not completely on the screen,
%		but a later one is. Here, too, the cursors will not be moved.
%		Subcuts (and how they differ from markers) are explained
%		elsewhere.
%		See main>display_settings>settime>sub_cut_control for
%		information on activating subcut display.
%
%	xyview
%		Changes the view of displays in the xy figure. For 2D displays
%		of 3D data (e.g sagittal, coronal or transversal views) it is
%		often convenient to design the display as 3D and then switch
%		between the possible views, rather than set up completely
%		different displays for the different viewing planes.
%		After giving this command the user is prompted for the desired
%		view. Give a 2-letter string (e.g �yx', �xz') to specify the
%		real-world axes to assign to the display x and y axis
%		respectively (it is also possible to revert from a 2D display 
%		back to the default 3D display). Axis direction can be reversed
%		by prefixing the axis letter with a �-�, e.g �-xy'.
%		If there are multiple displays in the xy figure, choose the
%		axes system to be modified by clicking in the coordinate system
%		in the xy figure (it will then be necessary to reactivate the
%		f(t) figure by clicking in its title bar). If this is
%		inconvenient (e.g if you want to set the view in a startup
%		command file) consider using the underlying function MT_SXYV
%		directly (consult the function's help for further information).
%
%	imageatcursor
%		Display video frame corresponding to the time-instant of the
%		active cursor (only available if a video figure is operational)
%
%	toggleautoimageupdate
%		Determines whether video frame is automatically updated
%		whenever the active cursor is moved, i.e without having to
%		explicitly use the imageatcursor command. Initially, this
%		feature is not in operation (it may make cursor movement rather
%		sluggish, so it may not always be desirable).
%		(Only available if a video figure is operational.)
%
%	return
%		Exit from cursor mode and return to the main command level.
%
%	sound
%
%		Introduction
%			Activates the sound submenu (see cursor>sound).
%		 	The signal currently defined as the audio channel will be
%			output via the soundcard. Any signal can be assigned to
%			the audio channel (see main>i_o>audiochannel), but the
%			program tries to make an intelligent? initial choice (i.e
%			it looks for a signal called �audio' or �Audio').
%			Assigning non-audio signals like laryngograph or EMG can
%			actually be quite useful.
%			It is not possible to interrupt the sound output once it
%			has started. However, if any mouse button is pressed, the
%			sound function itself is terminated and new commands can
%			be entered by  the user. In particular, the time instant
%			in the sound signal at which the mouse button was pressed
%			is noted by the program, and it is possible to set the
%			time display in the f(t) figure with this time point at
%			the centre of the screen by using the
%			 main>timeshift>bookmark command (see that command for a
%			detailed example).
%
%		cursor
%			Plays the segment delimited by the current left and right
%			cursor positions
%
%		screen
%			Plays the currently visible f(t) screen
% 
%		cut
%			Plays the whole of the current cut
% 
%		trial
%			Plays the whole of the current trial (in simple cases
%			where no segmentation has been carried out, this will be
%			the same as the cut command
%
%		current_marker
%			Plays the segment delimited by the start and end
%			boundaries of the current marker type. If either the
%			start or end boundary has not been set the active cursor
%			is used instead, in which case it must be in an
%			appropriate position, i.e if  only the start boundary has
%			been set then the active cursor must be to the right of
%			this boundary (and vice-versa if only the end boundary
%			has been set).
%			For more background on markers see the marker submenu.
%
%		numbered_marker
%			Plays the segment delimited by the start and end
%			boundaries of the desired marker type. After this command
%			has been given, the user must type a single digit to
%			choose the marker type to be played (there is no prompt
%			for this choice, and the key pressed is not echoed).
%			Obviously, if more than 10 marker types are in operation
%			only marker types 1 to 9 can be played with this command.
%			If either the start or end boundary has not been set the
%			active cursor is used instead, in which case it must be
%			in an appropriate position, i.e if  only the start
%			boundary has been set then the active cursor must be to
%			the right of this boundary (and vice-versa if only the
%			end boundary has been set).
%			For more background on markers see the marker submenu.
%
%		left_screen
%			Plays from the start of the f(t) screen up to the left
%			cursor.
%
%		right_screen
%			Plays from right cursor up to the end of the f(t) screen.
%
%		left_cut
%			Plays from the start of the current cut up to the left
%			cursor.
%
%		right_cut
%			Plays from right cursor up to the end of the current cut.
%
%		xleft_screen
%			Plays from the start of the f(t) screen up to the right
%			cursor.
%			("x" stands for "extended", i.e unlike the corresponding
%			commands without "x" in the command name this command
%			(and  its counterparts like xleft_cut) plays up to the
%			cursor furthest from the start position.)
%
%		xright_screen
%			Plays from left cursor up to the end of the f(t) screen.
%
%		xleft_cut
%			Plays from the start of the current cut up to the right
%			cursor.
%
%		xright_cut
%			Plays from left cursor up to the end of the current cut.
%
%	marker
%
%		Introduction
%			Activates the marker submenu (see cursor>marker).
%			This menu allows markers to be set, moved and deleted,
%			and the resulting segments to be labelled.
%			See the separate section on cuts, subcuts and markers for
%			more background to marker files.
%			Currently, there is no command to activate the marker
%			functions. It is necessary to call function MT_IMARK
%			directly. See the help for this function for more
%			details. Basically, it is necessary to specify a marker
%			file, the number of marker types to be used, and whether
%			 the program is to work in append, edit, or read-only
%			mode.
%
%		set_start
%			Sets a start marker at the position of the active cursor,
%			using the current marker type. The marker is shown in the
%			f(t) figure (and the sona figure if present) as a solid
%			line going from the bottom of the figure up to a height
%			that depends on cut type. The solid line has a right-
%			pointing triangle as line-marker. The position of the
%			start marker is also shown in the organization figure
%			with green right-pointing triangles, with position
%			related to the oscillogram of the current cut. This
%			display can be useful for keeping track of what markers
%			have been set in cases where the f(t) figure does not
%			display all the current cut.
%			If the start marker has already been set, it is moved to
%			the active cursor position. In other words, it is not
%			necessary to clear the marker to set it again. This means
%			that it is necessary to be a little bit careful not to
%			reposition a marker inadvertently. In future, a mechanism
%			for locking markers to guard against this may be
%			introduced.
%		
%		set_end
%			Sets an end marker at the position of the active cursor,
%			using the current marker type. The marker is shown in the
%			f(t) figure (and the sona figure if present) as a dashed
%			line going from the bottom of the figure up to a height
%			that depends on cut type. The dashed line has a left-
%			pointing triangle as line-marker. The position of the end
%			marker is also shown in the organization figure with red
%			left-pointing triangles, with position related to the
%			oscillogram of the current cut. This display can be
%			useful for keeping track of what markers have been set in
%			cases where the f(t) figure does not display all the
%			current cut.
%			No end marker will be set if the active cursor is to the
%			left of the corresponding start marker (if already set).
%		
%		clear_start
%			Clears the start marker of the current marker type.
%
%		clear_end
%			Clears the end marker of the current marker type.
%
%		decrease_type
%			Decreases the current marker type by one (if the current
%			maker type is already 1, the program issues a warning but
%			does nothing). The current marker type is indicated by a
%			horizontal dashed line across the f(t) figure, and a
%			corresponding number on the y-axis on the right side of
%			the figure. It is also shown in a similar way across the
%			oscillogram of the current cut in the organization
%			figure,
%
%		increase_type
%			Increases the current marker type by one (if the current
%			maker type is already at the maximum value, the program
%			issues a warning but does nothing). The current marker
%			type is indicated by a horizontal dashed line across the
%			f(t) figure, and a corresponding number on the y-axis on
%			the right side of the figure. It is also shown in a
%			similar way across the oscillogram of the current cut in
%			the organization figure,
%
%		set_label
%			The user is prompted to enter a label. This is displayed
%			near the start marker of the current marker type. It is
%			actually quite possible to define a label even if the
%			corresponding start marker has not yet been set. It is
%			displayed at a time location of zero until a start marker
%			is set (and thus may well not be visible on the screen).
%			(Note that labels are not displayed in the organization
%			figure.)
%			Currently no special fonts (e.g phonetic) can be used in
%			the label.
%
%		set_type
%			Set marker type to a specific type. After giving this
%			command the user must enter a single digit (1 to 9)
%			specifying the marker type to use (thus restricted to
%			cases where no more than this range of markers is in
%			operation). This single digit specification is not
%			explicitly prompted for, and is not echoed. If it is
%			necessary to specify marker types outside this range,
%			then the underlying function mt_smark must be used
%			directly (e.g in a macro). See the function help for more
%			details.
%