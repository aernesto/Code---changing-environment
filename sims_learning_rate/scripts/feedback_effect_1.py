import matplotlib.pyplot as plt
plt.rcdefaults()
import numpy as np
from scipy.stats import rv_discrete, beta
# from scipy import stats
import scipy
# import random
# import sqlite3
import datetime
# import subprocess
# import scipy.stats
# import psycopg2
import dataset


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

    def launch(self, observer, singleTrialOutputs, multiTrialOutputs):
        # boolean variables telling the script what to plot
        # plots are produced for a single trial ONLY if the total number of trials is 1
        # plots are produced for several trials ONLY if the total number of trials is > 1
        if self.tot_trial == 1:
            printEnvt = singleTrialOutputs[0]
            printStim = singleTrialOutputs[1]
            printLLR = singleTrialOutputs[2]
            multi = False
            raw_perf = False
            perf_lastcp = False
        else:
            printEnvt = False
            printStim = False
            printLLR = False
            multi = True
            raw_perf = multiTrialOutputs[0]
            perf_lastcp = multiTrialOutputs[1]

        # Start exhaustive loop on parameters
        for h in self.setof_h:
            for duration in self.setof_trial_dur:
                for stim_noise in self.setof_stim_noise:
                    for trial_idx in range(self.tot_trial):
                        trial_number = trial_idx

                        # select initial true environment state for current trial
                        if np.random.uniform() < self.exp_prior[0]:
                            init_state = self.states[0]
                        else:
                            init_state = self.states[1]

                        curr_exp_trial = ExpTrial(self, h, duration, stim_noise,
                                                  trial_number, init_state, printEnvt)
                        curr_stim = Stimulus(curr_exp_trial, printStim)
                        curr_obs_trial = ObsTrial(curr_exp_trial, curr_stim, observer.dt, self,
                                                  observer.prior_states, observer.prior_h)
                        curr_obs_trial.infer(printLLR)

                        # gather variables to store in database
                        if multi:
                            trial_duration = curr_exp_trial.duration
                            cp = curr_exp_trial.cp_times
                            if cp.size > 0:
                                time_last_cp = trial_duration - curr_exp_trial.cp_times[-1]
                            else:
                                time_last_cp = int(curr_exp_trial.duration)
                            dec = int(curr_obs_trial.decision)
                            #                 print(type(dec))
                            correct = bool(dec == curr_exp_trial.end_state)
                            #                 print(type(correct))
                            #                 print(dec, correct)

                            # WRITE TO DB

                            #         print(raw_perf)
        if raw_perf:
            self.raw_perf()

        # print(perf_lastcp)
        if perf_lastcp:
            self.perf_last_cp()

            # curr_exp_trial.save()
            #            curr_obs_trial.save()
            #         self.print_db()

    # def raw_perf(self):
    #     cursor = cur.execute("SELECT COUNT(Correct) FROM Results WHERE Correct == 1")
    #     for row in cursor:
    #         print('percent correct = ', (row[0] / self.tot_trial) * 100)
    #         print(' ')  # just to have a blank line

    # def perf_last_cp(self):
    #     #         print('entered the perf_last_cp function')
    #     # cursor1 = cur.execute('''SELECT TimeLastCp, SUM(Correct)*1.0 / COUNT(TimeLastCp), COUNT(TimeLastCp)
    #                             FROM Results
    #                             GROUP BY TimeLastCp
    #                             ORDER BY TimeLastCp''')
    #     time = np.zeros(0)
    #     perf = np.copy(time)
    #     counts = np.copy(time)
    #     for row in cursor1:
    #         time = np.append(time, row[0])
    #         perf = np.append(perf, row[1])
    #         counts = np.append(counts, row[2])
    #     # print(row)
    #     plt.figure()
    #     plt.ylim([0, counts.max()])
    #     plt.bar(time, counts, align='center', width=3)
    #     plt.title('Histogram of trial counts per time bin')
    #     plt.xlabel('time since last CP (msec)')
    #     plt.ylabel('trial count')
    #
    #     plt.figure()
    #     plt.plot(time, perf)
    #     plt.title('perf as fcn of time since last CP')
    #     plt.xlabel('time since last CP (msec)')
    #     plt.ylabel('percent correct')
    #     plt.show()
    #
    # # def print_db(self):
    # #     print('database content')  # temporary
    # #     cursor = cur.execute('''SELECT * FROM Results''')
    # #     for row in cursor:
    # #         print("Trial nb = ", row[0])
    # #         print("Decision = ", row[1])
    # #         print("Correct = ", row[2])
    # #         print("Time since last cp = ", row[3])
    # #         print("Trial duration", row[4], "\n")
    #
    # def parallel_launch(self):
    #     return 0  # temporary


class ExpTrial(object):
    def __init__(self, expt, h, duration, stim_noise, trial_number,
                 init_state, printEnvt):
        self.expt = expt
        self.true_h = h
        self.duration = duration  # msec
        self.stim_noise = stim_noise
        self.trial_number = trial_number
        self.init_state = init_state
        self.cp_times = self.gen_cp_discrete(self.duration, self.true_h)
        self.end_state = self.compute_endstate(self.cp_times.size)
        self.tot_trial = self.expt.tot_trial

    def compute_endstate(self, ncp):
        # the fact that the last state equals the initial state depends on
        # the evenness of the number of change points.
        if ncp % 2 == 0:
            return self.init_state
        else:
            return self.expt.switch(self.init_state)

    # def save(self):
    #        print('stimulus is:')
    #        print(self.stim)

    # the following is the likelihood used to generate stimulus values,
    #  given the true state H of the environment
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

    '''
    generates poisson train of duration milliseconds with rate true_h in Hz, 
    using the Gillespie algorithm.

    print statements are only there for debugging purposes
    '''
    def gen_cp(self, duration, true_h, printEnvt):
        # TODO: Generate a warning if >1 ch-pt occur in Experiment.exp_dt window
        # print('launching gen_cp')

        # convert duration into seconds.
        secdur = duration / 1000.0
        # print('secdur = '), secdur
        '''
        pre-allocate ten times the mean array size 
        for speed, will be shrinked after computation
        '''
        nEntries = int(np.ceil(10 * true_h * secdur))
        # print('allocated entries = '), nEntries

        t = np.zeros(nEntries)
        if nEntries == 0:
            print('change point times are')
            print(t)
            return t

        totalTime = 0
        eventIdx = -1

        while totalTime < secdur:
            sojournTime = np.random.exponential(1. / true_h)
            totalTime += sojournTime
            eventIdx += 1
            t[eventIdx] = totalTime

        # trim unused nodes, and maybe last event if occurred beyond secdur

        # print t[0:10]
        lastEvent, idxLastEvent = t.max(0), t.argmax(0)
        # print 'lastEvent = ', lastEvent, 'idxLastEvent = ', idxLastEvent

        if lastEvent > secdur:
            idxLastEvent -= 1

        if idxLastEvent == -1:
            t = np.zeros((0, 1))
        else:
            t = t[0:int(idxLastEvent) + 1]

        if printEnvt:
            if t.size == 0:
                x = np.array([0, secdur])
                y = np.array([self.init_state, self.init_state])
            else:
                x = np.insert(t, 0, 0)
                x = np.append(x, secdur)
                xpoints = x.size
                y = np.zeros(xpoints)
                y[0] = self.init_state
                last_envt = self.init_state
                for jjj in np.arange(1, xpoints):
                    new_envt = self.expt.switch(last_envt)
                    if jjj == xpoints - 1:
                        y[jjj] = last_envt
                    else:
                        y[jjj] = new_envt
                    last_envt = new_envt

                    #             print(y)
            fig = plt.figure()
            ax = fig.add_subplot(1, 1, 1)
            ticks = np.array([0, 1])
            ax.set_yticks(ticks)
            ax.set_xticks(x)
            ax.set_ylim([self.expt.states[0] - 1, self.expt.states[1] + 1])
            labels = ['H - ', 'H +']
            plt.yticks(self.expt.states, labels)
            plt.step(x, y, where='post')
            plt.title('Environment')
            plt.xlabel('time (seconds)')
            plt.show()
        # print('change point times are')
        #         print(t)
        return t


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

        # plot stimulus trace
        if printStim:
            #             plt.figure()
            plt.plot(np.arange(self.nbins), stimulus, 'o')
            plt.title('stimulus / observations')
            plt.show()

        # print('stimulus created')
        #         print(stimulus)
        return stimulus


class IdealObs(object):
    def __init__(self, dt, expt, prior_states=np.array([.5, .5]), prior_h=np.array([1, 1])):
        self.expt = expt  # reference to Experiment object
        self.dt = dt
        # try:
        #     if (self.expt.setof_trial_dur % dt) == 0:
        #         self.dt = dt  # in msec
        #     else:
        #         raise AttributeError("Error in arguments: the observer's time"
        #                              "step size "
        #                              "'dt' "
        #                              "does not divide "
        #                              "the trial durations 'setof_trial_dur'")
        # except AttributeError as err:
        #     print(err.args)

        self.prior_h = prior_h
        self.prior_states = prior_states  # TODO: check that prior_states is a stochastic vector

        #self.obs_noise = self.expt.setof_stim_noise

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
    def __init__(self, exp_trial, stimulus, dt, expt, prior_states=np.array([.5, .5]), prior_h=np.array([1, 1])):
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

    def gen_obs(self):
        return self.stimulus.stim

    #     def lh(self, H, x):
    #         IdealObs.lh(H.x)

    def infer(self, printLLR):
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
        #         print('first obs = ', x)
        #         print('Hp = ', Hp)

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
            #             print('j',j)
            # make an observation
            x = self.obs[j + 1]

            # compute likelihoods
            xp = self.lh(Hp, x, self.obs_noise)
            xm = self.lh(Hm, x, self.obs_noise)

            # update the boundaries (with 0 and j changepoints)
            #             print('alpha, priorPrec=',alpha,priorPrec)
            ea = 1 - alpha / (j + priorPrec)
            eb = (j + alpha) / (j + priorPrec)
            #             print('ea,eb', ea, eb)
            joint_plus_new[0] = xp * ea * joint_plus_current[0]
            joint_minus_new[0] = xm * ea * joint_minus_current[0]
            joint_plus_new[j + 1] = xp * eb * joint_minus_current[j]
            joint_minus_new[j + 1] = xm * eb * joint_plus_current[j]
            #             if j == 2:
            #                 print('Hpn', joint_plus_new)
            #                 print('Hmn', joint_minus_new)
            # update the interior values
            if j > 0:
                vk = np.arange(2, j + 2);
                #                 print('vk',vk)
                ep = 1 - (vk - 1 + alpha) / (j + priorPrec)  # no change
                em = (vk - 2 + alpha) / (j + priorPrec)  # change
                #                 print('ep, em =', ep, em)
                #                 if j == 2:
                #                     print(xp)
                #                     print(xm)
                #                     print(joint_plus_current)
                #                     print(joint_minus_current)
                #                     print(vk)
                #                     print(joint_plus_current[vk - 1])
                #                     print(joint_minus_current[vk - 2])
                joint_plus_new[vk - 1] = xp * (np.multiply(ep, joint_plus_current[vk - 1]) +
                                               np.multiply(em, joint_minus_current[vk - 2]))
                joint_minus_new[vk - 1] = xm * (np.multiply(ep, joint_minus_current[vk - 1]) +
                                                np.multiply(em, joint_plus_current[vk - 2]))

                # sum probabilities in order to normalize
            #             if j == 2:
            #                 print('Hpn', joint_plus_new)
            #                 print('Hmn', joint_minus_new)
            Hs = joint_plus_new.sum() + joint_minus_new.sum()
            #             print('sum Hpn', joint_plus_new.sum())
            #             print('sum Hmn', joint_minus_new.sum())
            #             if j == 2:
            #                 print('Hs = ', Hs)
            joint_plus_current = joint_plus_new / Hs
            joint_minus_current = joint_minus_new / Hs
            #             if j == 2:
            #                 print(joint_plus_current)
            #                 print(joint_minus_current)
            Pp[:, j + 1] = joint_plus_current.copy()
            Pm[:, j + 1] = joint_minus_current.copy()
            # compute marginals over state if last iteration
            #             if j >= self.stimulus.nbins - 3:
            lp = joint_plus_current.sum()
            lm = joint_minus_current.sum()
            self.llr[j + 1] = np.log(lp / lm)
        # print('j',j)
        #             if j>0:
        #                 print('vk',vk)
        #             print('ea, eb',ea, eb)
        #             if j>0:
        #                 print('ep, em',ep, em)
        #             print('Hpn',joint_plus_new)
        #             print('Hmn',joint_minus_new)
        #             print('Hpc',joint_plus_current)
        #             print('Hmc',joint_minus_current)


        #         print(lp)
        #         print(lm)
        #         print(Pp)
        #         print(Pm)
        # compute decision (interrogate the system)
        if np.sign(np.log(lp / lm)) == -1:
            self.decision = Hm
        elif np.sign(np.log(lp / lm)) == 1:
            self.decision = Hp
        else:
            if np.random.uniform() < 0.5:
                self.decision = Hm
            else:
                self.decision = Hp

        # plot log posterior odds ratio trace
        if printLLR:
            #             plt.figure()
            plt.plot(np.arange(self.stimulus.nbins), self.llr, 'r-')
            plt.axhline(0, color='black')
            plt.title('log posterior odds ratio')
            plt.show()


# SET PARAMETERS
hazard_rates = [0.01]
hstep = 0.05
hh = hstep
while hh < 0.51:
    hazard_rates += [hh]
    hh += hstep

alpha = 1
beta = 1

SNR = []
stimstdev = []
snrstep = 0.2
snr = snrstep
while snr < 3.01:
    stdev = 2.0 / snr
    SNR += [snr]
    stimstdev += [stdev]
    snr += snrstep

dt = 1  # for discrete time

trial_durations = [50]
tdstep = 100
td = tdstep
while td < 2001:
    trial_durations += [td]
    td += tdstep
trial_durations = np.array(trial_durations)
nTrials = 10
singleTrialOutputs = [True, True, True]
multiTrialOutputs = [True, True, True]

np.random.seed()  # not sure this is the correct way to change the seed automatically
Expt = Experiment(setof_stim_noise=stimstdev, exp_dt=dt, setof_trial_dur=trial_durations,
                  setof_h=hazard_rates, tot_trial=nTrials)
Observer = IdealObs(dt=Expt.exp_dt, expt=Expt, prior_h=np.array([alpha, beta]))
aa = datetime.datetime.now().replace(microsecond=0)
Expt.launch(Observer, singleTrialOutputs, multiTrialOutputs)
bb = datetime.datetime.now().replace(microsecond=0)
print('total elapsed time in hours:min:sec is', bb - aa)
