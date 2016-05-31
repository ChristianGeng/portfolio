function prompter_resetagstatus;
% function prompter_resetagstatus;

AG=prompter_gagd;

statbuf=AG.statbuf;
hlstat=AG.linehandle;
nstat=size(statbuf,2);
statbuf(3,:)=statbuf(1,:);
statbuf(2,:)=logical(zeros(1,nstat));
set(hlstat(2),'xdata',ones(nstat,1)*NaN);
AG.statbuf=statbuf;
prompter_sagd(AG);

