"""
The aim of this script is to visualize the data stored in the SQLite db from sims

The questions that this script should answer are:
- list existing fields in the DB
- list unique values in each field
- count how many trials exist per triplet (duration, h, SNR)
- for fixed triplet, compute the average difference (across trials) between the posterior means
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
dbname = 'test_6.db'
tablename = 'feedback'
db = dataset.connect('sqlite:///' + dbname)
table = db[tablename]

# list existing fields in the table
print(table.columns)

# list unique values in each field
for field in table.columns:
    print('unique values from ' + field)
    for row in table.distinct(field):
        print('type', type(row[field]))
        print(row[field])
    print('-----------------------------------')
