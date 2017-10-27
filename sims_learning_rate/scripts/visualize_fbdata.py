"""
The aim of this script is to visualize the data stored in the SQLite db from sims

The questions that this script should answer are:
1- list existing fields in the DB
2- list unique values in each field
3- count how many trials exist per triplet (duration, h, SNR)
4- for fixed triplet, compute the average difference (across trials) between the posterior means
    do the same for posterior stdev
- find the top 10 triplets for which the differences from previous bullet are maximized
"""
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import rv_discrete
import scipy
import datetime
import dataset

# define dbname
dbname = 'test_11.db'
tablename = 'feedback'
db = dataset.connect('sqlite:///' + dbname)
table = db[tablename]

# 1- list existing fields in the table
# print(table.columns)
#
# # 2- list unique values in each field
# for field in table.columns:
#     # print('unique values from ' + field)
#     for row in table.distinct(field):
#         # print('type', type(row[field]))
#         print(row[field])
#     print('-----------------------------------')

# 3- count how many trials exist per triplet (duration, h, SNR)
# print('unique values from ' + field)
# result = db.query('SELECT trialDuration, hazardRate, SNR, obsFeedback, COUNT(*) AS c \
# FROM feedback GROUP BY trialDuration, SNR, hazardRate, obsFeedback')
# for row in result:
#     print('quadruple:', row['trialDuration'], row['hazardRate'], row['SNR'], row['obsFeedback'])
#     print('count:', row['c'])
# print('-----------------------------------')


# 4- for fixed triplet, compute the average difference (across trials) between the posterior means
#     do the same for posterior stdev
result1 = db.query('SELECT ID, ')

'''
SELECT
    a.PurchaseID,
    ABS(a.PurchaseID - b.PurchaseID) AS diff
FROM
    PurchaseID a INNER JOIN PurchaseID b ON a.PurchaseID=b.PurchaseID
WHERE a.PurchaseID=?
    AND a.purchaseDate=?
    AND b.purchaseDate=?'''


result = db.query('SELECT trialDuration, hazardRate, SNR, obsFeedback, AVG() AS diff \
FROM feedback GROUP BY trialDuration, SNR, hazardRate, obsFeedback')
for row in result:
    print('quadruple:', row['trialDuration'], row['hazardRate'], row['SNR'], row['obsFeedback'])
    print('count:', row['c'])
