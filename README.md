# Christian Geng



## Head Motion Correction 
Head Motion Correction for Electromagnetic Articulography removes contribution of head motion from measured articulatory motion. 
It comes in two versions. It implements papers by [Rohlf & Slice](include/RohlfSlice_1990.pdf) and [Horn](include/hornQuaternion.pdf)
that provide solutions to the problem of finding the best transformation matrices between two point clouds. 
The approaches arise from two very different backgrounds. 
The first paper calculates rotation matrices from the Singular Value Decomposition of the cross-product ot the 
two point clouds that need to be aligned, after finding centerings in a preprocessing step.
 The second is a quaterion-based approach. The matrix N at the bottom of page 635(sorry, no equation numbering in this paper)
 is subjected to an eigenvalue decompostition. The resuling quaternions carry the same information as the transformation matrix in the R&S paper,
 and indeed the quaternion respresentation can be obtained by doing so. The mathematical details can be seen in code [here](include/philm/3dnew/rota_ini.m),
 although it is part of a larger data processing pipeline, and therefore will not run per se. 
 
## Amplitude Demodulation

In EMA, induction coils around the head produce an electromagnetic field that induces a current in the sensors in the mouth. In order to 
get hold of these currents which are modulated onto carrier frequencies, demodulation has to be carried out in order to extract the original information-bearing signal from a modulated carrier wave.
Matlab is very good at quick stuff like data visualization and prototyping algorithms, but can be slow and needing a performance boost by replacing the slow portions 
with C code. The C Mex interface then manages data access. Implementation details are found in [this file](AmpDemod/gradDemodCpp/src/gradDemod.cpp). The code was developped under 
Linux and later generalized to also work under 32-bit windows.

Although a little outdated by the time of writing this, it also recapitulates how to [debug mex files on Eclipse](AmpDemod/gradDemodCpp/src/mexOnEclipseNotes.txt),
and therefore might be interesting for people aiming to do something similar. 




 
