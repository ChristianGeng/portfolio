function prompter_quit
% function prompter_quit

P=prompter_gmaind;
P.finished=1;
P.istim=P.nstim;        %should not be necessary
prompter_showmsg(P.endmsg);
htinfo=P.infohandle;
set(htinfo(2),'string','');

prompter_smaind(P);

prompter_flushlogtext;
