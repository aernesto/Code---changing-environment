"""
Obtain the posterior variance via 20 points of the density AND via the
analytical formula, at times:
500; 1,000; ...; 3,000 bins.
For a single realization of the stationary chain (fixed click rates).
"""
import dataset
import numpy as np
import matplotlib.pyplot as plt

debug = False


def printdebug(string):
    if debug:
        print(string)


def raster(event_times_list, **kwargs):
    """
    Creates a raster plot
    Parameters
    ----------
    event_times_list : iterable
                       a list of event time iterables
    Returns
    -------
    ax : an axis containing the raster plot
    """
    ax = plt.gca()
    for ith, trial in enumerate(event_times_list):
        plt.vlines(trial, ith + .5, ith + 1.5, **kwargs)
    plt.ylim(.5, len(event_times_list) + .5)
    return ax


def gen_cp(duration, h):
    """
    generate the CP times from the trial by successively sampling
    from an exponential distribution
    :param duration: trial duration in sec
    :param h: hazard rate in Hz
    :return: numpy array of change point times strictly positive and inferior to duration
    """
    cp_times = []
    cp_time = 0
    while cp_time < duration:
        dwell_time = np.random.exponential(1. / h)
        cp_time += dwell_time
        if cp_time < duration:
            cp_times += [cp_time]

    return np.array(cp_times)


def gen_stim(ct, rate_l, rate_h, dur):
    """
    generates two simultaneous clicks streams (one per ear), selecting the
    initial environmental state at random (P_0(H) is uniform).
    Recall that environment == 1 means that high rate is presented to right ear
    -1 otherwise.
    :param ct: numpy array of change point times
    :param rate_l: low click rate in Hz
    :param rate_h: high click rate in Hz
    :param dur: trial duration in seconds
    :return: tuple with 2 elements,
     The first element is itself the tuple (left_stream, right_stream)
     The second element is the last environmental state
    """
    state = np.zeros(len(ct) + 1)
    num_trains = len(state)  # number of trains to stack, for each ear
    state[0] = np.random.choice([-1, 1])

    # flip state after each change point
    for counter in range(1, num_trains):
        state[counter] = -1 * state[counter - 1]

    left_stream = []  # storing click trains for each ear
    right_stream = []

    # construct trains between each change point
    for tt in range(num_trains):
        # extract time length of current train
        if tt == 0:
            if len(ct) > 0:
                time_length = ct[tt]
                offset = 0
            else:
                time_length = dur
                offset = 0
        elif tt == (num_trains - 1):
            offset = ct[-1]
            time_length = dur - offset
        else:
            offset = ct[tt - 1]
            time_length = ct[tt] - offset

        # construct trains for both ears, depending on envt state
        left_train_low = [XX + offset for XX in gen_cp(duration=time_length, h=rate_l)]
        left_train_high = [XX + offset for XX in gen_cp(duration=time_length, h=rate_h)]
        right_train_high = [XX + offset for XX in gen_cp(duration=time_length, h=rate_h)]
        right_train_low = [XX + offset for XX in gen_cp(duration=time_length, h=rate_l)]
        if state[tt] == 1:  # evaluates to true if envt is in state H+ ---> high rate to right ear
            left_stream += left_train_low
            right_stream += right_train_high
        else:  # envt in state H- ---> high rate to left ear
            left_stream += left_train_high
            right_stream += right_train_low

    stim_tuple = (np.array(left_stream), np.array(right_stream))
    if debug:
        plt.figure(1)
        raster(stim_tuple)
        plt.title('Stimulus (click trains)')
        plt.xlabel('time')
        plt.ylabel('ear')
        plt.show()

    return stim_tuple, state[-1]


if __name__ == "__main__":
    # set connection to SQLite database
    # name of SQLite db
    dbname = 'var_1_clicks'
    # create connection to SQLite db
    db = dataset.connect('sqlite:///' + dbname + '.db')
    # get handle for specific table of the db
    table = db['variance']

    # set parameters
    num_trials = 1
    rate_low = 14  # in Hz
    rate_high = 40 - rate_low
    trial_duration = 1  # in sec
    hazard_rate = 1  # in Hz
    dt = 0.0001  # in seconds. Used to approximate cts MC by DTMC

    # initialize seed
    np.random.seed(None)
    seed = np.random.randint(1000000000)
    np.random.seed(seed)

    # generate change points
    change_points = gen_cp(trial_duration, hazard_rate)
    printdebug(change_points)

    # generate stimulus (first element is left stream, second is right stream)
    stimulus, last_state = gen_stim(change_points, rate_low, rate_high, trial_duration)

    #