%pairs axes and sets up spatial and angular xy plots
%M> 
n
%Cut number [1]  * ISI, in word cut file
5
%M> 
t
%mt> 
d
%Time in s. [1]  *
2
%mt> 
q
%M> 
d
%md> 
t
%mdt> 
p
%this chooses all tip signals
%Choose left  axes (blank-separated list) ('?' for help) [AUDIO]  * 
%ll ref
ul
%Choose right axes (blank-separated list) ('?' for help) [AUDIO]  * 
%ul nas
ll
%Choose colours for left and right axes (blank separated; x=no change) ('?' for help) [x]  * 
%c y
x
%mdt> 
x
%Signal spec. ('?' for help) [AUDIO]  * 
%ul ll ref nas
ul ll jaw
r
r
%%%%%%%
%M> 
d
%md> 
x
%mdx> 
i
%Enter list of axes names as blank-separated list [xy]  * 
%the two axes have identical specs., but will be set for different views
%if doing angular plots, be careful to assign the x, y and z dimensions
% as in the mat files to the matlab x, y and z dimensions of the 3d plot
%i.e regardless of the internal names used for the signals
%otherwise there will be confusion when converting the phi and theta
%spherical coordinates to vectors in the 3d plot!!!
sagittal
%Subplot arrangement (2-element vector) [2  1]  * 
[1 1]
%mdx> 
a#sagittal#n#4#a#sagittal#traj#tb_ tm_ tt_ ul_ ll_ jaw_
%mdx> 
%mdx> 
x#sagittal#x#sig#y#lat
%mdx> 
x#sagittal#y#sig#y#a_p
%mdx> 
x#sagittal#z#sig#y#lon
%mdx> 
x#sagittal#c#time
%mdx> 
%mdx> 
%prevent points from being joined up
a#sagittal#contour_order#tb_ tm_ tt_ <line_break> ul_ <line_break> ll_ <line_break> jaw_
r
%md> 
r
v#mt_cuttype_ticktog
%v#mt_hextr(str2mat('ll_a_p','ll_lon','ll_lat'),2)
%v#mt_hextr(str2mat('ul_a_p','ul_lon','ul_lat'),2)
%v#mt_hextr(str2mat('tt_a_p','tt_lon','tt_lat'),2)
%v#mt_hextr(str2mat('ref_a_p','ref_lon','ref_lat'),2)
%v#mt_hextr(str2mat('nas_a_p','nas_lon','nas_lat'),2)
%v#mt_hextr(str2mat('t_phi','t_the','d_phi','d_the'),0.2)
%v#mt_hextr(str2mat('ll_ox','ll_oy','ll_oz','ul_ox','ul_oy','ul_oz'),0.2)
%v#mt_hextr(str2mat('tt_ox','tt_oy','tt_oz'),0.2)
%v#mt_hextr(str2mat('ref_ox','ref_oy','ref_oz','nas_ox','nas_oy','nas_oz'),0.2)

%v#mt_hextr(str2mat('ul_nit','ll_nit'),10)
%v#mt_hextr(str2mat('ul_ndi','ll_ndi'),10)
%v#mt_hextr(str2mat('ul_res','ll_res'),200)
%v#mt_hextr(str2mat('tt_nit'),10)
%v#mt_hextr(str2mat('tt_ndi'),10)
%v#mt_hextr(str2mat('tt_res'),200)

%v#mt_hextr(str2mat('ref_nit','nas_nit'),10)
%v#mt_hextr(str2mat('ref_ndi','nas_ndi'),10)
%v#mt_hextr(str2mat('ref_res','nas_res'),200)

%set up orientation plot
v#setvdall

%n.b the appropriate view also depends on relationship between world and graphic axes
v#mt_sxyv('sagittal',3)
%v#mt_sxyv('axial','xy')

v#mt_sxyl('sagittal','a_p',[-15 75])
%v#mt_sxyl('axial','a_p',[-2 2])
v#mt_sxyl('sagittal','lon',[-45 45])
%v#mt_sxyl('axial','lat',[-2 2])

%square xy axes
%v#axasp
s#X
v#mt_restorefigpos
%overrride default colour scheme for time signals
v#mt_setft(mt_gcsid('signal_list'),'stem',-3)
