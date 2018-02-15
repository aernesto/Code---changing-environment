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
dt=1/10000;
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
posttimes=0.001:0.001:T;
%posttimes=[0.1:0.1:.9, posttimes];
posttimes(end)=T-2*dt;

fig=figure(1); 
SP=rTrain(1)*1000; %right click time in msec
ax1=subplot(1,2,1);
hold on
title('post H+')
ylabel('prob(H+)')
xlabel('msec')
xlim([0,11])
ylim([0,1.05])
line([SP SP],get(ax1,'YLim'),'Color',[1 0 0], 'LineWidth',2)
line(get(ax1,'XLim'),[0.5,.5],'Color',[0 0 0], 'LineWidth',1)
line(get(ax1,'XLim'),[1,1],'Color',[0 0 0], 'LineWidth',1)
ax1.FontSize=20;

ax2=subplot(1,2,2);
hold on 
title('post H-')
ylabel('prob(H-)')
xlabel('msec')
xlim([0,11])
ylim([0,1.05])
line([SP SP],get(ax2,'YLim'),'Color',[1 0 0], 'LineWidth',2)
line(get(ax2,'XLim'),[0.5,.5],'Color',[0 0 0], 'LineWidth',1)
line(get(ax2,'XLim'),[1,1],'Color',[0 0 0], 'LineWidth',1)
ax2.FontSize=20;

for snr=[4]
    rateHigh=getlambdahigh(rateLow, snr, true);
    [jointPost,unnorm]=returnPostH(lTrain, rTrain, rateLow, rateHigh, T, ...
    gamma_max, posttimes, priorState, alpha, beta, dt, cptimes);

    ax1=subplot(2,2,1);
    ax1.FontSize=20;
    hold on
    plot(1000*(posttimes), jointPost(1,:),'-bo','MarkerSize',10,'LineWidth',2)
    line([SP SP],[0,1],'Color',[1 0 0], 'LineWidth',2)
    line([0,10],[0.5,.5],'Color',[0 0 0], 'LineWidth',1)
    line([0,10],[1,1],'Color',[0 0 0], 'LineWidth',1)
    xlim([0,10])
    ylabel('posterior prob')
    title('H+, a=0')
    
    ax2=subplot(2,2,2);
    ax2.FontSize=20;
    hold on
    plot(1000*(posttimes), jointPost(gamma_max+1,:),'-bo','MarkerSize',10,...
        'LineWidth',2)
    line([SP SP],[0,1],'Color',[1 0 0], 'LineWidth',2)
    line([0,10],[0.5,.5],'Color',[0 0 0], 'LineWidth',1)
    line([0,10],[1,1],'Color',[0 0 0], 'LineWidth',1)
    title('H-, a=0')
    xlim([0,10])
    
    ax3=subplot(2,2,3);
    plot(1000*(posttimes), jointPost(2,:),'-o','LineWidth', ...
        3, 'MarkerSize',8)
    title('H+, a=1')
    xlim([0,10])
    ylabel('posterior prob')
    xlabel('msec')
    ax3.FontSize=20;
    
    ax4=subplot(2,2,4);
    plot(1000*(posttimes), jointPost(gamma_max+2,:),'-o','LineWidth', ...
        3, 'MarkerSize',8)
    xlim([0,10])
    xlabel('msec')
    title('H-, a=1')
    ax4.FontSize=20;
    
    %%%%%%%%%%%%%%%%%%%5
    % NOW PLOT SUBPLOTS FOR yp and ym!!!
end