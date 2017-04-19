% Global script administering the simulation
clear
% random number generator, randomly choose the seed
rng('shuffle')

% global variables
global rate_low
    rate_low=2;
    
global rate_high
    rate_high=38;
    
global kappa
    kappa=log(rate_high/rate_low);
    
global stimulusLength
    stimulusLength=.5;
    
global dt       % time step for time discretization
    dt=50e-3;   % 50 msec
    
global h    % hazard rate, in Hz
    h=5;
tic
% Generate the environment
[ct,E]=genClickEnvt();              % this only decides on S+ versus S-

% Generate the observations
[lTrain,rTrain]=genClickObs(ct,E);  % this produces the click trains

% if you want to visualize the clicks
figure 
plotClickTrains(lTrain,rTrain,ct)

% perform inference
P=jointPosteriorClicks(lTrain,rTrain);
toc
% plot joint posterior
figure
plotClicksJointPosterior(P)


