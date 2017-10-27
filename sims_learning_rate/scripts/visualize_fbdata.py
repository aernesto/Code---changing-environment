"""
The aim of this script is to visualize the data stored in the SQLite db from sims

The questions that this script should answer are:
1- list existing fields in the DB
2- list unique values in each field
3- count how many trials exist per triplet (duration, h, SNR)
4- for fixed triplet, compute the average difference (across trials) between the posterior means
    do the same for posterior stdev
5- find the top 10 triplets for which the differences from previous bullet are maximized
"""
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import rv_discrete
import scipy
import datetime
import dataset

# define dbname
dbname = 'true_1.db'
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
# result = db.query('SELECT trialDuration, hazardRate, SNR, COUNT(*) AS c \
# FROM feedback GROUP BY trialDuration, SNR, hazardRate')
# for row in result:
#     print('triplet:', row['trialDuration'], row['hazardRate'], row['SNR'])
#     print('count:', row['c'])
# print('-----------------------------------')


# 4- for fixed triplet, compute the average difference (across trials) between the posterior means
#     do the same for posterior stdev
result = db.query('SELECT trialDuration, hazardRate, SNR, \
AVG(meanFeedback - meanNoFeedback) AS meandiff, \
AVG(stdevFeedback - stdevNoFeedback) AS stdevdiff \
FROM feedback GROUP BY trialDuration, SNR, hazardRate')

'''
way to compute the variance
SELECT AVG((feedback.num - sub.average) * (feedback.num - sub.average)) as var from feedback, \
(SELECT name, AVG(feedback.num) AS average FROM feedback group by name) AS sub \
where feedback.name = sub.name group by sub.name
'''

# store results in numpy array
diffs = np.array([[row['trialDuration'],
                   row['hazardRate'],
                   row['SNR'],
                   row['meandiff'],
                   row['stdevdiff']] for row in result])

print('mean', np.mean(diffs[:, 3]))
print('max', np.max(diffs[:, 3]))
