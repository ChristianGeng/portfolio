function prompter_commoncmd(mycmd)
% function prompter_commoncmd(mycmd)

if mycmd=='h' prompter_showhelp; end;
if mycmd=='a' prompter_autonext('start'); end;

if mycmd=='c' prompter_getcomment; end;



if mycmd=='q' prompter_quit; end;

if mycmd=='k' dummy; end;

if ((mycmd=='r') | (mycmd=='R')) prompter_repeat(mycmd); end;

if ((mycmd=='x') | (mycmd=='X')) prompter_mark(mycmd); end;

if mycmd=='s' prompter_mark2stack; end;
if mycmd=='S' prompter_showstack; end;

if mycmd=='t' prompter_settrialnumber; end;

if mycmd=='g' prompter_gotostim; end;

if ((mycmd=='m') | (mycmd=='M')) prompter_msg2sub(mycmd); end;

if mycmd=='d' prompter_trialduration; end;
