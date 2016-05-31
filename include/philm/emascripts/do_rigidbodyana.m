%do_rigidbodyana

mypart='lab1';

doaddv=0; domakecut=0; dorig=1;

inpath='ampsadj\merge\rawpos\';
outpath=['mat\mca2_' mypart '_head_'];

triallist=1:121;
cutfile=['mca2_' mypart '_cut'];

refname='..\mca2_cv1_0125_refobj';

%head right not used, . This version also without ref
refsensors=str2mat('ref','v_ref','nose','v_nose','head_left','v_head_left');

[cutdata,cutlabel,agtrialnum,mttrialnum,trialnumS]=parselogfile('mca2_lab_ran_log_lab1_adj');

if doaddv
    %best to do this before setting up a references object?
    %add item_id and comment to input data
    addvariable2mat([inpath '0'],'item_id',cutlabel,triallist);
    addcommentfromfile([inpath '0'],'..\mca2_comment.txt',triallist);
end;


if dorig
    fixed_trafo=refname;
    refobj=fixed_trafo;
    rigidbodyname='headrig';
    rigidbodyana(inpath,outpath,triallist,fixed_trafo,refobj,refsensors,rigidbodyname);
end;

if domakecut
    %makecutfile can only be done after rigidbodyana has been done
    % (or base it on input files if no changes in trial numbers are to be made)
    makecutfile([outpath '0'],cutfile,triallist)
    valuelabel=mymatin(cutfile,'valuelabel');
    valuelabel.trial_number=trialnumS;
    addvariable2mat(cutfile,'valuelabel',valuelabel);
end;

