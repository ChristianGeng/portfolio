function make_sonix_probe_spec
% MAKE_SONIX_PROBE_SPEC Create mat file with Sonix probe specs
% function make_sonix_probe_spec
% make_sonix_probe_spec: Version 06.02.2013
%
%   Note
%       Uses probe names compatible with matlab field names (as returned by
%       sonix_ctrl('getpreset'))
%       Specs set up by hand here, with just the essential settings
%       but could be extended to process the probes.xml file automatically

functionname='make_sonix_probe_spec: Version 06.02.2013';
Probe.C9_5_10mm.name='C9-5/10';
Probe.C9_5_10mm.numElements=128;
Probe.C9_5_10mm.pitch=205;
Probe.C9_5_10mm.radius=10000;
Probe.C9_5_10mm.transmitoffset=0;

Probe.C7_3_50mm.name='C7-3/50';
Probe.C7_3_50mm.numElements=128;
Probe.C7_3_50mm.pitch=479;
Probe.C7_3_50mm.radius=50420;
Probe.C7_3_50mm.transmitoffset=0;


valuelabel.Probe.value=[19 21];
valuelabel.Probe.label=str2mat('C9_5_10mm','C7_3_50mm');

comment='Sonix probe specs. Use valuelabel to cross-reference probe name and numeric probe id.';
comment=[comment crlf 'pitch and radius are in micrometer'];
comment=framecomment(comment,functionname);

save('sonix_probe_specs','Probe','valuelabel','comment');
