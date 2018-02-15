% This script does the following:
%   1. generate the stimulus for 1 trial of the dynamic clicks task
%   2. evolve the full system with truncated gamma (CP count)
%   3. compute posterior over change point count at several time points
%   4. display a plot with two subplots described below
%       - raster plot of stimulus clicks, with change points marked
%       - posterior mean over CP count with 'error' bars shown at 1stdev
%
% REQUIRED SCRIPTS:
% returnPostH.m
% getlambdahigh.m

clear
%% set parameters
% click rates in Hz
rateLow=0.01;

% time step for forward Euler, in sec
dt=1/1000000;
% max allowed change point count
gamma_max=100;
% hyperparameters for Gamma dist over hazard rate
alpha=1;
beta=1;
priorState=[.5,.5];

%trial duration (sec)
T=0.010; %10 msec

%% generate stimulus
lTrain=[];
rTrain=0.0049; % right before 5 msec
cptimes=0.004;


%% call ODE function
%posttimes=1:50;
posttimes=0.001:0.00001:T;
%posttimes=[0.1:0.1:.9, posttimes];
posttimes(end)=T-2*dt;

fig=figure(1); 
hax=axes;
SP=rTrain(1)*1000; %right click time in msec
hold on
title('posterior prob of H+ as fcn of time')
ylabel('posterior prob(H+)')
xlabel('msec')
xlim([0,11])
ylim([0.49,1.05])
line([SP SP],get(hax,'YLim'),'Color',[1 0 0], 'LineWidth',2)
hax.FontSize=20;

for snr=[.5,1,2,4]
    rateHigh=getlambdahigh(rateLow, snr, true);
    [jointPost,unnorm]=returnPostH(lTrain, rTrain, rateLow, rateHigh, T, ...
    gamma_max, posttimes, priorState, alpha, beta, dt, cptimes);
    plot(1000*posttimes, sum(jointPost(1:gamma_max,:),1),'LineWidth',2)
end
legend('click time','snr=0.5','snr=1','snr=2','snr=4')
line(get(hax,'XLim'),[0.5,.5],'Color',[0 0 0], 'LineWidth',1)
line(get(hax,'XLim'),[1,1],'Color',[0 0 0], 'LineWidth',1)