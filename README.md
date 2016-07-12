# Christian Geng

## Hyperparameter Optimization

The adjustment of the many parameters of an algorithm in machine learning is a hard problem. Besides brute force methods, more elegant solutions have gained popularity that fuel hopes to find optimal hyperparameters quicker. My interest in these approaches has been stimulated by end-to-end systems like [Deep Feature synthesis](https://groups.csail.mit.edu/EVO-DesignOpt/groupWebSite/uploads/Site/DSAA_DSM_2015.pdf) 
This is a blog-like exploration of tuning hyperparameters in machine learning as an [ipython notebook](hyperparamsOptimization/tuneHyperPrams.ipynb). A worked example uses hyperopt, and particular care was taken to demo the use of a custom objective function which is easy when using the python package hyperopt.


## Amplitude Demodulation

In EMA, induction coils around the head produce an electromagnetic field that induces a current in the sensors in the mouth. In order to 
get hold of these currents which are modulated onto carrier frequencies, demodulation has to be carried out in order to extract the original information-bearing signal from a modulated carrier wave.
Matlab is very good at quick stuff like data visualization and prototyping algorithms, but can be slow and needing a performance boost by replacing the slow portions 
with C code. The C Mex interface then manages data access. Implementation details are found in [this file](AmpDemod/gradDemodCpp/src/gradDemod.cpp). The code was developped under 
Linux and later generalized to also work under 32-bit windows.

Although a little outdated by the time of writing this, it also recapitulates how to [debug mex files on Eclipse](AmpDemod/gradDemodCpp/src/mexOnEclipseNotes.txt),
and therefore might be interesting for people aiming to do something similar. 


## Head Motion Correction 
Head Motion Correction for Electromagnetic Articulography removes contribution of head motion from measured articulatory motion. 
It comes in two versions. It implements papers by [Rohlf & Slice](include/RohlfSlice_1990.pdf) and [Horn](include/hornQuaternion.pdf)
that provide solutions to the problem of finding the best transformation matrices between two point clouds. 
The approaches arise from two very different backgrounds. 
The first paper calculates rotation matrices from the Singular Value Decomposition of the cross-product ot the 
two point clouds that need to be aligned, after finding centerings in a preprocessing step.
 The second is a quaterion-based approach. The matrix N at the bottom of page 635(sorry, no equation numbering in this paper)
 is subjected to an eigenvalue decompostition. The resuling quaternions carry the same information as the transformation matrix in the R&S paper. This has been confirmed. The mathematical details can be made clear by looking at the code [here](include/philm/3dnew/rota_ini.m), although it is part of a larger data processing pipeline, and therefore will not run per se. 


## Tools for Mass-Spectrographic Data

Speech formant extraction and the identification in mass spectra share some similarities. In order to understand these better and in an attempt to make technology from medicinal chemistry productive in speech, I have written a quick and dirty sketch of a mass-spec toolbox. This (Readme)[https://github.com/ChristianGeng/MStools/blob/master/README.md] is the most useful entry point to that piece of work. 

## Real Time Display for two motion trackers in parallel

For monitoring data quality during experimental conduct exists this dual EMA RT monitor. 
It queries the devices TCP Real Time Stream of Online calculated positions, and visualizes these positions on the computer screen. This gives you evidence whether motion tracking works right. The code is a mess, but might be useful for those who wish to study Matlab callbacks. Find it [here](include/cgm/3DUoE/lida_rtmon_dual.m).

## Misc. 
These are miscellaneous tools, aiming at demonstrating exposure to various other topics

### Processing - Pandas Python

Some tools simply packaging some often used routines to munge pandas dataframes. I use them as a quick and dirty way to [munge data.](https://github.com/ChristianGeng/python-tools/blob/master/dfMassage.py). 

### Shell Scripts 
Bash tools in cglib, my collection of [bash functions](https://github.com/ChristianGeng/bashscripts/blob/master/cglib)

### Database

I have done mainly MySQL. I have been involved in generating a linguistic database of a speech corpus of interlocutors in situated dialoge. My first attempt to model linguistic structure was to use a [relational sheme](https://github.com/ChristianGeng/portfolio/blob/master/misc/dtsketch.pdf) using MySQLWorkbench. 
Nowadays, I am not so convinced any more that a relational model is ideal for this kind of data. 

