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
                                                   'lowrate', low_rate,
                                                   'highrate', high_rate,
                                                   'assumedh',
                                                   'assumedh'))
    curve1 = []
    x1 = []
    for row_data in result1:
        x1 += [row_data['assumedrate']]
        curve1 += [row_data['performance']]

    plt.figure(fignum)
    plt.plot(x1, curve1, linewidth=3.0)
    plt.title('ODE - 3,000 trials per point - low/high rate = 14/26')
    # plt.legend(['snr ' + str(pair1[0]) + '; h ' + str(pair1[1]),
    #             'snr ' + str(pair2[0]) + '; h ' + str(pair2[1])])
    plt.xlabel('assumed hazard rate')
    plt.ylabel('percentage correct')
    plt.show()


if __name__ == "__main__":
    # name of SQLite db
    dbname = 'test_7_clicks'
    # create connection to SQLite db
    db = dataset.connect('sqlite:///' + dbname + '.db')
    # get handle for specific table of the db
    table = db['perf']

    plot_clicks_perfs(14, 26, db, 1)
