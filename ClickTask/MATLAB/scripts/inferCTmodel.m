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
rateLow=10;

% time step for forward Euler, in sec
dt=1/1000000;
% max allowed change point count
gamma_max=20;
% hyperparameters for Gamma dist over hazard rate
m=1.5; % mean of prior on h
priorState=[.5,.5];

%trial duration (sec)
T=0.400; %400 msec

%% generate stimulus
lTrain=[0.100];
rTrain=[0.200,0.300]; % right before 5 msec
cptimes=0.150;


%% call ODE function
%posttimes=1:50;
posttimes=0.0001:0.00001:T;
%posttimes=[0.1:0.1:.9, posttimes];
posttimes(end)=T-2*dt;
msect=1000*posttimes;

expRate=1; %exponential decay to apply to initial mass on a at t=0
fig=figure(1);  
SP=[lTrain,rTrain]*1000; %click times in msec
%fig2=figure(2);
%fig1=figure(1);
varlist=[.1,5];
nv=length(varlist);
snrlist=[1,4];
ns=length(snrlist);
for priorVar_idx=1:nv
    priorVar=varlist(priorVar_idx);
    for iii=1:ns
        snr=snrlist(iii);
        % generate stimulus
        rateHigh=getlambdahigh(rateLow, snr, true);
        %data=genStimBank2(1,1,rateHigh,rateLow,T);
        % number of distinct trial durations in the data array
        %N=size(data,1);
        % get single trial from longest trial duration (3 sec)
        %clicksCell=data{N,1};
        % total number of available trials for this trial duration
        %nTrials = length(clicksCell);
        %trial = 1; % select first trial for now
        %[lTrain,rTrain, cptimes]=clicksCell{trial, 1:3};
        i=sub2ind([nv,ns],iii,priorVar_idx);
        ax=subplot(nv,ns,i);
        grid on
        hold on
        v=priorVar; % prior variance
        beta=m/v;
        alpha=beta*m;
        % If m = mode of prior
        %beta = m / (2 * v) + sqrt(m^2 / (v^2) + 4 / v) / 2;
        %alpha = m * beta + 1;
        
        % perform inference
        [jointPost,~,~,~,~,~]=returnPostH(lTrain, rTrain, rateLow, rateHigh, T, ...
            gamma_max, posttimes, priorState, alpha, beta, dt, cptimes, expRate);
        %compute marginal over state H+
        postHp=sum(jointPost(1:gamma_max,:),1);
        %compute marginal over CP count
        marginalCPcount=jointPost(1:gamma_max,:)+...
            jointPost(gamma_max+1:end,:); % dim = CPcount x TimeSteps
        meanCPcount=(0:gamma_max-1)*marginalCPcount;
        stdevCPcount=sqrt(((0:gamma_max-1).^2)*marginalCPcount-meanCPcount.^2);
        % plot marginal
        mylines=plot(msect, meanCPcount,'-b',...
             msect,meanCPcount+stdevCPcount,'-k',...
             msect,max(meanCPcount-stdevCPcount,0),'-k',...
            'LineWidth', 4);
        ax.YLim=[0,2.2];
        %vertical lines for click times
        vl1=line([SP(1),SP(1)],get(ax,'ylim'),'Color',[4,2,3]/4,'LineWidth',4,'LineStyle','--');
        vl2=line([SP(2),SP(2)],get(ax,'ylim'),'Color',[2,3,4]/4,'LineWidth',4,'LineStyle','--');
        vl3=line([SP(3),SP(3)],get(ax,'ylim'),'Color',[2,3,4]/4,'LineWidth',4,'LineStyle','--');
        title(['SNR=',num2str(snr),',     prior Var=',num2str(priorVar)])
        if snr==snrlist(1) & priorVar==varlist(1)
            legend([mylines(1:2);vl1;vl2],...
                'mean','1 stdev','left click',...
                'right click',...
                'Location','NorthWest')
            legend BOXOFF
        end
        if snr==snrlist(1) 
            ylabel('CP count')
        end
        if priorVar==varlist(end)
            xlabel('msec')
        end
        ax.FontSize=20;
        
        % append prior values for time point t=0
        %means=[alpha/beta,means];
        %vars=[alpha/beta^2,vars];
        %lbvar=[alpha/beta^2, lbvar];
        %posttimes_inloop=[0,posttimes];
        
%         figure(fig1)
%         ax=subplot(nv,ns,i);
%         grid on
%         hold on
%         %plot for posterior mean over h
%         plot(posttimes_inloop,means,'-b',[0,T],[1,1],'-r','LineWidth',3)
%         xlim([0,T])
%         ylim([0,max(means)+.5])
%         %vertical lines for CP times
%         for lll=1:length(cptimes)
%             line([cptimes(lll),cptimes(lll)],...
%                 get(ax,'ylim'),'Color',[0,0,0],...
%                 'LineWidth',2,'LineStyle','--');
%         end
%         ylabel('posterior mean','FontSize',18)
%         title(['mean h, ','SNR=',num2str(snr),', Var=',num2str(priorVar)],'FontSize',18)
%         legend('learned','true','change points')
%         %plot for posterior variance over h
%         figure(fig2)
%         ax=subplot(nv,ns,i);
%         grid on
%         hold on
%         plot(posttimes_inloop,vars,'-b',[0,cptimes'], lbvar,'*r','LineWidth',3);
%         xlim([0,T])
%         ylim([0,max(abs(vars))+.5]);
%         %vertical lines for CP times
% %         for lll=1:length(cptimes)
% %             line([cptimes(lll),cptimes(lll)],...
% %                 get(ax,'ylim'),'Color',[0,0,0],...
% %                 'LineWidth',2,'LineStyle','--');
% %         end
%         xlabel('time','FontSize',18)
%         ylabel('posterior var','FontSize',18)
%         legend('learned','explicit change points')
%         title(['var h, ','SNR=',num2str(snr),', Var=',num2str(priorVar)],'FontSize',18)
    end
end
toc















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