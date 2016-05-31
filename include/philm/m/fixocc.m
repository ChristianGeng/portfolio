% FIXOCC Set up occlusal plane file

parameternames=descriptor;
strg2var;
occtmp=data(:,[occlfrontX_xo occlfrontY_xo occlbackX_xo occlbackY_xo]);
disp(occtmp)
data=[occtmp(2,1:2);occtmp(2,3:4)];
disp(data)
unit=['cm';'cm'];
descriptor=['X';'Y'];
label=['front';'back '];
comment='data from second occlusal plane trial';
save occlnew data descriptor unit label comment;
