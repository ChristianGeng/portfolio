# -*- coding: utf-8 -*-
"""
Purpose: python script Write raw tables to mysql database
Does NOT work under python 3.x (mysqldb connector not ported to python 3)
Data are fairly large so they are written chunkwise
Assumptions: 
+ mysql is set up correctly (in particular settings my.conf need to reflect that the matrices are in the GB range)
+ a DB called kddcup exists
+ permissions are set such that user has write access 

@author: christian

    # write outcomes to SQL DB
    # 36M     ../../kddcup2014/data/outcomes.csv
    # 218M    ../../kddcup2014/data/projects.csv
    # 561M    ../../kddcup2014/data/resources.csv
    # 810M    ../../kddcup2014/data/donations.csv
    # 1.3G    ../../kddcup2014/data/essays.csv
    # 1.5M    ../../kddcup2014/data/sampleSubmission.csv


https://betterexplained.com/articles/the-quick-guide-to-guids/
http://docs.sqlalchemy.org/en/latest/core/type_basics.html
file_dtype =  {'col1': str, 'col2': np.int32, 'col3': datetime} 
sql_dtype = {'col1': VARCHAR, 'col2': INTEGER, 'col3': TIMESTAMP} 
to_sql(TABLE, engine, dtype=sql_dtype, if_exists='append')

http://onthecode.com/post/2014/03/06/emacs-on-steroids-for-python-elpy-el.html


M-x realgud:pdf Enter python -m pdb <file.py> Entersa

"""
from __future__ import unicode_literals
import warnings
import codecs
import pdb; 
#pdb.set_trace()
import sys

import sys
import os
import pandas as pd
import MySQLdb as mdb
import uuid
import sqlalchemy
import datetime
from sqlalchemy import create_engine
from sqlalchemy import Column, DateTime, String, Integer, ForeignKey, func

HOST='localhost'
USER='christian'
PASS='christian'
DB='kddcup2014'

dataloc="../../kddcup2014/data/"
tableNames =["outcomes","projects","resources","donations","essays","sampleSubmission"]

# SQLAlchemy Engine
enginestring='mysql://'+USER+':'+PASS+'@'+HOST+':3306/'+DB
engine = create_engine(enginestring,echo=False)

def MySQLdropTable(table_name):
    """ drop an sql table """

    try:
        mycommand='''DROP TABLE table_name;'''
        mycommand = mycommand.replace('table_name',table_name)
        print(mycommand)
        MySQLCommand(mycommand)
    except Exception: 
        print("dropping failed ...")
        print (Exception)
        pass

def MySQLSelect2df(selectquery):
    """ 
    Wohl nich mehr benoetigt, jetzt wird sqlalchemy genutzt. 
    Usage: 
        import MySQLdb
        mysql_cn= MySQLdb.connect(host='myhost', 
                port=3306,user='myusername', passwd='mypassword', 
                db='information_schema')
                df_mysql = pd.read_sql('select * from VIEWS;', con=mysql_cn)    
                print 'loaded dataframe from MySQL. records:', len(df_mysql)
                mysql_cn.close()    

     get df from DT corpus using query string (MySQL)
    """
    
    try:        
        mysql_cn = mdb.connect(HOST, USER, PASS, DB)
        df_mysql = pd.read_sql(selectquery, con=mysql_cn)
        print 'loaded dataframe from MySQL. records:', len(df_mysql)
    except mdb.Error, e:
        print "MySQLSelect2df error: - exit"
        print "Error %d: %s" % (e.args[0],e.args[1])
        sys.exit(1)
    finally:
        mysql_cn.close()
    return df_mysql

def MySQLCommand(mystring):
    """
    SQL command ausfuehren
    """
    try:
        con = mdb.connect(HOST, USER, PASS, DB)
        cursor = con.cursor()     # get the cursor
        cursor.execute("USE "+DB) # select the database
        cursor.execute(mystring)
    except mdb.Error as e:
        print ("MySQLCommand error: - exiting")
        print ("Error %d: %s" % (e.args[0],e.args[1]))
    finally:    
        if con:
            con.close() 

def df2MySQL(tablename, aDataFrame):
    """ 
    write df to corpus, MySQL, nur fuer kleinere Tabellen
    """
    cn = mdb.connect(HOST, USER, PASS, DB)    
    try:              
        write_frame(aDataFrame, name=tablename, con=cn, flavor='mysql', if_exists='replace')
        #aDataFrame.to_sql(tablename, cn, flavor='mysql', schema=None, if_exists='replace')
        #df_mysql = read_db('select * from '+tablename, con=cn)    
        #print df_mysql
        #print 'loaded dataframe from mysql', len(df_mysql)
    except mdb.Error as e:
        print ("MySQLCommand error: - exit")
        print ("Error %d: %s" % (e.args[0],e.args[1]))
        sys.exit(1)
    finally:
        cn.close()

def setIDX(columns,tablename='<unnamed table>'):
    """ 
    einen Index generieren, Indizierung macht den Join schnell 
    Beispielsyntax: 
    CREATE INDEX idx_SyllableID  ON syllableconstituents(SyllableID);
    Notes: 
    - falls der key schon existiert, dann wird ein Fehler geworfen
    - Default für den Corpus: Generierter Index zeigt auf den uebergeordneten konsitutenten
    (durch column). self.name  ist der Konstituent, aus dem aufgerufen wird. 
    - man kann auch noch die Art index spezifizieren: 
    create index your_index_name on your_table_name(your_column_name) using HASH;
    - alternative syntax: 
    ALTER TABLE trials ADD INDEX (TrialID);
    SHOW INDEX FROM trials;        
    TODO:drittes Argument 'tablename' nicht getestet
    """
           
    print "setIDX in table "+tablename
    
    for column in columns:
        mystring="""
        CREATE INDEX idx_varname  ON tablename(varname);
        """
        mystring = mystring.replace('tablename',tablename).replace('varname',column)
        MySQLCommand(mystring)
        
        
def setPK(indexname,tablename='<unnamed table>'): 
    """ 
    set primary keys 
    indexname - welche Variable soll PK werden 
    tablename: In welcher Tabelle soll der index gesetzt werden
    """
        
    try:
        print "setting PK in table "+tablename
        mystring ="""
        ALTER TABLE `tablename`
        ALTER `idxidentifier` DROP DEFAULT,
        ADD PRIMARY KEY (`idxidentifier`);
        """
        mycommand = mystring.replace('tablename',tablename).replace('idxidentifier',indexname)
        MySQLCommand(mycommand)
    except Exception: 
        print (Exception)
        pass




def write_outcomes(chunksize=50000):
     """ 
     WRITE TABLE OUTCOMES
     """
     
     tableName="outcomes"
     print ("processing ", tableName)
     MySQLdropTable(tableName)

     midx = 0
     writeflag='replace'
     try:
         for chunk in pd.read_csv(dataloc+tableName+'.csv',sep=',', chunksize=50 , na_values=[" ","nan"],encoding = 'utf8'):
             if midx > 0: 
                 writeflag = 'append'
                 print("stop in second iteration")
                 break;

             midx=midx+1
             chunk=chunk.fillna(0)              # set missing to  zero,

             
             # treat bools
             d = {'t': True, 'f': False}
             
             boollist=['is_exciting','at_least_1_teacher_referred_donor', 'fully_funded','at_least_1_green_donation',
                       'great_chat', 'three_or_more_non_teacher_referred_donors' , 
                       'one_non_teacher_referred_donor_giving_100_plus', 'donation_from_thoughtful_donor']
             for x in boollist:
                 chunk[x]=chunk[x].map(d)
                 chunk[x]=chunk[x].astype(bool)


                 
            # dtype conversions
             dtypes={
                 'projectid': sqlalchemy.types.NVARCHAR(length=255), # sqlalchemy.types.Unicode(length=255) 
             }

             chunk.to_sql(tableName,con=engine, flavor='mysql', if_exists=writeflag,chunksize=chunksize,dtype=dtypes)
     except: 
        pass
        #sys.exc_info()[0]
        #write_to_page( "<p>Error: %s</p>" % e )        


     setIDX(['projectid'],tableName)
     setPK('projectid',tableName)


def write_donations(chunksize=50000):
    """ 
    WRITE TABLE DONORS
    """
    tableName="donations"
    print ("processing ", tableName)
    #MySQLdropTable(tableName)

    midx = 0
    writeflag='replace'

    try:
         for chunk in pd.read_csv(dataloc+tableName+'.csv',sep=',', chunksize=500, encoding = 'iso-8859-1'): # encoding = 'iso-8859-1' encoding = 'utf8' , 'iso-8859-1'
             
             print ("chunk  " , midx+1, " with size ", chunk.shape[0])
             if midx > 0: 
                 writeflag = 'append'
                 print("stop in second iteration")
                 break;
             midx=midx+1
             print chunk.shape

             #strs=['donationid','projectid', 'donor_acctid','donor_city','donor_state']
             #print strs


             #for idx in strs: 
             #    chunk[idx]=chunk[idx].apply(lambda x: unicode(x))
             
             # print chunk.dtypes
             # warnings.simplefilter('error')


             #body=unicode(body)
             #chunk=chunk.fillna(0)              # set missing to  zero,
             print chunk.shape
             print chunk.dtypes
             #print chunk['donation_timestamp']
             chunk['donation_timestamp'] = pd.to_datetime(chunk['donation_timestamp'])
             #print (chunk.donation_timestamp)
             #datetime.datetime.strptime('2012-03-01 14:47:48.969', "%Y-%m-%d %H:%M:%S.%f")
             #print ""
             # treat bools
             d = {'t': True, 'f': False}
             
             boollist=['donation_included_optional_support','payment_included_campaign_gift_card','payment_included_acct_credit',
                       'payment_included_web_purchased_gift_card','payment_was_promo_matched',
                       'via_giving_page','for_honoree']

             for x in boollist:
                 chunk[x]=chunk[x].map(d)
                 chunk[x]=chunk[x].astype(bool)

             usedtypes={
                'donation_timestamp' : sqlalchemy.DateTime,
                'projectid': sqlalchemy.types.NVARCHAR(length=255), # sqlalchemy.types.Unicode(length=255) 
                'donationid': sqlalchemy.types.NVARCHAR(length=255), 
                'donor_acctid': sqlalchemy.types.NVARCHAR(length=255)  #String(convert_unicode=True)

                # 'projectid': sqlalchemy.types.Unicode(length=255), 
                # 'donationid': sqlalchemy.types.Unicode(length=255), 
                # 'donor_acctid': sqlalchemy.types.Unicode(length=255)  

#                'projectid': String(convert_unicode=True),
#                'donationid': String(convert_unicode=True),
#                'donor_acctid': String(convert_unicode=True),


                 # convert_unicode=False
             }
             print(writeflag)
             chunk.to_sql(tableName,con=engine, flavor='mysql', if_exists=writeflag,chunksize=chunksize,dtype=usedtypes)
    except:
        e = sys.exc_info()[0]
        print( "Error: %s" % e )
        pass



    setIDX(['projectid','donationid','donor_acctid'],tableName)
    setPK('donationid',tableName)


def write_resources(chunksize=50000):
      tableName="resources"
      print ("processing ", tableName)
      MySQLdropTable(tableName)

      midx = 0
      writeflag='replace'
      try:
          for chunk in pd.read_csv(dataloc+tableName+'.csv',sep=',', chunksize=50, na_values=[" ","nan"],encoding = 'utf-8'):

              if midx > 0: 
                  writeflag = 'append'
                  print("stop in second iteration")
                  break;
              midx=midx+1

              chunk=chunk.fillna(0)              # set missing to  zero,



              usedtypes={
                  'resourceid': sqlalchemy.types.NVARCHAR(length=255), # sqlalchemy.types.Unicode(length=255) 
                  'projectid': sqlalchemy.types.NVARCHAR(length=255), 
                  'vendorid': sqlalchemy.types.NVARCHAR(length=255)  #String(convert_unicode=True)
              }
          print(writeflag)
          chunk.to_sql(tableName,con=engine, flavor='mysql', if_exists=writeflag,chunksize=chunksize,dtype=usedtypes)


      except:
         pass


      setIDX(['resourceid','projectid' ,'vendorid'],tableName)
      setPK('resourceid',tableName)
    

def write_projects(chunksize=50000):

     """
     WRITE TABLE PROJECTS
     
     enginestring='mysql://'+USER+':'+PASS+'@'+HOST+':3306/'+DB
     engine = create_engine(enginestring,echo=False)
     data = pandas.read_sql_table('projects', con=engine, chunksize=5000)
     pandas.DataFrame.to_sql
     if_exists : {‘fail’, ‘replace’, ‘append’}, default ‘fail’
     df2 = pd.read_csv('test', sep='\t', converters={'a': str})
    """

     tableName="projects"
     print ("processing ", tableName)
     MySQLdropTable(tableName)

     midx = 0
     writeflag='replace'
     try:
         for chunk in pd.read_csv(dataloc+tableName+'.csv',sep=',', chunksize=50, na_values=[" ","nan"],encoding='utf-8'):
        
             if midx > 0: 
                 writeflag = 'append'
                 print("stop in second iteration")
                 break;
             midx=midx+1

             chunk=chunk.fillna(0)              # set missing to  zero,
        
             # to uuids, die werden dann als char(36) abgespeichert und indiziert
             #chunk['projectid']=chunk['projectid'].apply(lambda x: uuid.UUID(unicode(x)))
             #chunk['teacher_acctid']=chunk['teacher_acctid'].apply(lambda x: uuid.UUID(unicode(x)))
             #chunk['schoolid']=chunk['schoolid'].apply(lambda x: uuid.UUID(unicode(x)))
             #chunk['teacher_acctid']=chunk['teacher_acctid'].apply(uuid.UUID)
             #chunk['schoolid']=chunk['schoolid'].apply(uuid.UUID)
             # oder als ints: 
             #chunk['projectid'] = chunk['projectid'].apply(lambda x: int(x,16))
             chunk.date_posted = pd.to_datetime(chunk.date_posted)              # convert date

             #datetime.datetime.strptime('2012-03-01 14:47:48.969', "%Y-%m-%d %H:%M:%S.%f")


             # treat ints
             intlist=['school_zip']
             for x in intlist:
                  chunk[x] = chunk[x].astype(int)
                        
            # map bools
             d = {'t': True, 'f': False}
             boollist=['school_charter','school_magnet',
                       'school_year_round','school_nlns','school_kipp',
                       'school_charter_ready_promise',
                       'teacher_teach_for_america','teacher_ny_teaching_fellow',
                       'eligible_double_your_impact_match','eligible_almost_home_match']
             for x in boollist:
                 chunk[x]=chunk[x].map(d)
                 chunk[x]=chunk[x].astype(bool)

             dtypes={
                 'date_posted' : sqlalchemy.DateTime,
                 'projectid': sqlalchemy.types.NVARCHAR(length=255), # sqlalchemy.types.Unicode(length=255) 
                 'teacher_acctid': sqlalchemy.types.NVARCHAR(length=255), 
                 'schoolid': sqlalchemy.types.NVARCHAR(length=255),  #String(convert_unicode=True)
                 # 'vendor_name' : sqlalchemy.types.Unicode(),
                 # 'project_resource_type' : sqlalchemy.types.Unicode(),
                 # 'item_name' : sqlalchemy.types.Unicode(),
                 # 'item_number' : sqlalchemy.types.Unicode(),
             }

             
             chunk.to_sql(tableName,con=engine, flavor='mysql', if_exists=writeflag,chunksize=chunksize,dtype=dtypes)
     except:
         pass



     setIDX(['projectid','teacher_acctid','schoolid','school_ncesid'],tableName)
     setPK('projectid',tableName)




if __name__=='__main__':

    #write_outcomes() # for table outcomes
    #write_projects() # for table projects
    write_donations()
    #write_resources()
    
