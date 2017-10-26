import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import rv_discrete
import scipy
import datetime
import dataset
import pickle
plt.rcdefaults()

# Debug mode
debug = True


def printdebug(debugmode, string=None, vartuple=None):
    '''
    prints string, varname and var for debug purposes
    :param debugmode: True or False
    :param string: Custom message useful for debugging
    :param vartuple: Tuple (varname, var), where:
        :varname: string representing name of variable to display
        :var: actual Python variable to print on screen
    :return:
    '''
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


class Experiment(object):
    '''

    Note: to simulate discrete time equations, easiest way is to set exp_dt = 1
    '''
    def __init__(self, setof_stim_noise, exp_dt, setof_trial_dur, setof_h,
                 tot_trial, states=np.array([-1, 1]),
                 exp_prior=np.array([.5, .5])):
        self.states = states
        self.setof_stim_noise = setof_stim_noise
        self.setof_trial_dur = setof_trial_dur  # for now an integer in msec.
        self.tot_trial = tot_trial
        #         self.outputs = outputs
        self.setof_h = setof_h
        self.results = []
        self.exp_prior = exp_prior  # TODO: check that entries >=0 and sum to 1

        # exp_dt = 40 msec corresponds to 25 frames/sec (for stimulus presentation)
        try:
            # check that exp_dt divides all the trial durations
            if ((self.setof_trial_dur % exp_dt) != 0).sum() == 0:
                self.exp_dt = exp_dt  # in msec - or in time unit for discrete time
            else:
                raise AttributeError("Error in arguments: the Experiment's time"
                                     "step size "
                                     "'exp_dt' "
                                     "does not divide "
                                     "the trial durations 'setof_trial_dur'")
        except AttributeError as err:
            print(err.args)

    # function that switches the environment state that is given as argument
    def switch(self, H):
        try:
            # might be more elegant to use elseif syntax below
            if H in self.states:
                if H == self.states[0]:
                    return self.states[1]
                else:
                    return self.states[0]
            else:
                raise ValueError("Error in argument H: must be an element of "
                                 "Experiment.states")
        except AttributeError as err:
            print(err.args)

    def launch(self, observer, singleTrialOutputs, dbname):
        # boolean variables telling the script what to plot
        # plots are produced for a single trial ONLY if the total number of trials is 1
        # plots are produced for several trials ONLY if the total number of trials is > 1
        if self.tot_trial == 1:
            printEnvt = singleTrialOutputs[0]
            printStim = singleTrialOutputs[1]
            multi = False
        else:
            printEnvt = False
            printStim = False
            multi = True

        # Start exhaustive loop on parameters
        for h in self.setof_h:
            for duration in self.setof_trial_dur:
                for stim_noise in self.setof_stim_noise:
                    for trial_idx in range(self.tot_trial):
                        printdebug(debugmode=not debug,
                                   string="inside nested for loops",
                                   vartuple=("h",
                                             h))
                        printdebug(debugmode=not debug,
                                   vartuple=("duration",
                                             duration))
                        printdebug(debugmode=not debug,
                                   vartuple=("stim_noise",
                                             stim_noise))
                        printdebug(debugmode=not debug,
                                   vartuple=("trial_idx",
                                             trial_idx))
                        trial_number = trial_idx

                        # select initial true environment state for current trial
                        if np.random.uniform() < self.exp_prior[0]:
                            init_state = self.states[0]
                        else:
                            init_state = self.states[1]
                        printdebug(debugmode=not debug, string="about to create ExpTrial object")
                        np.random.seed(None)
                        seed = np.random.get_state()
                        curr_exp_trial = ExpTrial(self, h, duration, stim_noise,
                                                  trial_number, init_state, seed=seed)
                        printdebug(debugmode=not debug, string="about to create Stimulus object")
                        curr_stim = Stimulus(curr_exp_trial, printStim)
                        printdebug(debugmode=not debug, string="about to create ObsTrial object")
                        curr_obs_trial = ObsTrial(curr_exp_trial, curr_stim, observer.dt, self,
                                                  observer.prior_states, observer.prior_h,
                                                  dbname=dbname)
                        printdebug(debugmode=not debug, string="about to launch infer method")
                        curr_obs_trial.infer(save2db=True)


class ExpTrial(object):
    def __init__(self, expt, h, duration, stim_noise, trial_number,
                 init_state, seed):
        self.expt = expt
        self.true_h = h
        self.duration = duration  # msec
        self.stim_noise = stim_noise
        self.trial_number = trial_number
        self.init_state = init_state
        self.cp_times = self.gen_cp_discrete(self.duration, self.true_h)
        self.end_state = self.compute_endstate(self.cp_times.size)
        self.tot_trial = self.expt.tot_trial
        self.seed = seed

    def compute_endstate(self, ncp):
        # the fact that the last state equals the initial state depends on
        # the evenness of the number of change points.
        if ncp % 2 == 0:
            return self.init_state
        else:
            return self.expt.switch(self.init_state)

    def randlh(self, H):
        # try clause might be redundant (because switch method does it)
        try:
            if H in self.expt.states:
                return np.random.normal(H, self.stim_noise)
            else:
                raise ValueError("Error in argument H: must be an element of "
                                 "Experiment.states")
        except ValueError as err:
            print(err.args)

    def gen_cp_discrete(self, duration, true_h):
        cp_times = []
        t = 1  # time step
        while t <= duration:
            if np.random.uniform() < true_h:
                cp_times += [t]
            t += 1
        return np.array(cp_times)


class Stimulus(object):
    def __init__(self, exp_trial, printStim):
        self.exp_trial = exp_trial
        self.trial_number = self.exp_trial.trial_number

        self.binsize = self.exp_trial.expt.exp_dt  # in msec

        # number of bins, i.e. number of stimulus values to compute
        # the first bin has 0 width and corresponds to the stimulus presentation
        # at the start of the trial, when t = 0.
        # So for a trial of length T = N x exp_dt msecs, there will be an observation
        # at t = 0, t = exp_dt, t = 2 x exp_dt, ... , t = T
        self.nbins = int(self.exp_trial.duration / self.binsize) + 1

        self.stim = self.gen_stim(printStim)

    def gen_stim(self, printStim):

        # stimulus vector to be filled by upcoming while loop
        stimulus = np.zeros(self.nbins)

        ncp = self.exp_trial.cp_times.size  # number of change points

        # loop variables
        bin_nb = 0  # we start counting bins from 0
        last_envt = self.exp_trial.init_state
        next_cp_idx = 0
        non_passed = True

        for bin_nb in np.arange(self.nbins):
            # exact time in msec, of current bin
            curr_time = bin_nb * self.binsize

            # Control flow setting current environment
            if ncp == 0:  # no change point
                curr_envt = last_envt
            else:
                next_cp = self.exp_trial.cp_times[next_cp_idx]  # next change point time in msec
                if curr_time < next_cp:  # current bin ends before next cp
                    curr_envt = last_envt
                else:  # current bin ends after next cp
                    if non_passed:
                        curr_envt = self.exp_trial.expt.switch(last_envt)
                        if next_cp_idx < ncp - 1:
                            next_cp_idx += 1
                        else:
                            non_passed = False  # last change point passed
                    else:
                        curr_envt = last_envt

                        #             print('time, envt', curr_time, curr_envt)
            # compute likelihood to generate stimulus value
            stimulus[bin_nb] = self.exp_trial.randlh(curr_envt)

            # update variables for next iteration
            last_envt = curr_envt

        return stimulus


class IdealObs(object):
    def __init__(self, dt, expt, prior_states=np.array([.5, .5]), prior_h=np.array([1, 1])):
        self.expt = expt  # reference to Experiment object
        self.dt = dt
        self.prior_h = prior_h
        self.prior_states = prior_states  # TODO: check that prior_states is a stochastic vector

    # the following is the likelihood used by the ideal observer
    # H = assumed state of the environment
    # x = point at which to evaluate the pdf
    def lh(self, H, x, obs_noise):
        try:
            if H in self.expt.states:
                return scipy.stats.norm(H, obs_noise).pdf(x)
            else:
                raise ValueError("Error in argument H: must be an element of "
                                 "Experiment.states")
        except ValueError as err:
            print(err.args)


class ObsTrial(IdealObs):
    def __init__(self, exp_trial, stimulus, dt, expt,
                 prior_states=np.array([.5, .5]),
                 prior_h=np.array([1, 1]),
                 dbname=None):
        super().__init__(dt, expt, prior_states, prior_h)
        self.exp_trial = exp_trial
        self.stimulus = stimulus
        self.llr = np.zeros(self.stimulus.nbins)
        self.decision = 0
        self.obs_noise = self.exp_trial.stim_noise
        self.trial_number = self.exp_trial.trial_number
        # artificial observations for testing purposes
        #         self.obs = np.array([0.7, -0.2, -2, 3.6])
        self.obs = self.gen_obs()
        self.dbname = dbname

    def gen_obs(self):
        return self.stimulus.stim

    def infer(self, save2db):
        #  initialize variables
        Hp = self.expt.states[1]
        Hm = self.expt.states[0]
        joint_plus_new = np.zeros(self.stimulus.nbins)
        joint_plus_current = np.copy(joint_plus_new)
        joint_minus_new = np.copy(joint_plus_new)
        joint_minus_current = np.copy(joint_plus_new)
        alpha = self.prior_h[0]
        priorPrec = self.prior_h.sum()
        Pp = np.zeros([self.stimulus.nbins, self.stimulus.nbins])
        Pm = np.copy(Pp)

        # get first observation
        x = self.obs[0]

        # First time step
        # compute joint posterior after first observation: P_{t=0}(H,a=0) --- recall first obs at t=0
        joint_minus_current[0] = self.lh(Hm, x, self.obs_noise) * self.prior_states[0]
        joint_plus_current[0] = self.lh(Hp, x, self.obs_noise) * self.prior_states[1]

        #         print(joint_plus_current)
        Fd = joint_plus_current[0] + joint_minus_current[0]
        joint_plus_current[0] = joint_plus_current[0] / Fd
        #         print(joint_plus_current[0])
        joint_minus_current[0] = joint_minus_current[0] / Fd

        # compute marginals over state
        lp = joint_plus_current[0]
        lm = joint_minus_current[0]
        self.llr[0] = np.log(lp / lm)  # log posterior odds ratio
        Pp[:, 0] = joint_plus_current.copy()
        Pm[:, 0] = joint_minus_current.copy()

        # pursue algorithm if interrogation time is greater than 0
        if self.exp_trial.duration == 0:
            print('trial has duration 0 msec')
            # todo: find a way to exit the function

        for j in np.arange(self.stimulus.nbins - 1):
            # make an observation
            x = self.obs[j + 1]

            # compute likelihoods
            xp = self.lh(Hp, x, self.obs_noise)
            xm = self.lh(Hm, x, self.obs_noise)

            # update the boundaries (with 0 and j changepoints)
            ea = 1 - alpha / (j + priorPrec)
            eb = (j + alpha) / (j + priorPrec)
            joint_plus_new[0] = xp * ea * joint_plus_current[0]
            joint_minus_new[0] = xm * ea * joint_minus_current[0]
            joint_plus_new[j + 1] = xp * eb * joint_minus_current[j]
            joint_minus_new[j + 1] = xm * eb * joint_plus_current[j]

            # update the interior values
            if j > 0:
                vk = np.arange(2, j + 2)
                #                 print('vk',vk)
                ep = 1 - (vk - 1 + alpha) / (j + priorPrec)  # no change
                em = (vk - 2 + alpha) / (j + priorPrec)  # change

                joint_plus_new[vk - 1] = xp * (np.multiply(ep, joint_plus_current[vk - 1]) +
                                               np.multiply(em, joint_minus_current[vk - 2]))
                joint_minus_new[vk - 1] = xm * (np.multiply(ep, joint_minus_current[vk - 1]) +
                                                np.multiply(em, joint_plus_current[vk - 2]))

            # sum probabilities in order to normalize
            Hs = joint_plus_new.sum() + joint_minus_new.sum()
            joint_plus_current = joint_plus_new / Hs
            joint_minus_current = joint_minus_new / Hs
            Pp[:, j + 1] = joint_plus_current.copy()
            Pm[:, j + 1] = joint_minus_current.copy()

        # compute marginals over change point count if last iteration
        self.marg_gamma = joint_plus_current + joint_minus_current

        if save2db:
            self.save2db(dbname=self.dbname, seed=self.exp_trial.seed)

    def save2db(self, dbname, seed):
        dict2save = dict()
        dict2save['commit'] = '21b7d9a5c6136b2c5757599cd0025ffd2924a28b'
        dict2save['path2file'] = 'sims_learning_rate/scripts/feedback_effect_1.py'
        dict2save['discreteTime'] = True
        dict2save['trialNumber'] = self.exp_trial.trial_number
        dict2save['trialDuration'] = self.exp_trial.duration
        printdebug(debugmode=not debug,
                   vartuple=("seed has type", type(seed)))
        printdebug(debugmode=not debug, vartuple=("seed", seed))
        dict2save['initialState'] = self.exp_trial.init_state
        dict2save['endState'] = self.exp_trial.end_state
        dict2save['alpha'] = self.prior_h[0]
        dict2save['beta'] = self.prior_h[1]
        # compute and store time since last change point
        if self.exp_trial.cp_times.size > 0:
            time_last_cp = self.exp_trial.duration - self.exp_trial.cp_times[-1]
        else:
            time_last_cp = self.exp_trial.duration
        dict2save['timeLastCp'] = time_last_cp

        # write heavy data to file
        heavydict = dict()
        heavydict['seed'] = seed
        heavydict['marginal-gamma'] = self.marg_gamma
        # heavydict['post-var-h'] =
        # heavydict['post-mean-h'] =
        filename = dbname + '.pickle'
        with open(filename, 'wb') as handle:
            pickle.dump(heavydict, handle, protocol=pickle.HIGHEST_PROTOCOL)

        db = dataset.connect('sqlite:///' + dbname + '.db')
        table = db['feedback']
        table.insert(dict2save)


if __name__ == "__main__":

    # SET PARAMETERS
    printdebug(debugmode=debug,
               string="debug prints activated")
    # list of hazard rates to use in sim
    hazard_rates = [0.01]
    hstep = 0.05
    hh = hstep
    while hh < 0.51:
        hazard_rates += [hh]
        hh += hstep
    printdebug(debugmode=not debug, vartuple=("hazard_rates", hazard_rates))
    # hyper-parameters of Beta prior
    alpha = 1
    beta = 1

    # list of SNRs to use in sim
    SNR = []
    stimstdev = []
    snrstep = 0.2
    snr = snrstep
    while snr < 3.01:
        stdev = 2.0 / snr
        SNR += [snr]
        stimstdev += [stdev]
        snr += snrstep

    # time step. Should be one for discrete time
    dt = 1  # for discrete time

    # numpy array of trial durations to use in sim
    trial_durations = [50]
    tdstep = 100
    td = tdstep
    while td < 2001:
        trial_durations += [td]
        td += tdstep
    trial_durations = np.array(trial_durations)

    # total number of trials per condition
    nTrials = 1

    # boolean variables telling script what to plot
    singleTrialOutputs = [True, True, True]
    multiTrialOutputs = [True, True]

    # filenames for saving data
    dbname = 'test_3'

    printdebug(debugmode=not debug, string="about to create expt object")
    Expt = Experiment(setof_stim_noise=stimstdev, exp_dt=dt, setof_trial_dur=trial_durations,
                      setof_h=hazard_rates, tot_trial=nTrials)
    printdebug(debugmode=not debug, string="Expt object created")
    Observer = IdealObs(dt=Expt.exp_dt, expt=Expt, prior_h=np.array([alpha, beta]))
    printdebug(debugmode=not debug, string="Observer object created")
    aa = datetime.datetime.now().replace(microsecond=0)
    printdebug(debugmode=not debug, string="initial time stored")
    printdebug(debugmode=True, string="about to execute the launch method")
    Expt.launch(Observer, singleTrialOutputs, dbname)

    bb = datetime.datetime.now().replace(microsecond=0)
    print('total elapsed time in hours:min:sec is', bb - aa)
