%produces data .mat file necessary for panels A and B of figure 3

%parallel code that performs nSims simulations to compute the performance 
%of 3 types of models
%1. the correctly known rate model 
%2. the wrongly assumed rate model 
%3. the unknown rate model

function [correct]=paramRange_unknown(snr,nSims,finalTime)
%nSims=100,000 is reasonable

% datapath='~/MatlabCode/data/'; %path where you want to save the .mat file
% filename='paramRange';        %how you want to call the .mat file
%parallel pool settings

nTimePoints=1;               %number of points on curve
% nCores=19;                     %number of cores
% parpool(nCores);

%nSims=10000;%1000000;                  %number of sims at each time point
%finalTime=30;                 %last point of the curve (first is always 1)
timePoints=floor(linspace(finalTime,finalTime,nTimePoints)); %points for which 
                                                        %sims are run

%parameters explored by the panel
%rates=(0.01:.01:.5)';      %range of rates assumed by the observer 
                                %(i.e. number of curves - 1)
%snrs=.5;                       %could be a vector for exploration

%param=1;                      %can take values 1-length(rates)*length(snrs)

% paramMat=zeros(0,2);                %this matrix is trivial here, as only 
%                                         %1 true rate and snr are used
% for i=1:length(rates)
%     for j=1:length(snrs)
%         paramMat=[paramMat;[rates(i),snrs(j)]];
%     end
% end

%errEps=rates;
eps=.1;
%snr=paramMat(param,2);
%snr=snrs;
%nWrong=length(errEps);              %number of known rates assumed

%frequency of correct answers at each time point for unknown rate algorithm
correct=zeros(nTimePoints,1);

%frequency of correct answers at each time point for known rate algorithms
%correctk=zeros(nWrong,nTimePoints);
m = 1;                      %half the distance between means of likelihoods

sigma=2*m/snr;              %sd of likelihoods
%priorState=[.5;.5];         %prior on each state H^\pm
%priorRatio=priorState(1)/priorState(2);

%hyperparameters for hyperprior over epsilon
priorPrec=2;                %a0+b0=priorPrec and a0/priorPrec=eps
a0=1;                       %priorPrec*eps;
%b0=1;                       %priorPrec-a0;

%start loop on time points
c=1;
N=timePoints(c);       %time at which each simulation stops.
freqU=0;              %frequency of correct responses for unknown rate
%freqK=zeros(nWrong,1);%frequencies of correct responses for known rates
%loop over sims
for s=1:nSims
%initialize variables
Hpn = zeros(N,1); Hpc = Hpn; Hmn = Hpn; Hmc = Hpn;
%generate first state randomly
    if rand<.5
        strue=m;
    else
        strue=-m;
    end
%make an observation
x = strue+sigma*randn;

%compute likelihoods
%xp=exp(-(x-m)^2/(2*sigma^2));
%xm=exp(-(x+m)^2/(2*sigma^2));

%algorithm for unknown rate - first time step
%compute joint probabilities over state and change point count
        Hpc(1) = exp(-(x-m)^2/(2*sigma^2));
        Hmc(1) = exp(-(x+m)^2/(2*sigma^2));
        Fd = Hpc(1)+Hmc(1);
        Hpc(1) = Hpc(1)/Fd;
        Hmc(1) = Hmc(1)/Fd;
        %compute marginals over state
        lp = Hpc(1);
        lm = Hmc(1);

%known rate algorithms - first time step
%ld=priorRatio*ones(nWrong,1);%first entry used for the true rate
%ld=xp/xm*((1-errEps).*ld+errEps)./(errEps.*ld+1-errEps);

    %pursue the algorithms if the interrogation time is >1     
    %loop over time
    for j=1:N-1
        %update the true state
        if rand<eps
            strue=-strue;
        end

        % make an observation
        x = strue+sigma*randn;
        %compute likelihoods
        xp = exp(-(x-m)^2/(2*sigma^2));
        xm = exp(-(x+m)^2/(2*sigma^2));

        %specifics of unknown rate algorithm
        % update the boundaries (with 0 and j changepoints)
                ea = 1-a0/(j-1+priorPrec);
                eb= (j-1+a0)/(j-1+priorPrec);
                Hpn(1) = xp*ea*Hpc(1);
                Hmn(1) = xm*ea*Hmc(1);
                Hpn(j+1) = xp*eb*Hmc(j);
                Hmn(j+1) = xm*eb*Hpc(j);
                
                % update the interior values
                if j>1
                    vk = (2:j)';
                    ep = 1-(vk-1+a0)/(j-1+priorPrec);   %no change
                    em=(vk-2+a0)/(j-1+priorPrec);       %change
                    Hpn(vk) = xp*(ep.*Hpc(vk)+em.*Hmc(vk-1));
                    Hmn(vk) = xm*(ep.*Hmc(vk)+em.*Hpc(vk-1));
                end
                
                % sum probabilities in order to normalize
                Hs = sum(Hpn)+sum(Hmn);
                Hpc=Hpn/Hs;
                Hmc=Hmn/Hs;
                
                %compute marginals over state if last iteration
                if j==N-1
                    lp = sum(Hpc); lm = sum(Hmc);
                end

        %update evidence for known rate algorithms
        %ld=xp/xm*((1-errEps).*ld+errEps)./(errEps.*ld+1-errEps);            
    end

    %compute decisions (interrogate the system)
            decvaru=m*sign(log(lp/lm));
            if decvaru==strue
                freqU=freqU+1;           %count correct answers
            end
    %decision variable for known rates
    %decvark=m*sign(log(ld));
%     for ii=1:nWrong
%         if decvark(ii)==strue
%             freqK(ii)=freqK(ii)+1;
%         end
%     end
end
     correct(c)=freqU;
     correct=correct/nSims;
%correctk(:,c)=freqK;

    
%rows=1:size(errEps,1);
%lastrow=rows(errEps==max(errEps));
%finalPoints=correctk(1:lastrow(1),nTimePoints)/nSims;
%x1=errEps(1:lastrow(1));
%y1=finalPoints;
%x2=eps;
%y2=finalPoints(abs(errEps-eps)<0.0001);
%save([datapath,filename,'.mat'],'-v7.3')

% %shut pool of workers down
% poolobj = gcp('nocreate');
% delete(poolobj);


%%%%%%            PLOT
% fig1=figure;
% %fig1.Visible='off';
% 
% currimagepath='/Users/aeradillo/Pictures/phd/inference/grantJosh/'; %where to save the image
% currfilename='paramRange';
% 
% %parameters
% fss=12;      %small font
% fsb=17;     %big font
% lwb=1.5;    %big line width
% lws=1;   %small line width
% aw=1;     %axis line width
% ymin=0.48;
% 
% %sB=subplot(1,3,2);
% hold on
% 
% % %plot performance of the unknown rate algorithm at different times
% % times=[40,100,200,300];
% % indices=1:nTimePoints;
% % 
% % blueshades=gobjects(length(times),1);
% % for jj=1:length(times)
% %     t=indices(timePoints==times(jj));
% %     yval=correct(t);
% %     blueshades(jj)=plot([min(errEps),max(errEps)],[yval,yval]/nSims,...
% %         'LineWidth',lws);
% %     %text(.3,yval/nSims,['n=',num2str(timePoints(times(jj)))],...
% %      %   'HorizontalAlignment','right','FontSize',12)
% % end
% % 
% % blueshades(4).Color=[0,0,0];
% % blueshades(3).Color=[1,1,1]/8;
% % blueshades(2).Color=[1,1,1]/4;
% % blueshades(1).Color=[1,1,1]*3/8;
% %alpha(blueshades,0.3) line objects do not support transparancy
% 
% %plot performance of the known rate algorithm 
% plot(errEps(1:lastrow(1)),finalPoints,'Color',[0,3.2,0]/4,...
%     'LineWidth',lwb)
% %plot best performance when rate is known
% yyy=finalPoints(abs(errEps-eps)<0.0001);
% plot(eps,yyy,'*r','MarkerSize',8,'LineWidth',lws)
% hold off
% 
% title(['performance as a function of the assumed rate; $\epsilon=$',...
%     num2str(eps),'; snr$=$',...
%     num2str(snr)],...
%     'Interpreter','latex')
% xlabel('assumed $\epsilon$','Interpreter','latex')
% ylabel('percentage correct','Interpreter','latex')
% 
% % legend({'uknown rate n=40',...
% %     'uknown rate n=100',...
% %     'uknown rate n=200',...
% %     'uknown rate n=300','assumed rates','true rate'},...
% %     'Location','southwest','FontSize',fss,'Box','off',...
% %     'Interpreter','latex')
% 
% sB=gca;
% sB.FontSize=fsb;
% sB.TickLabelInterpreter='latex';
% sB.LineWidth=aw;
% sB.Box='off';
% sB.XLim=[0.01,0.5];
% sB.XTick=[.01,0.1,.25,.5];
% sB.YLim=[ymin,1];
% sB.YTick=[ymin,.85];
% %sB.ActivePositionProperty='OuterPosition';
% %sB.OuterPosition=[8/27+tiny,0,7/27,1];
% %replace previous legend by text in the plot
% 
% %printing/saving output as png file
% % rez=200; %resolution (dpi) of final graphic
% % figpos=getpixelposition(fig1); %dont need to change anything here
% % resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
% % set(fig1,'paperunits','inches','papersize',figpos(3:4)/resolution,...
% % 'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
% % print(fig1,fullfile(currimagepath,currfilename),'-dpng',['-r',num2str(rez)]) %save file 
% 
% 


end