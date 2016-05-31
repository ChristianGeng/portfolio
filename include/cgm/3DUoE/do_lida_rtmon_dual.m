function do_lida_rtmon_dual
% Example call call for rt display 
% 
% 
%  See do_lida_rtmon_switch writedeflida 
%
%  $28-OCT-2009$
% CGeng
%


% recpath = '/ema/ema/ema/recordeddata/R0028_CGeng_23July2009/'
%recpath = '/ema/ema/ema/recordeddata/R0029_KRichmond_06Aug2009/'
% recpath = '/ema/ema/ema/recordeddata/R0031_ATurk_08Sep2009/'

%recpath = '/ema/ema/ema/recordeddata/R0032_JScobbieATurk_29Oct2009/'

%recpath = '/ema/ema/ema/recordeddata/intermachinecs5/'
% recpath = '/ema/ema/ema/recordeddata/R0033_JScobbieATurk_17Dec2009/'
% recpath = '/ema/ema/ema/recordeddata/R0034_JScobbieATurk_26Jan2010/'
% recpath = '/ema/ema/ema/recordeddata/R0035_JScobbieATurk_16Feb2010/'
recpath = '/ema/ema/ema/recordeddata/R0036_JScobbieATurk_35Mar2010/'



cd (recpath)
lida_rtmon_dual(recpath)

