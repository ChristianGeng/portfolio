        userdata of axis signal_axis
        retrieve with mt_gcsid. Set by mt_org and mt_ssig
        signal_list
        signalpath
        ref_trial
        unique_matname
        mat2signal
        max_sample_inc
        audio_channel
        
                      userdata of text object (tag=signalname) in signal_axis
                      
                      retrieve with mt_gsigv
                      set by mt_ssig and mt_loadt
                      
                      signal_name
           mat_name
           descriptor
           mat_column
           unit
           samplerate
           t0
           scalefactor
           signalzero
           signal_number
           dimension
           class_mat
           class_mem
           data_size
           
        
        userdata of cut_file_axis
                cutS=struct('filename',cutname,'data',cutdata,'label',cutlabel,'trial_label',triallabel);
        
        userdata of trial_axis
        retrieve with mt_gtrid
        set by mt_strid (esp. in mt_loadt)
        
        trialS=struct('number',0,'label','','cut_data',[],'cut_label','','signal_t0',[],'signal_tend',[]);

        children: line: boundaries of cuts in current trial
        				position of available data
        
        
        
        
        userdata of current_cut_axis
           
        %should marker data also be added to this structure???
        
        ccutS=struct('number',0,'data',[],'label','','sub_cut_data',[],'sub_cut_label','');
           
           
           
           
           
           
           figure mt_f(t)
           
           set up by mt_setft
           userdata
             myS=struct('signal_name',siglist,'axis_name',axislist,'panel_number',panellist);
