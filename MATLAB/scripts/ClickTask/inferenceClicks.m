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
    dt=1e-3;   % 50 msec
    
global h    % hazard rate, in Hz
    h=5;
    
global obs  % to be computed later
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

% extract portion of stimulus that contains both 01 and 10 observations
nObs=size(obs,1);
wSize = 8; % sliding window size
startIdx = 1;
endIdx = wSize;
found = false;
while (endIdx < nObs) && (~found)
    window=obs(startIdx:endIdx,:);
    found = sum(ismember([0,1;1,0],window,'rows')) > 1;
    if found
        break
    end
    startIdx = endIdx + 1;
    endIdx = endIdx + wSize;
end
endIdx = endIdx + 1;

% plot joint posterior
figure
plotClicksJointPosterior(P,[startIdx,endIdx])


