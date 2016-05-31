%do_renumber_trials

%renumber the trials after the system crashed
%it would probably have been better to do this right at the start of
%processsing

[cutdata,cutlabel,agtrialnum,mttrialnum,trialnumS]=parselogfile('french_s_all_ran_log_noel4_adj');
%watch out with leading zeros!! should try and automate
renumber_trials('noel4\ampsadj\merge\rawpos\00','noel2\ampsadj\from4\0',[agtrialnum mttrialnum]);

