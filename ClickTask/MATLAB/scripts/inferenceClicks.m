% Global script administering the simulation
clear
% random number generator, randomly choose the seed 
rng('shuffle')


% global variables
global rate_low
    rate_low=0.01;

global snr
global rate_high
    
global kappa
    kappa=log(rate_high/rate_low);
    
global stimulusLength
    stimulusLength=.010;  % 10 msec
    
global dt       % time step for time discretization
    dt=1e-3;   % 1 msec
    
global h    % hazard rate, in Hz
    h=4;
global alpha
    alpha=1;
global beta
    beta=1;
    
global obs  % to be computed later
global N    % to be computer later
%create artificial stimulus
lTrain=[];
rTrain=.0049;
ct=0.004;
%load('/home/radillo/Git/GitHub/LearningClicksTask/data/ClickTrains_h4_rateHigh26_rateLow14_nTrials1_LONG.mat')
% number of distinct trial durations in the data array
%N=size(data,1);
% get single trial from longest trial duration (3 sec)
%clicksCell=data{N,1};
% total number of available trials for this trial duration
%nTrials = length(clicksCell);
%trial = 1; % select first trial for now
%[lTrain,rTrain, ct]=clicksCell{trial, 1:3};


% Generate the environment
%[ct,E]=genClickEnvt();              % this only decides on S+ versus S-

% Generate the observations
%[lTrain,rTrain]=genClickObs(ct,E);  % this produces the click trains

% if you want to visualize the clicks
%figure(10) 
%plotClickTrains(lTrain,rTrain,ct)


fig=figure(1); 
hax=axes; 
hold on 
SP=rTrain(1)*1000; %right click time in msec
for snr=[.5,1,2,4]
    rate_high=getlambdahigh(rate_low, snr, true);
% perform inference
    P=jointPosteriorClicks(lTrain,rTrain);
%compute marginal over state
    marginalState=squeeze(sum(P,1)); % dim = StateNb x TimeSteps

% plot marginal
    plot(1000*(dt:dt:stimulusLength), marginalState(1,:),'-o','LineWidth', ...
        3, 'MarkerSize',4)
end
title('posterior prob of H+ as fcn of time')
ylabel('posterior prob(H+)')
xlabel('time within stimulus (msec)')
xlim([0,11])
ylim([0.45,1.05])
line([SP SP],get(hax,'YLim'),'Color',[1 0 0], 'LineWidth',2)
line(get(hax,'XLim'),[0.5,.5],'Color',[0 0 0], 'LineWidth',1)
line(get(hax,'XLim'),[1,1],'Color',[0 0 0], 'LineWidth',1)
legend('snr=0.5','snr=1','snr=2','snr=4','click time', 'Location', 'east')
% extract portion of stimulus that contains both 01 and 10 observations
%wSize = 8; % sliding window size
%startIdx = 1;
%endIdx = wSize;
%found = false;
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

%plot2DClicksJointPosterior(P,[startIdx,endIdx])

% compute posterior mean over change point count
%mean_cpc = meanPostCPClicks(P); %mean change point count

% plot posterior mean of change point count
%figure
%plot((1:length(mean_cpc))*dt,mean_cpc,'LineWidth',3);
%title('Posterior mean of change point count')
%xlabel('sec')
%ylabel('change point count')
ax = gca;
ax.FontSize=20;
% savefile='dt05msec2614.mat';
% ttime=(1:length(mean_cpc))*dt;
% save(savefile, 'mean_cpc','ttime')
