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
posttimes=0.001:0.00001:T;
%posttimes=[0.1:0.1:.9, posttimes];
posttimes(end)=T-2*dt;
msect=1000*posttimes;

fig=figure(1);  
SP=rTrain(1)*1000; %right click time in msec
for priorVar=1:3
    for snr=1:4
        i=sub2ind([4,3],snr,priorVar);
        ax=subplot(3,4,i);
        grid on
        hold on
        beta = alpha / sqrt(priorVar);
        rateHigh=getlambdahigh(rateLow, snr, true);
        % perform inference
        [jointPost,~]=returnPostH(lTrain, rTrain, rateLow, rateHigh, T, ...
    gamma_max, posttimes, priorState, alpha, beta, dt, cptimes);
        %compute marginal over CP count
        marginalCPcount=jointPost(1:gamma_max,:)+...
            jointPost(gamma_max+1:end,:); % dim = CPcount x TimeSteps
        meanCPcount=(0:gamma_max-1)*marginalCPcount;
        stdevCPcount=((0:gamma_max-1).^2)*marginalCPcount-meanCPcount.^2;
        % plot marginal
        plot(msect, meanCPcount,'-b',...
             msect,meanCPcount+stdevCPcount,'-k',...
             msect,max(meanCPcount-stdevCPcount,0),'-k',...
            'LineWidth', 3)
        line([SP,SP],[0,0.04],'Color',[4,2,3]/4,'LineWidth',2)
        title(['SNR=',num2str(snr),', Var=',num2str(priorVar)])
        if snr==1 
            ylabel('CP count')
        end
        if priorVar==3
            xlabel('msec')
        end
        %ylim([0,0.04])
        ax.FontSize=20;
    end
end
















% 
% 
% fig=figure(1); 
% hax=axes;
% SP=rTrain(1)*1000; %right click time in msec
% hold on
% title('posterior prob of H+ as fcn of time')
% ylabel('posterior prob(H+)')
% xlabel('msec')
% xlim([0,11])
% ylim([0.49,1.05])
% line([SP SP],get(hax,'YLim'),'Color',[1 0 0], 'LineWidth',2)
% hax.FontSize=20;
% 
% for snr=[.5,1,2,4]
%     rateHigh=getlambdahigh(rateLow, snr, true);
%     [jointPost,unnorm]=returnPostH(lTrain, rTrain, rateLow, rateHigh, T, ...
%     gamma_max, posttimes, priorState, alpha, beta, dt, cptimes);
%     plot(1000*posttimes, sum(jointPost(1:gamma_max,:),1),'LineWidth',2)
% end
% legend('click time','snr=0.5','snr=1','snr=2','snr=4')
% line(get(hax,'XLim'),[0.5,.5],'Color',[0 0 0], 'LineWidth',1)
% line(get(hax,'XLim'),[1,1],'Color',[0 0 0], 'LineWidth',1)