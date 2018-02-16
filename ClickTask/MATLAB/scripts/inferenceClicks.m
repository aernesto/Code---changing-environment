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
    dt=1e-4;   % 0.1 msec
msect=1000*(dt:dt:stimulusLength);
global h    % hazard rate, in Hz
    h=4;
global alpha
    alpha=1;
global beta
    
global obs  % to be computed later
global N    % to be computer later
%create artificial stimulus
lTrain=[];%.006;
rTrain=[.005];           
ct=0.004;

fig=figure(1);  
SP=rTrain(1)*1000; %right click time in msec
for priorVar=1:3
    for snr=1:4
        i=sub2ind([4,3],snr,priorVar);
        ax=subplot(3,4,i);
        grid on
        hold on
        beta = alpha / sqrt(priorVar);
        rate_high=getlambdahigh(rate_low, snr, true);
        % perform inference
        P=jointPosteriorClicks(lTrain,rTrain);
        %compute marginal over CP count
        marginalCPcount=squeeze(sum(P,2)); % dim = CPcount x TimeSteps
        meanCPcount=(0:size(P,1)-1)*marginalCPcount;
        stdevCPcount=sqrt(((0:size(P,1)-1).^2)*marginalCPcount-meanCPcount.^2);
        % plot marginal
        plot(msect, meanCPcount,'-b',...
             msect,meanCPcount+stdevCPcount,'-k',...
             msect,max(meanCPcount-stdevCPcount,0),'-k',...
            'LineWidth', 3)
        line([SP,SP],get(ax,'ylim'),'Color',[4,2,3]/4,'LineWidth',2)
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