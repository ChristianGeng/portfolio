function mtkmdt
% mtkmdt mt user commands main_display_time
persistent K
kname='mdt';
if isempty(K)
   myS=load('mt_skey',['k_' kname]);
   K=getfield(myS,['k_' kname]);
   clear myS;
   mlock;   
end;
[abint,abnoint,abscalar,abnoscalar]=abartdef;
clist='';
command=-1;

myS=mt_getft;
figh=mt_gfigh('mt_f(t)');
%oscillogram colours, taken from mt_setft
chancol='ymc';

while command~=K.return
   mystring=philinp([kname '> ']);
   if isempty(mystring)
      command=K.return;
   else
      command=abs(mystring(1));
   end;
   commandback=mtkcomm(command,K,'return');
   if commandback command=commandback; end;
   
   
   allsigs=mt_gcsid('signal_list');	%may need pruning to scalar signals   
   if command==K.initialize		%i.e reset display to all signals
      
      mt_setft;
   end;
   
   
   if command==K.choose_signals
      mylist=abartstr('Choose signals (blank-separated list)',myS.signal_name,allsigs,abnoscalar);
      
      mt_setft(mylist);
   end;
   
   if command==K.pair_axes
      collist=(['x' chancol])';
      mylistl=abartstr('Choose left  axes (blank-separated list)',deblank(myS.axis_name(1,:)),myS.axis_name,abnoscalar);
      mylistr=abartstr('Choose right axes (blank-separated list)',deblank(myS.axis_name(1,:)),myS.axis_name,abnoscalar);
      if size(mylistl,1)~=size(mylistr,1)
         disp ('Length of lists must match!');
      else
         
         mycol=abartstr('Choose colours for left and right axes (blank separated; x=no change)','x',collist,abnoscalar);
         vi=strmatch('x',mycol);         
         if ~isempty(vi) mycol='x';end;
         
         mt_sftlr(mylistl,mylistr,mycol);
      end;
   end;
   
   if command==K.cancel_pairing
      mt_sftlr;
   end;
   
   
   
   if command==K.sub_cut_control   
      myv=myS.sub_cut_flag;   
      myv=abart('Sub_cut control; 0=off, 1=all on, vector=selected on',myv,-1000,1000,abint,abnoscalar);
      disp(['New sub_cut setting: ' int2str(myv)]);
      myS.sub_cut_flag=myv;
      set(figh,'userdata',myS);
      
      
   end;
   
   
   if command==K.get_settings
      
      nn=size(myS.signal_name,1);
      bb=(blanks(nn))';
      disp('Signal names, axes names and panel numbers');
      disp([myS.signal_name bb myS.axis_name bb int2str(myS.panel_number)]);
   end;
   
         %Up Down and Extremes commands ============================
         
         ftaxes=mt_getft('axis_name');
         
         if isempty(clist) clist=deblank(ftaxes(1,:));end;  
         
         if command==K.up
            %get channel
            clist=abartstr ('Signal spec.',deblank(clist(1,:)),mt_getft('axis_name'),abnoscalar);
            mt_zoom2(clist,1);
         end
         if command==K.down
            %get channel
            clist=abartstr ('Signal spec.',deblank(clist(1,:)),mt_getft('axis_name'),abnoscalar);
            mt_zoom2(clist,-1);
         end
         if command==K.extremes
            %  get channel
            clist=abartstr ('Signal spec.',deblank(clist(1,:)),mt_getft('axis_name'),abnoscalar);
            ylimlist=mt_gextr(clist);
            for ie=1:size(clist,1)
               cl=clist(ie,:);
               disp (['f(t) axes ' cl]);
               ylimlist(ie,2)=abart ('Max',ylimlist(ie,2),-realmax,realmax,abnoint,abscalar);
               ylimlist(ie,1)=abart ('Min',ylimlist(ie,1),-realmax,ylimlist(ie,2)-(10*eps),abnoint,abscalar);
            end
            mt_sextr(clist,ylimlist);
         end
         
         if command==K.clipping
            %clipping mode
            %get channel
            clist=abartstr ('Signal spec.',deblank(clist(1,:)),mt_getft('axis_name'),abnoscalar);
            mt_sclip(clist);
            
         end
         
   
end;		%while not return
