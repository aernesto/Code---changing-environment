Aim of simulation is to decide whether or not a feedback about the  
state at the end of a trial improves the precision about the inferred  
hazard rate.  

Only investigate discrete time to start with.    

Fix the total number of observations per trial:  
50  
100  
200  
300  
...  
2,000  

Fix the values of hazard rate to test:  
0.01  
0.05  
0.1  
0.15  
0.2  
0.25  
...  
0.5  

Fix the SNR values to test:  
0.2  
0.4  
0.6  
0.8  
1  
...  
3  

Generate 10,000 trials for each triplet (ntrial, h, SNR). Run  
two ideal-observer models on each trial, which differ only in  
their integration of the feedback info. One takes it into account,  
the other doesn't.  

For each trial, record:  
the triplet (ntrial, h, SNR)  
the true (initial-state, end-state) pair  
the seed to generate the observation train  
the prior hyperparameters over h   
the joint posterior at interrogation time  
the posterior variance and mean over h  

