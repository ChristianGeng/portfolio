# -*- coding: utf-8 -*-
"""
Created on Wed Aug 31 18:15:22 2016

@author: christian

https://regexone.com/references/python
http://www.regular-expressions.info/lookaround.html
http://www.regular-expressions.info/examples.html
https://regexone.com/problem/matching_html

hackerrank problem: 
https://www.hackerrank.com/challenges/detect-html-links

(1)
href=[\'"]?" :    "href=", mit otionnalem ' oder " 

(2)    
danach eine Gruppe in () - ausschneiden und separat zurueckgeben
[^\'" >]+ : in der eckigen Klammer ist "^" = DO NOT MATCH

(3)
[^>]* -      

quantifiers:
?   = exactly 1 or 0 der davor kommenden r.e.
+ ein oder mehrere der davor kommenden r.e

"""



    

        

def detect_html_links(data):
    import re
    
    
    myregex = """<a.*?href="(.*?)".*?>(.*?)<\/a>"""
    myregexc = re.compile(myregex)
    mymatches = myregexc.findall(data)
    for  mystr in mymatches:
        tagsremoved =    re.sub('<[^>]*>', '', mystr[1])     
        print   "%s,%s" % (mystr[0],tagsremoved.lstrip().rstrip())
    

if __name__ == '__main__':
    import sys
    
    data = sys.stdin.read()
    #data = '<a href="http://www.hackerrank.com"><h1><b>HackerRank</b></h1></a>'
    detect_html_links(data)
    
