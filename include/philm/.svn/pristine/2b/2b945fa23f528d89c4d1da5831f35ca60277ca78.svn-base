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

09.05.2011
makerefobjn:
This includes a new command 't' for allowing input from an existing ref object.
For example, a ref object can be defined based on an occlusion trial, and this
can then be used to provide the basic setting for a ref object based on a rest position trial.

29.03.2012
rigidbodyana and makerefobjn:
Extensive changes to the underlying functions rege_h and rota_ini that are 
used to compute the transformations.
Normally no changes should be necessary in how these functions are used.
But please report any unusual problems (and in that case also have a look at the help texts).
The way the average taxonomic distance in calculated in rigidbodyana has also been changed.
It will now give slightly smaller values.

17.10.2012
Major changes to show_trialox (one of the main functions used by do_do_comppos):
Choice of std or max-min for range display in statistics figure.
Either parameter 7 or tangential velocity or distance to desired sensor can be displayed
without having to read all the raw data again, i.e. in general generating displays with different
settings (or selection of channels) is much faster. 
See help text for details.
