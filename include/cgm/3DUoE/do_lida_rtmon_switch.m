function do_lida_rtmon_switch
% caller for rt display 


% recpath = '/ema/ema/ema/recordeddata/R0028_CGeng_23July2009/'
% recpath = '/ema/ema/ema/recordeddata/R0029_KRichmond_06Aug2009/'
% recpath = '/ema/ema/ema/recordeddata/R0031_ATurk_08Sep2009/'
% recpath = '/ema/ema/ema/recordeddata/R0032test/'
% recpath = '/ema/ema/ema/recordeddata/R0032_KRichmond_05Dec2009/'
% recpath = '/ema/ema/ema/recordeddata/speckletest1'
recpath='/ema/ema/ema/recordeddata/R0037_PierreBadinChristopheSavariaux_17June2010/'

cd (recpath)
lida_rtmon_switch(recpath)
