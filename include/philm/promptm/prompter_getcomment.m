function prompter_getcomment
P=prompter_gmaind;

freecomment=philinp('Comment : ');
            
P.logtext_sup=[P.logtext_sup '%<' freecomment '>%' crlf];
prompter_smaind(P);
