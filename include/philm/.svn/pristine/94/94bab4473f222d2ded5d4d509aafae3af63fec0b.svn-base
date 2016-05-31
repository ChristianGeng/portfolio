function prompter_restorefigpos
% function prompter_restorefigpos
% prompter_restorefigpos: Version 22.11.2012

P=prompter_gmaind;
filename=[P.function_name '_figpos'];
if exist([filename '.mat'],'file')
    fign=mymatin(filename,'figure_names');
    figp=mymatin(filename,'figure_positions');
    nf=size(fign,1);
    for ifi=1:nf
        hf=findobj('type','figure','name',deblank(fign(ifi,:)));
        if length(hf)==1
            try
                set(hf,'position',figp(ifi,:));
            catch
                disp(['Problem restoring position of figure ' int2str(hf)]);
                disp(lasterr);
            end;
            
        end;
    end;
    
drawnow;    
    
else
    disp('Note: No figure position file available');
end;
%could be useful for graphics settings that can't be done already in
%prompter_ini_base

prompter_evaluserfunc(P.userset2func,'set2');
