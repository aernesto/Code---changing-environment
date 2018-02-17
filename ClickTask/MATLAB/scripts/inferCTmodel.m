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
priorState=[.5,.5];

%trial duration (sec)
T=0.010; %10 msec

%% generate stimulus
lTrain=[];
rTrain=0.005; % right before 5 msec
cptimes=0.004;


%% call ODE function
%posttimes=1:50;
posttimes=0.0001:0.00001:T;
%posttimes=[0.1:0.1:.9, posttimes];
posttimes(end)=T-2*dt;
msect=1000*posttimes;

fig1=figure(1);  
%fig2=figure(2);
SP=rTrain(1)*1000; %right click time in ms
priorVar=1;
snr=1;
figure(fig1)
%i=sub2ind([4,3],snr,priorVar);
rates=[1,10,100];
for ii=1:length(rates)
    expRate=rates(ii);
    ax=subplot(1,3,ii);
    grid on
    hold on
    beta = alpha / sqrt(priorVar);
    rateHigh=getlambdahigh(rateLow, snr, true);
    % perform inference
    [jointPost,~,priorGamma]=returnPostH(lTrain, rTrain, rateLow, rateHigh, T, ...
        gamma_max, posttimes, priorState, alpha, beta, dt, cptimes,expRate);
    
    %compute marginal over CP count
    marginalCPcount=jointPost(1:gamma_max,:)+...
        jointPost(gamma_max+1:end,:); % dim = CPcount x TimeSteps
    meanCPcount=(0:gamma_max-1)*marginalCPcount;
    stdevCPcount=sqrt(((0:gamma_max-1).^2)*marginalCPcount-meanCPcount.^2);
    % plot marginal
    mylines=plot(msect, meanCPcount,'-b',...
        msect,meanCPcount+stdevCPcount,'-k',...
        msect,max(meanCPcount-stdevCPcount,0),'-k',...
        'LineWidth', 3);
    vertline=line([SP,SP],get(ax,'ylim'),'Color',[4,2,3]/4,'LineWidth',2);
    title(['decay rate=',num2str(expRate)])
    legend([mylines(1:2);vertline],...
        'mean','1 stdev','click time','Location','NorthWest')
    legend BOXOFF
    ylabel('CP count')
    xlabel('msec')
    ax.FontSize=20;
end
