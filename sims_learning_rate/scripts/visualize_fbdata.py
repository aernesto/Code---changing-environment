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
import numpy as np
import dataset
import matplotlib.pyplot as plt

# Debug mode
debug = True


def printdebug(debugmode, string=None, vartuple=None):
    """
    prints string, varname and var for debug purposes
    :param debugmode: True or False
    :param string: Custom message useful for debugging
    :param vartuple: Tuple (varname, var), where:
        :varname: string representing name of variable to display
        :var: actual Python variable to print on screen
    :return:
    """
    if debugmode:
        print('-------------------------')
        if string is None:
            pass
        else:
            print(string)
        if vartuple is None:
            pass
        else:
            print(vartuple[0], '=', vartuple[1])
        print('-------------------------')


# get connection to SQLite database where results are stored
dbname = 'true_5.db'
tablename = 'feedback'
db = dataset.connect('sqlite:///' + dbname)
table = db[tablename]


def list_tables():
    """
    :return: list existing fields in the table
    """
    print(table.columns)


def list_unique(fields):
    """
    :param fields: list of strings containing field names from SQLite database
    :return: list unique values in each field from fields
    """
    for field in fields:
        # print('unique values from ' + field)
        for thisrow in table.distinct(field):
            # print('type', type(row[field]))
            print(thisrow[field])
        print('-----------------------------------')


def list_triplets(prints=True):
    """
    :param prints: True to get printed output, False if only the count is desired
    :return: prints the distinct values of each triplet (duration, h, SNR) if prints = True
            returns the count of these distinct triplets
    """
    result0 = db.query('SELECT trialDuration, hazardRate, SNR, COUNT(trialNumber) AS c \
    FROM feedback GROUP BY trialDuration, SNR, hazardRate')
    count = 0
    for row in result0:
        count += 1
        if prints:
            print('triplet:', row['trialDuration'], round(row['hazardRate'], 3), round(row['SNR'], 3))
            print('count:', row['c'])
            print('-----------------------------------')
    printdebug(debugmode=not debug, vartuple=('nb of distinct triplets', count))
    return count


def analyze_diff(typediff='new'):
    """
    :param typediff: Either 'old' or 'new', depending on whether the table
                    analyzed was before or after true_3.db
    :return: numpy array "array_results" with, as many rows as there are distinct triplets,
            (trialDuration, hazardRate, SNR)
            Columns are as follows:
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
    """
    if typediff == 'old':
        result1 = db.query('SELECT trialDuration, hazardRate, SNR, '
                           '(meanFeedback - meanNoFeedback) as meandiff, '
                           '(stdevFeedback - stdevNoFeedback) as stdevdiff '
                           'FROM feedback')
    elif typediff == 'new':
        result1 = db.query('SELECT trialDuration, hazardRate, SNR, meandiff, '
                           'stdevdiff FROM feedback')

    # store results in numpy array
    '''
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
    array_results = np.zeros((list_triplets(prints=False), 10))
    array_row = -1
    lasttriplet = (0, 0, 0)
    nsamples = 1
    run_meandiff_avg, run_meandiff_var, run_stdevdiff_avg, run_stdevdiff_var = (0, 0, 0, 0)
    run_absmeandiff_avg, run_absmeandiff_var, run_absstdevdiff_avg, run_absstdevdiff_var = (0, 0, 0, 0)
    ccc = 0
    for row in result1:
        ccc += 1
        printdebug(debugmode=not debug, vartuple=("iteration, ", ccc))
        newtriplet = (int(row['trialDuration']), row['hazardRate'], row['SNR'])
        if newtriplet != lasttriplet:
            if nsamples > 1:
                nsamples -= 1  # to correct for last incorrect increment
                coef = nsamples - 1
                # compute CVs to store
                std_absmeandiff = np.sqrt(run_meandiff_var / coef)
                if run_absmeandiff_avg > 1e-6:
                    cv_meandiff = std_absmeandiff / run_absmeandiff_avg
                else:
                    cv_meandiff = np.nan

                std_absstdevdiff = np.sqrt(run_stdevdiff_var / coef)
                if run_absstdevdiff_avg > 1e-6:
                    cv_stdevdiff = std_absstdevdiff / run_absstdevdiff_avg
                else:
                    cv_stdevdiff = np.nan

                # store
                array_results[array_row, 3:10] = (run_meandiff_avg,
                                                  run_stdevdiff_avg,
                                                  np.sqrt(run_meandiff_var / coef),
                                                  np.sqrt(run_stdevdiff_var / coef),
                                                  cv_meandiff,
                                                  cv_stdevdiff,
                                                  nsamples)

            nsamples = 1
            array_row += 1
            # fill in first 3 columns
            array_results[array_row, 0:3] = newtriplet
            lasttriplet = newtriplet

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

    return array_results


def plot_hist_cv(array, lastfigure):
    """
    :param array: array returned by analyze_diff()
    :param lastfigure: integer to generate figure numbers
    :return: two histograms for the CV of the absolute values of the differences
            between posterior means; and between posterior stdevs.
    """
    lastfigure += 1
    plt.figure(lastfigure)
    absmeans = array[:, 7]
    absmeans = absmeans[~np.isnan(absmeans)]
    plt.hist(absmeans, bins='auto')
    plt.title('CV diff means')
    plt.xlabel('CV of absolute diff between posterior means')
    plt.ylabel('count out of 100')
    lastfigure += 1
    plt.figure(lastfigure)
    absstdev = array[:, 8]
    absstdev = absstdev[~np.isnan(absstdev)]
    plt.hist(absstdev, bins='auto')
    plt.title('CV diff std')
    plt.xlabel('CV of absolute diff between posterior stdev')
    plt.ylabel('count out of 100')
    plt.show()


def plots1d(array, fixed_vars, lastfigure):
    """
    :param array: numpy array returned by analyze_diff()
    :param fixed_vars: dict with two key-value pairs.
        key: one of 'SNR', 'hazardRate', 'trialDuration'
        value: an appropriate value existing in the database
    :param lastfigure: integer to generate figure numbers
    :return: four errorbar plots for the mean (error bars represent 1 stdev) of:
            - the difference between posterior means;
            - the difference between posterior stdevs;
            - the absolute difference between posterior means;
            - the absolute difference between posterior stdevs.
    """
    keylist = list(fixed_vars.keys())
    valuelist = list(fixed_vars.values())
    # pass array to an equivalent SQLite database on which the query may be run
    # get connection to SQLite database where results are stored
    db_aux = dataset.connect('sqlite:///:memory:')
    table_aux = db_aux[tablename]

    # fill in the database row by row from the numpy array
    for array_row in np.arange(array.shape[0]):
        elts = array[array_row, :]
        table_aux.insert({'trialDuration': elts[0],
                          'hazardRate': elts[1],
                          'SNR': elts[2],
                          'meanMeandiff': elts[3],
                          'meanStdevdiff': elts[4],
                          'stdMeandiff': elts[5],
                          'stdStdevdiff': elts[6],
                          'cv1': elts[7],
                          'cv2': elts[8],
                          'nsamples': elts[9]})

    # get the free variable name (indepvar)
    if 'SNR' not in keylist:
        indepvarname = 'SNR'
    elif 'trialDuration' not in keylist:
        indepvarname = 'trialDuration'
    elif 'hazardRate' not in keylist:
        indepvarname = 'hazardRate'

    printdebug(debugmode=debug, vartuple=('indepvarname', indepvarname))

    result2 = db_aux.query('SELECT meanMeandiff, stdMeandiff, meanStdevdiff, \
    stdStdevdiff, {} FROM feedback WHERE {} = {} AND {} = {}'.format(indepvarname,
                                                                     keylist[0],
                                                                     valuelist[0],
                                                                     keylist[1],
                                                                     valuelist[1]))
    indepvar = []
    means = indepvar.copy()
    stdevs = indepvar.copy()
    err_means = indepvar.copy()
    err_stdevs = indepvar.copy()
    for row in result2:
        indepvar += [row[indepvarname]]
        means += [row['meanMeandiff']]
        stdevs += [row['meanStdevdiff']]
        err_means += [row['stdMeandiff']]
        err_stdevs += [row['stdStdevdiff']]

    lastfigure += 1
    plt.figure(lastfigure)
    plt.errorbar(indepvar, means, yerr=err_means)
    plt.title("avg diff in means as fcn of " + indepvarname)
    plt.xlabel(indepvarname)
    lastfigure += 1
    plt.figure(lastfigure)
    plt.errorbar(indepvar, stdevs, yerr=err_stdevs)
    plt.title("avg diff in stdev as fcn of " + indepvarname)
    plt.xlabel(indepvarname)
    plt.show()


if __name__ == "__main__":
    fignum = 0
    # list_tables()
    # list_unique(['trialDuration', 'SNR', 'hazardRate'])
    # list_triplets()
    # simdata = analyze_diff(typediff='new')
    # plot_hist_cv(simdata, fignum)
    # plots1d(simdata, {'hazardRate': 0.1, 'SNR': 1.0}, fignum)
