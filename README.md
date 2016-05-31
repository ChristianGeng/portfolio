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
 and indeed the quaternion respresentation can be obtained by doing so. 
 
 ## 
