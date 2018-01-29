% Global script administering the simulation
clear
% random number generator, randomly choose the seed 
rng('shuffle')


% global variables
global rate_low
    rate_low=0.01;
    
global rate_high
    rate_high=38;
    
global kappa
    kappa=log(rate_high/rate_low);
    
global stimulusLength
    stimulusLength=.5;
    
global dt       % time step for time discretization
    dt=0.5*1e-3;   % 0.5 msec
    
global h    % hazard rate, in Hz
    h=4;
    
global obs  % to be computed later
global N    % to be computer later
tic
load('/home/radillo/Git/GitHub/LearningClicksTask/data/ClickTrains_h4_rateHigh38_rateLow001_nTrials1_SHORT.mat')
% number of distinct trial durations in the data array
N=size(data,1);
% get single trial from longest trial duration (3 sec)
clicksCell=data{N,1};
% total number of available trials for this trial duration
nTrials = length(clicksCell);
trial = 1; % select first trial for now
[lTrain,rTrain, ct]=clicksCell{trial, 1:3};


% Generate the environment
%[ct,E]=genClickEnvt();              % this only decides on S+ versus S-

% Generate the observations
%[lTrain,rTrain]=genClickObs(ct,E);  % this produces the click trains

% if you want to visualize the clicks
figure(10) 
plotClickTrains(lTrain,rTrain,ct)

% perform inference
P=jointPosteriorClicks(lTrain,rTrain);
toc

% extract portion of stimulus that contains both 01 and 10 observations
wSize = 8; % sliding window size
startIdx = 12;
endIdx = 17;
found = false;
% while (endIdx < N) && (~found)
%     window=obs(startIdx:endIdx,:);
%     found = sum(ismember([0,1;1,0],window,'rows')) > 1;
%     if found
%         break
%     end
%     startIdx = endIdx + 1;
%     endIdx = endIdx + wSize;
% end
% endIdx = startIdx + 1;
% if ~found
%     fprintf(['no window with 10 and 01 close enough was found\n',...
%         'default back to window centered at change point\n'])
%     startIdx = floor(ct(1)/dt);
%     endIdx = startIdx+wSize;
% end


% plot joint posterior

% figure
% plotClicksJointPosterior(P,[startIdx,endIdx])

plot2DClicksJointPosterior(P,[startIdx,endIdx])

% compute posterior mean over change point count
mean_cpc = meanPostCPClicks(P); %mean change point count

% plot posterior mean of change point count
figure
plot((1:length(mean_cpc))*dt,mean_cpc,'LineWidth',3);
title('Posterior mean of change point count')
xlabel('sec')
ylabel('change point count')
ax = gca;
ax.FontSize=20;


