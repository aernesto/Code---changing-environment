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
dbname = 'true_2.db'
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
result0 = db.query('SELECT trialDuration, hazardRate, SNR, COUNT(*) AS c \
FROM feedback GROUP BY trialDuration, SNR, hazardRate')
array_size = 0
for row in result0:
    array_size += 1
#     print('triplet:', row['trialDuration'], row['hazardRate'], row['SNR'])
#     print('count:', row['c'])
# print('-----------------------------------')


# 4- for fixed triplet, compute the average difference (across trials) between the posterior means
#     do the same for posterior stdev
result1 = db.query('SELECT trialDuration, hazardRate, SNR, '
                   '(meanFeedback - meanNoFeedback) as meandiff, '
                   '(stdevFeedback - stdevNoFeedback) as stdevdiff '
                   'FROM feedback GROUP BY trialDuration, SNR, hazardRate')

# store results in numpy array
'''
column0: trialDuration
column1: hazardRate
column2: SNR
column3: difference of means, averaged across trials
column4: difference of stdev, averaged across trials
column5: standard deviation of the difference of means
column6: standard deviation of the difference of stdev
column7: Coefficient of variation for abs(difference of means)
column8: Coefficient of variation for abs(difference of stdev)
column9: sample size

====
Recall formula for running average
(https://stackoverflow.com/questions/28820904/how-to-efficiently-compute-average-on-the-fly-moving-average)

n=1;
curAvg = 0;
loop{
  curAvg = curAvg + (newNum - curAvg)/n;
  n++;
}

====
Recall formula for running variance 
(https://www.johndcook.com/blog/standard_deviation/)

Initialize M1 = x1 and S1 = 0.

For subsequent x‘s, use the recurrence formulas

Mk = Mk-1+ (xk – Mk-1)/k               -- this is exactly the running average
Sk = Sk-1 + (xk – Mk-1)*(xk – Mk).

For 2 ≤ k ≤ n, the kth estimate of the variance is s2 = Sk/(k – 1).

'''
array_results = np.zeros((array_size, 10))
array_row = -1
counter = 0
lasttriplet = (0, 0, 0)
nsamples = 1
run_meandiff_avg, run_meandiff_var, run_stdevdiff_avg, run_stdevdiff_var = (0, 0, 0, 0)
run_absmeandiff_avg, run_absmeandiff_var, run_absstdevdiff_avg, run_absstdevdiff_var = (0, 0, 0, 0)
for row in result1:
    newtriplet = (int(row['trialDuration']), round(row['hazardRate'], 3), round(row['SNR'], 3))
    if newtriplet != lasttriplet:
        if nsamples > 1:
            coef = nsamples - 1
            # compute CVs to store
            std_absmeandiff = np.sqrt(run_meandiff_var / coef)
            CV_meandiff = std_absmeandiff / run_absmeandiff_avg
            std_absstdevdiff = np.sqrt(run_stdevdiff_var / coef)
            CV_stdevdiff = std_absstdevdiff / run_absstdevdiff_avg

            # store
            array_results[array_row, 3:10] = (run_meandiff_avg,
                                              run_stdevdiff_avg,
                                              np.sqrt(run_meandiff_var / coef),
                                              np.sqrt(run_stdevdiff_var / coef),
                                              CV_meandiff,
                                              CV_stdevdiff,
                                              nsamples)

        nsamples = 1
        array_row += 1
        # fill in first 3 columns
        array_results[array_row, 0:3] = newtriplet

    # compute running averages
    mean_aux_diff = row['meandiff'] - run_meandiff_avg
    var_aux_diff = row['stdevdiff'] - run_stdevdiff_avg
    run_meandiff_avg += mean_aux_diff / nsamples
    run_stdevdiff_avg += var_aux_diff / nsamples

    mean_aux_absdiff = abs(row['meandiff']) - run_absmeandiff_avg
    var_aux_absdiff = abs(row['stdevdiff']) - run_absstdevdiff_avg
    run_absmeandiff_avg += mean_aux_absdiff / nsamples
    run_absstdevdiff_avg += var_aux_absdiff / nsamples

    # compute running variances
    if nsamples > 1:
        run_meandiff_var += mean_aux_diff * (row['meandiff'] - run_meandiff_avg)
        run_stdevdiff_var += var_aux_diff * (row['stdevdiff'] - run_stdevdiff_avg)
        run_absmeandiff_var += mean_aux_absdiff * (abs(row['meandiff']) - run_absmeandiff_avg)
        run_absstdevdiff_var += var_aux_absdiff * (abs(row['stdevdiff']) - run_absstdevdiff_avg)
    nsamples += 1
