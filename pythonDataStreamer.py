# -*- coding: utf-8 -*-
"""
Created on Sun Jan 25 17:09:49 2015

@author: Raghav Saboo
"""

import pymysql.cursors
connection=pymysql.connect(
    host='67.159.81.86',user='student',
    passwd='bassconnex',db='energydata',
    cursorclass = pymysql.cursors.SSCursor)
cursor=connection.cursor()
cursor.execute("SELECT smarthome.timestamp,	smarthome.b7139_01_r_01_phase1 \
, smarthome.b7139_01_r_02_phase2 FROM energydata.smarthome \
ORDER BY smarthome.timestamp DESC")
for row in cursor:
    print(row)
cursor.close()
connection.close()