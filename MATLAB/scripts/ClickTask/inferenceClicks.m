% Global script administering the simulation

% random number generator, randomly choose the seed
rng('shuffle')

% global variables
global rate_low
    rate_low=2;
    
global rate_high
    rate_high=38;
    
global kappa
    kappa=log(rate_high/rate_low);
    
global stimulusLength;
    stimulusLength=.5;
    
global h    % hazard rate, in Hz
    h=5;
    
for param = 1:4    
h = h + 2*param;    
% Generate the environment
[ct,E]=genClickEnvt();              % this only decides on S+ versus S-
% Generate the observations
[lTrain,rTrain]=genClickObs(ct,E);  % this produces the click trains
% if you want to visualize the clicks
subplot(2,2,param)
plotClickTrains(lTrain,rTrain,ct);
end


% perform inference
P=jointPosteriorClicks(obs);