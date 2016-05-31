% Recent updates to Phil's matlab functions
% ('type phil_m_all_updates' will give a more complete list of updates)

13.05.2011
tapad_ph_rs:
The options input argument has been substantially changed.
If running matlab with version 4.1 or later of the optimization toolbox
(check with the 'ver' command) it is no longer recommended to use the
'-l' switch to get the levenberg-marquardt algorithm.
Leaving the options argument empty will now result in matlab's default algorithm
being used, which is currently 'trust-region-reflective'. This seems to work at
least as well as levenberg-marquardt, and is much faster.
The preferred way to set options is now to set the values of fields
in a struct.
    e.g to get recursive mode:
        options.recursiveflag=1
    however, the old method
        options='-r'
    will continue to work.
The help window now displays the tapad and optimization options in force while the program
is running (and they are now also documented better in the output files).
The trust-region-reflective algorithm allows some new settings for constraining the 
solution space which may be useful in difficult cases.
See the tapad_ph_rs help for more details.

09.95.2011
makerefobjn:
This includes a new command 't' for allowing input from an existing ref object.
For example, a ref object can be defined based on an occlusion trial, and this
can then be used to provide the basic setting for a ref object based on a rest position trial.
