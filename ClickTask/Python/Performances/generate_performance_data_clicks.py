"""
For fixed hazard rate, click rates, and trial duration,
generate num_trials dynamic clicks trials, and computes
the ideal observer's performance, with delta function on
h.
Stores data with seed in SQLite database
"""
import dataset
import numpy as np
import datetime
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


def evolve_ode(hh, stim, lr, hr, stim_dur):
    """
    Evolves the optimal ODE described in Piet et al. 2017 (without sensory noise)
    Integration method is forward Euler
    :param hh: assumed hazard rate in Hz (delta prior of the observer)
    :param stim: tuple of left and right click streams
    :param lr: low click rate
    :param hr: high click rate
    :param stim_dur: stimulus duration in seconds
    :return: state chosen by ideal observer at end of trial
    """
    dt = 0.0001  # time step in sec
    if lr > 0:
        kappa = np.log(hr / lr)
    else:
        print('for now, null low rate not allowed')  # todo: need to deal with this case
        return None

    a = 0  # log posterior odds ratio (accumulated evidence)
    b = [a]
    time = dt  # absolute time in sec, represents right endpoint of time bin
    left_clicks, right_clicks = stim  # click trains for each ear

    # time of last left and right click, respectively, with their array indices
    if len(left_clicks) == 0:
        next_left, idx_left = None, None
    else:
        next_left, idx_left = left_clicks[0], 0
        top_left = len(left_clicks) - 1
    if len(right_clicks) == 0:
        next_right, idx_right = None, None
    else:
        next_right, idx_right = right_clicks[0], 0
        top_right = len(right_clicks) - 1

    while time < stim_dur:
        if abs(np.sinh(a)) > 1000000:
            print('trial', trial_nb, 'time', time)
            print('sinh yields absolute value above 1M')
        a -= dt * (2 * hh * np.sinh(a))

        # when no next left click exists...
        if next_left is None:
            left_click = 0

            # if no next right click exists...
            if next_right is None:
                right_click = 0  # here, both left and right clicks are disabled

            # there exists an upcoming right click
            else:
                # the next right click falls into current bin
                if time >= next_right:
                    right_click = kappa  # enable upwards evidence jump

                    # increment upcoming right click, only if this wasn't the last one
                    if idx_right < top_right:
                        idx_right += 1
                        next_right = right_clicks[idx_right]

                    # if it was the last one, disable upcoming right clicks
                    else:
                        next_right, idx_right = None, None

                # the next right click hasn't been reached yet
                else:
                    right_click = 0

        # there is a next left click scheduled
        else:
            # if the next left click fell into the current bin
            if time >= next_left:
                left_click = -kappa  # set appropriate evidence jump

                # increment upcoming left click, only if this wasn't the last one
                if idx_left < top_left:
                    idx_left += 1
                    next_left = left_clicks[idx_left]

                # if it was the last one, disable upcoming left clicks
                else:
                    next_left, idx_left = None, None
            # next left click hasn't been reached yet
            else:
                left_click = 0

            # if there is no upcoming right click, set evidence jump to zero
            if next_right is None:
                right_click = 0

            # if there is a right click scheduled
            else:
                # the next right click falls into current bin
                if time >= next_right:
                    right_click = kappa  # enable upwards evidence jump
                    if left_click is not 0:
                        printdebug('left and right clicks fell into same bin at time' + str(time))
                    # increment upcoming right click, only if this wasn't the last one
                    if idx_right < top_right:
                        idx_right += 1
                        next_right = right_clicks[idx_right]

                    # if it was the last one, disable upcoming right clicks
                    else:
                        next_right, idx_right = None, None

                # the next right click hasn't been reached yet
                else:
                    right_click = 0

        # update evidence with discontinuous jumps:
        if np.isnan(a):
            print('trial', trial_nb, 'a is nan at time', time)
            break
        else:
            if abs(right_click + left_click) > 0.0001:
                printdebug('jumping by ' + str(right_click + left_click) + ' at time ' + str(time))
            a += right_click + left_click
            # b += [a]

        time += dt
    if debug:
        plt.figure(2)
        plt.plot(b)
        plt.title('evidence 1 trial')
        plt.xlabel('time bin')
        plt.show()
    return np.sign(a)


if __name__ == "__main__":
    # set connection to SQLite database
    # name of SQLite db
    dbname = 'test_7_clicks'
    # create connection to SQLite db
    db = dataset.connect('sqlite:///' + dbname + '.db')
    # get handle for specific table of the db
    table = db['perf']

    # set parameters
    num_trials = 3000
    rate_low = 14  # in Hz
    rate_high = 40 - rate_low
    trial_duration = 1  # in sec
    hazard_rate = 1  # in Hz
    list_assumed_h = np.arange(0.5, 3.1, .1)  # assumed hazard rate in Hz

    aa = datetime.datetime.now().replace(microsecond=0)
    for assumed_h in list_assumed_h:
        for trial_nb in range(num_trials):

            # initialize seed
            np.random.seed(None)
            seed = np.random.randint(1000000000)
            np.random.seed(seed)

            # generate change points
            change_points = gen_cp(trial_duration, hazard_rate)
            printdebug(change_points)
            # generate stimulus (first element is left stream, second is right stream)
            stimulus, last_state = gen_stim(change_points, rate_low, rate_high, trial_duration)

            # compute performance of ODE model
            decision = evolve_ode(assumed_h, stimulus, rate_low, rate_high, trial_duration)
            if np.isnan(decision):
                score = None
            elif int(decision) == int(last_state):
                score = 1
            else:
                score = 0

            # write to database
            if score is None:
                pass
            else:
                table.insert({'seed': seed,
                              'score': score,
                              'lowrate': rate_low,
                              'highrate': rate_high,
                              'h': hazard_rate,
                              'assumedh': assumed_h,
                              'trialdur': trial_duration})

    bb = datetime.datetime.now().replace(microsecond=0)
    print('total elapsed time in hours:min:sec is', bb - aa)
