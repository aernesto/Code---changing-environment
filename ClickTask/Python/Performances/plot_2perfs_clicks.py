"""
This script allows to plot two curves, using data stored in an SQLite
database. Each curve is percentage correct as function of time since last change point.
"""
import dataset
import matplotlib.pyplot as plt


def plot_clicks_perfs(low_rate, high_rate, data, fignum):
    """
    Generate two curves (one per parameter pair)
    Plot curves in order to visualize the cross-over effect
    :param pair1: 2-element tuple (snr, h)
        :snr: float
        :h: float in Hz
    :param pair2: like pair1, for the second curve
    :param data: database object from dataset module
    :param columnnames: dict containing column names from db

            columnnames = {'commit': 'comm',
                            'trial_duration': 'dur',
                            'snr': 'snr',
                            'h': 'h',
                            'seed': 'seed',
                            'bin_number': 'numb',
                            'bin_width': 'bwidth',
                            'init_state': 'init',
                            'end_state': 'end',
                            'decision': 'dec',
                            'correctness': 'correct'}
    :param fignum: figure number (integer)
    :return: produces cross-over plot for the two given curves
    """
    result1 = data.query('SELECT {} AS assumedrate, AVG({}) AS performance FROM perf \
                              WHERE {} = {} AND {} = {} \
                              GROUP BY {} \
                              ORDER BY {};'.format('assumedh',
                                                   'score',
                                                   'lowrate', low_rate[0],
                                                   'highrate', high_rate[0],
                                                   'assumedh',
                                                   'assumedh'))
    curve1 = []
    x1 = []
    maxpoints = 4
    points = 1
    for row_data in result1:
        if points > maxpoints:
            break
        else:
            points += 1
        x1 += [row_data['assumedrate']]
        curve1 += [row_data['performance']]

    result2 = data.query('SELECT {} AS assumedrate, AVG({}) AS performance FROM perf \
                                  WHERE {} = {} AND {} = {} \
                                  GROUP BY {} \
                                  ORDER BY {};'.format('assumedh',
                                                       'score',
                                                       'lowrate', low_rate[1],
                                                       'highrate', high_rate[1],
                                                       'assumedh',
                                                       'assumedh'))
    curve2 = []
    x2 = []
    points = 1
    for row_data in result2:
        if points > maxpoints:
            break
        else:
            points += 1
        x2 += [row_data['assumedrate']]
        curve2 += [row_data['performance']]
    plt.figure(fignum)
    plt.plot(x1, curve1, x2, curve2, linewidth=3.0)
    plt.title('ODE - 10,000 trials per point - low/high rate = 14/26')
    plt.legend(['low ' + str(low_rate[0]) + '; high ' + str(high_rate[0]),
                'low ' + str(low_rate[1]) + '; high ' + str(high_rate[1])])
    plt.xlabel('assumed hazard rate')
    plt.ylabel('percentage correct')
    plt.ylim(.5,1)
    plt.show()


if __name__ == "__main__":
    # name of SQLite db
    dbname = 'compute11_10000_lowsnr_h1_clicks'
    # create connection to SQLite db
    db = dataset.connect('sqlite:///' + dbname + '.db')
    # get handle for specific table of the db
    table = db['perf']

    plot_clicks_perfs([14, 8], [26, 32], db, 1)
