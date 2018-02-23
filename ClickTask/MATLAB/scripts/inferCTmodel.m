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
m=1; % mode of prior on h
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
varlist=[.1,5];
nv=length(varlist);
snrlist=[1,4];
ns=length(snrlist);
for priorVar_idx=1:nv
    priorVar=varlist(priorVar_idx);
    for iii=1:ns
        snr=snrlist(iii);
        i=sub2ind([nv,ns],iii,priorVar_idx);
        ax=subplot(nv,ns,i);
        grid on
        hold on
        v=priorVar; % prior variance
        beta = m / (2 * v) + sqrt(m^2 / (v^2) + 4 / v) / 2;  
        alpha = m * beta + 1;

        rateHigh=getlambdahigh(rateLow, snr, true);
        % perform inference
        [jointPost,~]=returnPostH(lTrain, rTrain, rateLow, rateHigh, T, ...
    gamma_max, posttimes, priorState, alpha, beta, dt, cptimes, expRate);
        %compute marginal over state H+
        postHp=sum(jointPost(1:gamma_max,:),1);
        %compute marginal over CP count
        %marginalCPcount=jointPost(1:gamma_max,:)+...
        %    jointPost(gamma_max+1:end,:); % dim = CPcount x TimeSteps
        %meanCPcount=(0:gamma_max-1)*marginalCPcount;
        %stdevCPcount=sqrt(((0:gamma_max-1).^2)*marginalCPcount-meanCPcount.^2);
        % plot marginal
        mylines=plot(msect, postHp,'-b',...
            'LineWidth', 3);
        ax.YLim=[0,1];
        %vertical lines for click times
        vl1=line([SP(1),SP(1)],get(ax,'ylim'),'Color',[4,2,3]/4,'LineWidth',2,'LineStyle','--');
        vl2=line([SP(2),SP(2)],get(ax,'ylim'),'Color',[2,3,4]/4,'LineWidth',2,'LineStyle','--');
        vl3=line([SP(3),SP(3)],get(ax,'ylim'),'Color',[2,3,4]/4,'LineWidth',2,'LineStyle','--');
        title(['SNR=',num2str(snr),', Var=',num2str(priorVar)])
        if snr==snrlist(1) & priorVar==varlist(1)
            legend([mylines(1);vl1;vl2],...
                'P(H+)','left click',...
                'right click',...
                'Location','NorthWest')
            legend BOXOFF
        end
        if snr==snrlist(1) 
            ylabel('Posterior H+')
        end
        if priorVar==varlist(end)
            xlabel('msec')
        end
        ax.FontSize=20;
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