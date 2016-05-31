# -*- coding: utf-8 -*-
"""
https://www.kaggle.com/bobcz3/prudential-life-insurance-assessment/neural-network-example/code

mkdir ~/.virtualenvs
virtualenv --system-site-packages cgML
pip install --ignore-installed pandas
workon cgML
deactivate

Interesting parameters
https://github.com/scikit-learn/scikit-learn/issues/2889

"""


import pandas as pd
import dfMassage
from dfMassage import *
import os
import pandas as pd
import scipy
import dfMassage
from dfMassage import *
from pylab import *
# Import modules following official guidelines:
import numpy as np
import matplotlib.pyplot as plt  #analysis:ignore
from sklearn.cross_validation import train_test_split
import   matplotlib as mpl
import ml_metrics

def getscore(y,ypred):
    return  ml_metrics.quadratic_weighted_kappa(y,ypred)

def getdataXGBoostStyle(dropMedhist1=False,BMI_Age=False,SumMedicalKeywords=True, recpath='/D/myfiles/2016/kagglePrudendial/'):
    # global variables
    columns_to_drop = ['Id', 'Response','Product_Info_2']
    columns_to_drop_realtwo=['Medical_History_10','Medical_History_24']
        
    print("Load the data using pandas")
    train = pd.read_csv(recpath+"/input/train.csv")
    test = pd.read_csv(recpath+"/input/test.csv")
    myid=test["Id"].values
    # combine train and test
    all_data = train.append(test)
    
    
    all_data = all_data.drop(columns_to_drop_realtwo, axis=1)
    
    # create any new variables    
    all_data['Product_Info_2_char'] = all_data.Product_Info_2.str[1]
    all_data['Product_Info_2_num'] = all_data.Product_Info_2.str[2]

    # factorize categorical variables
    all_data['Product_Info_2'] = pd.factorize(all_data['Product_Info_2'])[0]
    all_data['Product_Info_2_char'] = pd.factorize(all_data['Product_Info_2_char'])[0]
    all_data['Product_Info_2_num'] = pd.factorize(all_data['Product_Info_2_num'])[0]
    
    
    print('Eliminate missing values')    
    # Use -1 for any others
    all_data.fillna(-1, inplace=True)
    
    # fix the dtype on the label column
    all_data['Response'] = all_data['Response'].astype(int)
    
    # Provide split column
    all_data['Split'] = np.random.randint(5, size=all_data.shape[0])

    if dropMedhist1:
        all_data.drop(labels = 'Medical_History_1', axis = 1, inplace = True)

    if BMI_Age: 
        all_data['BMI_Age'] = all_data['BMI'] * all_data['Ins_Age']

    if SumMedicalKeywords:
        all_data.insert(0,'SumMedicalKeywords',all_data[all_data.columns[all_data.columns.str.contains('Medical_Keyword')]].sum(axis=1, skipna=True))
        all_data.insert(0,'SumEmploymentInfo',all_data[all_data.columns[all_data.columns.str.contains('InsuredInfo')]].sum(axis=1, skipna=True))
        all_data.insert(0,'SumMedicalHistory',all_data[all_data.columns[all_data.columns.str.contains('Medical_History')]].sum(axis=1, skipna=True))
        
        
    
    all_data['devfeature1'] = all_data['BMI'] * all_data['SumMedicalHistory']   
    all_data['devfeature2'] = all_data['BMI'] * all_data['SumMedicalKeywords']  
    
    #all_data['devfeature1'] = all_data['BMI'] * all_data['SumMedicalHistory']  
        
    # split train and test
    train = all_data[all_data['Response']>0].copy()
    test = all_data[all_data['Response']<1].copy()
    
    
    resp=train['Response'].values
    train = train.drop(columns_to_drop, axis=1)
    train['Response']=resp
    
    resp=test['Response'].values
    test = test.drop(columns_to_drop, axis=1)
    test['Response']=resp
    
    
    
    
    return train,test,myid



def makesubmission(ofname,predictions):        
    #print ("")
    #submissiondir = "/D/myfiles/2016/kagglePrudendial/submissions/"

    print ("submitting best estimator ", ofname)
    submission = pd.read_csv('../input/sample_submission.csv')
    submission["Response"] = predictions
    submission.to_csv(ofname, index=False)

def make_dataset_ORI(useDummies = True, fillNANStrategy = "mean", useNormalization = True):
    data_dir = "../input/"
    train = pd.read_csv(data_dir + 'train.csv')
    test = pd.read_csv(data_dir + 'test.csv')
    
    labels = train["Response"]
    train.drop(labels = "Id", axis = 1, inplace = True)
    train.drop(labels = "Response", axis = 1, inplace = True)
    test.drop(labels = "Id", axis = 1, inplace = True)
    
    categoricalVariables = ["Product_Info_1", "Product_Info_2", "Product_Info_3", "Product_Info_5", "Product_Info_6", "Product_Info_7", "Employment_Info_2", "Employment_Info_3", "Employment_Info_5", "InsuredInfo_1", "InsuredInfo_2", "InsuredInfo_3", "InsuredInfo_4", "InsuredInfo_5", "InsuredInfo_6", "InsuredInfo_7", "Insurance_History_1", "Insurance_History_2", "Insurance_History_3", "Insurance_History_4", "Insurance_History_7", "Insurance_History_8", "Insurance_History_9", "Family_Hist_1", "Medical_History_2", "Medical_History_3", "Medical_History_4", "Medical_History_5", "Medical_History_6", "Medical_History_7", "Medical_History_8", "Medical_History_9", "Medical_History_10", "Medical_History_11", "Medical_History_12", "Medical_History_13", "Medical_History_14", "Medical_History_16", "Medical_History_17", "Medical_History_18", "Medical_History_19", "Medical_History_20", "Medical_History_21", "Medical_History_22", "Medical_History_23", "Medical_History_25", "Medical_History_26", "Medical_History_27", "Medical_History_28", "Medical_History_29", "Medical_History_30", "Medical_History_31", "Medical_History_33", "Medical_History_34", "Medical_History_35", "Medical_History_36", "Medical_History_37", "Medical_History_38", "Medical_History_39", "Medical_History_40", "Medical_History_41"]

    if useDummies == True:
        print ("Generating dummies...")
        train, test = getDummiesInplace(categoricalVariables, train, test)
    
    if fillNANStrategy is not None:
        print ("Filling in missing values...")
        train = pdFillNAN(train, fillNANStrategy)
        test = pdFillNAN(test, fillNANStrategy)

    if useNormalization == True:
        print ("Scaling...")
        scaler = pdStandardScaler()
        train = scaler.fit_transform(train)
        test = scaler.transform(test)
    
    return train, test, labels



""" NN DATA SET with maybe some modifications """
def make_dataset_MOD(useDummies = True, fillNANStrategy = "mean", useNormalization = True, ):
    data_dir = "../input/"
    train = pd.read_csv(data_dir + 'train.csv')
    test = pd.read_csv(data_dir + 'test.csv')
    
    labels = train["Response"]
    train.drop(labels = "Id", axis = 1, inplace = True)
    train.drop(labels = "Response", axis = 1, inplace = True)
    test.drop(labels = "Id", axis = 1, inplace = True)
    
        
    
    """ modified  by me - """
    categoricalVariables = ['Product_Info_1','Product_Info_2','Product_Info_3','Product_Info_5','Product_Info_6','Product_Info_7','Employment_Info_2','Employment_Info_3','Employment_Info_5','InsuredInfo_1','InsuredInfo_2','InsuredInfo_3','InsuredInfo_4','InsuredInfo_5','InsuredInfo_6','InsuredInfo_7','Insurance_History_1','Insurance_History_2','Insurance_History_3','Insurance_History_4','Insurance_History_7','Insurance_History_8','Insurance_History_9','Family_Hist_1','Medical_History_2','Medical_History_3','Medical_History_4','Medical_History_5','Medical_History_6','Medical_History_7','Medical_History_8','Medical_History_9','Medical_History_11','Medical_History_12','Medical_History_13','Medical_History_14','Medical_History_16','Medical_History_17','Medical_History_18','Medical_History_19','Medical_History_20','Medical_History_21','Medical_History_22','Medical_History_23','Medical_History_25','Medical_History_26','Medical_History_27','Medical_History_28','Medical_History_29','Medical_History_30','Medical_History_31','Medical_History_33','Medical_History_34','Medical_History_35','Medical_History_36','Medical_History_37','Medical_History_38','Medical_History_39','Medical_History_40', 'Medical_History_41']
    """ original FROM NN """
    #categoricalVariables = ["Product_Info_1", "Product_Info_2", "Product_Info_3", "Product_Info_5", "Product_Info_6", "Product_Info_7", "Employment_Info_2", "Employment_Info_3", "Employment_Info_5", "InsuredInfo_1", "InsuredInfo_2", "InsuredInfo_3", "InsuredInfo_4", "InsuredInfo_5", "InsuredInfo_6", "InsuredInfo_7", "Insurance_History_1", "Insurance_History_2", "Insurance_History_3", "Insurance_History_4", "Insurance_History_7", "Insurance_History_8", "Insurance_History_9", "Family_Hist_1", "Medical_History_2", "Medical_History_3", "Medical_History_4", "Medical_History_5", "Medical_History_6", "Medical_History_7", "Medical_History_8", "Medical_History_9", "Medical_History_10", "Medical_History_11", "Medical_History_12", "Medical_History_13", "Medical_History_14", "Medical_History_16", "Medical_History_17", "Medical_History_18", "Medical_History_19", "Medical_History_20", "Medical_History_21", "Medical_History_22", "Medical_History_23", "Medical_History_25", "Medical_History_26", "Medical_History_27", "Medical_History_28", "Medical_History_29", "Medical_History_30", "Medical_History_31", "Medical_History_33", "Medical_History_34", "Medical_History_35", "Medical_History_36", "Medical_History_37", "Medical_History_38", "Medical_History_39", "Medical_History_40", "Medical_History_41"]

    if useDummies == True:
        print ("Generating dummies...")
        train, test = getDummiesInplace(categoricalVariables, train, test)
    
    if fillNANStrategy is not None:
        print ("Filling in missing values...")
        train = pdFillNAN(train, fillNANStrategy)
        test = pdFillNAN(test, fillNANStrategy)

    if useNormalization == True:
        print ("Scaling...")
        scaler = pdStandardScaler()
        train = scaler.fit_transform(train)
        test = scaler.transform(test)
    
    
    print ('train data shape seen by modeling is ' , train.shape)
    print ('test  data shape seen by modeling is ' , test.shape)
    return train, test, labels

print ("Creating dataset...") 





def make_dataset_dfMassage(useNormalization =True, subsamplefac=None,dropMedhist1=True):
    """
    using dfMassage
    """
   

    print ('scratchs cleandata')
    #os.chdir('/D/myfiles/2016/kagglePrudendial/')
    
    categoricalVariables = ['Product_Info_1','Product_Info_2','Product_Info_3','Product_Info_5','Product_Info_6','Product_Info_7','Employment_Info_2','Employment_Info_3','Employment_Info_5','InsuredInfo_1','InsuredInfo_2','InsuredInfo_3','InsuredInfo_4','InsuredInfo_5','InsuredInfo_6','InsuredInfo_7','Insurance_History_1','Insurance_History_2','Insurance_History_3','Insurance_History_4','Insurance_History_7','Insurance_History_8','Insurance_History_9','Family_Hist_1','Medical_History_2','Medical_History_3','Medical_History_4','Medical_History_5','Medical_History_6','Medical_History_7','Medical_History_8','Medical_History_9','Medical_History_11','Medical_History_12','Medical_History_13','Medical_History_14','Medical_History_16','Medical_History_17','Medical_History_18','Medical_History_19','Medical_History_20','Medical_History_21','Medical_History_22','Medical_History_23','Medical_History_25','Medical_History_26','Medical_History_27','Medical_History_28','Medical_History_29','Medical_History_30','Medical_History_31','Medical_History_33','Medical_History_34','Medical_History_35','Medical_History_36','Medical_History_37','Medical_History_38','Medical_History_39','Medical_History_40', 'Medical_History_41']
    contVariables = ['Product_Info_4','Ins_Age','Ht','Wt','BMI','Employment_Info_1','Employment_Info_4','Employment_Info_6','Insurance_History_5','Family_Hist_2','Family_Hist_3','Family_Hist_4','Family_Hist_5']
    discreteVariables = ['Medical_History_1','Medical_History_10','Medical_History_15','Medical_History_24','Medical_History_32']
    dummyvarlist = ['Medical_Keyword_'+str(x) for x in range(48 + 1)[1:]]

    data_dir = "../input/"
    X_train = pd.read_csv(data_dir + 'train.csv')
    X_test = pd.read_csv(data_dir + 'test.csv')

    if subsamplefac is not None:
        """ subsample for evaluation purposes """    
        print ("subsampling")
        X_train=subsampledf(X_train,subsamplefac) 


    """ remove outliers in cont variables - affects rows """    
    X_train = outliersout(X_train,contVariables) #
    
    
    """ drop variables with too many missing """
    #res= percentageNaN(X_train)
    #droplistMissing = res[res>70].index.tolist()    
    #X_train = X_train.drop(labels=droplistMissing , inplace=True, axis=0)
    #droplistMissing = res[res>70].index.tolist()    
    #X_test = X_train.drop(labels=droplistMissing , inplace=True, axis=0)
    
    


    """ drop garbage variables """
    Id_train = X_train.Id
    Id_test = X_test.Id    
    X_train.drop(labels = "Id", axis = 1, inplace = True)
    X_test.drop(labels = "Id", axis = 1, inplace = True)
    """ get dependent """
    y_train = splitcols(X_train,['Response'])
    #y_train = np.array(y_train).ravel()

    if dropMedhist1:
        X_train.drop(labels = 'Medical_History_1', axis = 1, inplace = True)
        X_test.drop(labels = 'Medical_History_1', axis = 1, inplace = True)
        

    X_train['BMI_Age'] = X_train['BMI'] * X_train['Ins_Age']
    X_test['BMI_Age'] = X_test['BMI'] * X_test['Ins_Age']
    
    
    
    
    print ("debugging")
        
    
    #decimateMissing=False
    #if decimateMissing:
    #missing = countmissing(X_train)
    #missing = countmissing(X_test)
    #print valuecounts(X_train,['Medical_Keyword_43','Medical_Keyword_42'])
    #df[(np.abs(stats.zscore(df)) < 3).all(axis=1)]
        
    """ try to drop missing here"""
    #X_train.drop(droplistMissing, axis=1, inplace=True)
    #X_test.drop(droplistMissing, axis=1, inplace=True) 

    """  dummy encoding """
    X_train, X_test = getDummiesInplace(categoricalVariables, X_train, X_test)

    """ impute means """
    fillNANStrategy = "mean"
    X_train = pdFillNAN(X_train, fillNANStrategy)
    X_test = pdFillNAN(X_test, fillNANStrategy)





    #print ('shape of data: ',X_train.shape[1])        tra
    #nearZeroVar =  nzvKJ(X_test,X_test.columns,freqCut = 20.)
    #varlist = nearZeroVar[nearZeroVar['nzv']].index.tolist()
    #print ('keeping ',X_train.shape[1] - len(varlist), " variables")
    #X_train.drop(varlist, axis=1, inplace=True);X_test.drop(varlist, axis=1, inplace=True) 
    #print ('shape of data: ',X_train.shape[1]) 


    """ Scaling/preprocessing """ 
    print ("Scaling...")
    scaler = pdStandardScaler()
    X_train = scaler.fit_transform(X_train)
    X_test = scaler.transform(X_test)
    

    """ near zero var thresholding """
    nzv=nzvThresh(X_train,X_train.columns,thresh=0)
    nzvlist = nzv[nzv['nzv']].index.tolist()
    #print nzv
    X_train.drop(nzvlist, axis=1, inplace=True)
    X_test.drop(nzvlist, axis=1, inplace=True)


    print ("finished making data, reporting shape: ")
    print ('train data shape seen by modeling is ' , X_train.shape)
    print ('test  data shape seen by modeling is ' , X_test.shape)
    print ('y_train shape seen by modeling is ' , y_train.shape) # should be pandas series

    return X_train,X_test,y_train





def makesklldata(dosubsample=14):

    #train, test, labels = make_dataset_ORI(useDummies = True, fillNANStrategy = "mean", useNormalization = True)
    #train, test, labels = make_dataset_MOD(useDummies = True, fillNANStrategy = "mean", useNormalization = True)
    
    print ("this is going to subsample: " , dosubsample)
    #dosubsample=14
    train, test, labels = make_dataset_dfMassage(useNormalization =True,subsamplefac=dosubsample,dropMedhist1=True)
    train['Response']=np.array(labels).ravel()
    infix=""
    if dosubsample is not None: infix="-short"
    train, dev = makeskllDirs('/D/myfiles/2016/kagglePrudendial/sklldata-0.01'+ infix+'/',train,test,0.2,42) 
    

    return 0

     

def applyoffsetcorrection(train_preds,test_preds,trainresp):
    """
    note: testresp ist immer -1!
    trainresp ist die integer response in den training data
    
    """
    from scipy.optimize import fmin_powell
    from ml_metrics import quadratic_weighted_kappa
    from pprint import  pprint as pp
    num_classes = 8
    def eval_wrapper(yhat, y):  
        y = np.array(y)
        y = y.astype(int)
        yhat = np.array(yhat)
        yhat = np.clip(np.round(yhat), np.min(y), np.max(y)).astype(int)   
        return quadratic_weighted_kappa(yhat, y)
    
    def apply_offset(data, bin_offset, sv, scorer=eval_wrapper):
        # data has the format of pred=0, offset_pred=1, labels=2 in the first dim
        data[1, data[0].astype(int)==sv] = data[0, data[0].astype(int)==sv] + bin_offset
        score = scorer(data[1], data[2])
        return score
    # train offsets 


    #offsets = np.array([0.1, -1, -2, -1, -0.8, 0.02, 0.8, 1])
    #offsets = np.ones(num_classes) * -0.5
    offsets = np.array([0.1, -1, -2, -1, -0.8, 0.02, 0.8, 1])
    #offsets = np.array([0.1, -1, -2, -1, -0.8, 0.02, 0.8, 1])
    offset_train_preds = np.vstack((train_preds, train_preds, trainresp)) # train['Response'].values
    
    for j in range(num_classes):
        train_offset = lambda x: -apply_offset(offset_train_preds, x, j)
        offsets[j] = fmin_powell(train_offset, offsets[j])  
        print ("offset" ,offsets[j])
    
    #print (train_preds)
    #print (np.shape(train_preds))
    #print (offset_train_preds)
    
    # apply offsets to test
    data = np.vstack((test_preds, test_preds, np.ones(len(test_preds))*-1)) #test['Response'].values
    for j in range(num_classes):
        data[1, data[0].astype(int)==j] = data[0, data[0].astype(int)==j] + offsets[j] 
    
    #pp(offsets)
    #print (data.head)
    rawpreds = data[1]
    final_test_preds = np.round(np.clip(data[1], 1, 8)).astype(int)
    return final_test_preds, rawpreds,offset_train_preds





if __name__ == '__main__':
    #X_train,X_test,y_train = cleandata()
    #makeDevDirs('/D/myfiles/2016/kagglePrudendia1l/sklldata/',X_train,y_train,X_test,0.2,42)
    makesklldata(dosubsample=None)
    makesklldata(dosubsample=4)
    


    # studyDir="/D/myfiles/2016/kagglePrudendial/sklldata-decimatedtest"
    # X = pd.read_csv(studyDir+'/train/X.csv')
    # y = pd.read_csv(studyDir+'/train/y.csv')
    # expFrame = pd.concat((X,y),axis=1)
    # print (test.info())

    # print ("aa")
    # print (X.shape)
    # print(y.shape)
    # print (expFrame.shape)
    # of=studyDir+'/train/Experiment.csv'
    # expFrame.to_csv(of, sep=',', header=True, index=False)

