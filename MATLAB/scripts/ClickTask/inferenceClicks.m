% Global script administering the simulation

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
    
% Generate the environment
S=genClickEnvt();


% Generate the observations
obs=genClickObs(S);


% perform inference
P=jointPosteriorClicks(obs);