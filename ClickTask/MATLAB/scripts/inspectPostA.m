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
tic
%% set parameters
% click rates in Hz
rateLow=0.01;

% time step for forward Euler, in sec
dt=1/1000000;
% max allowed change point count
allgammas=2:10;

% hyperparameters for Gamma dist over hazard rate
alpha=1;
priorState=[.5,.5];

%trial duration (sec)
T=0.010; %10 msec

%% generate stimulus
lTrain=[];
rTrain=0.005; % right before 5 msec
cptimes=0.004;


%% call ODE function
%posttimes=1:50;
posttimes=T;
%posttimes=[0.1:0.1:.9, posttimes];
posttimes(end)=T-2*dt;
msect=1000*posttimes;

PA0=zeros(1,length(allgammas));
PA1=PA0;
PAMORE=PA0;
priorVar=1;
snr=1;
beta = alpha / sqrt(priorVar);
rateHigh=getlambdahigh(rateLow, snr, true);
for i=1:length(allgammas)
    gamma_max=allgammas(i);
    % perform inference
    [jointPost,~]=returnPostH(lTrain, rTrain, rateLow, rateHigh, T, ...
        gamma_max, posttimes, priorState, alpha, beta, dt, cptimes);
    %compute marginal over CP count
    marginalCPcount=jointPost(1:gamma_max,:)+...
        jointPost(gamma_max+1:end,:); % dim = CPcount x TimeSteps
    PA0(i)=marginalCPcount(1,:);
    PA1(i)=marginalCPcount(2,:);
    PAMORE(i)=sum(marginalCPcount(3:end,:),1);
end


fig=figure(1);  

ax1=subplot(3,1,1);
plot(allgammas,PA0,'o','MarkerSize',10,'LineWidth',2)
ylim([-0.1,1.1])
title('Pr(a=0) at 10msec')
ylabel('Prob')
ax1.FontSize=20;
grid on

ax2=subplot(3,1,2);
plot(allgammas,PA1,'o','MarkerSize',10,'LineWidth',2)
ylim([-0.1,1.1])
title('Pr(a=1) at 10msec')
ylabel('Prob')
ax2.FontSize=20;
grid on

ax3=subplot(3,1,3);
plot(allgammas,PAMORE,'o','MarkerSize',10,'LineWidth',2)
ylim([-0.1,1.1])
title('Pr(a>1) at 10msec')
ylabel('Prob')
xlabel('max CP cap')
ax3.FontSize=20;
grid on

toc