%function pnet_putscript_relpath(ip,scriptname)

%pnet_remote(con,'PUTSCRIPT',scriptname);

scriptname='prompter_doubleEMAtcpip.m'
cs6ip='129.215.204.7';
concs6remote=pnet_remote('connect',cs6ip)
pnet_remote(concs6remote,'PUTSCRIPT',scriptname)
pause(0.5)
evalstring=['abspathname(''',scriptname,''')']


pnet_remote(concs6remote,'eval',evalstring)
pnet_remote('close',concs6remote)



%pnet_remote(con,'eval',evalstring);
