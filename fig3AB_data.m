%produces data .mat file necessary for panels A and B of figure 3

%parallel code that performs nSims simulations to compute the performance 
%of 3 types of models
%1. the correctly known rate model 
%2. the wrongly assumed rate model 
%3. the unknown rate model

clear
datapath='~/MatlabCode/data/'; %path where you want to save the .mat file
filename='fig3AB';        %how you want to call the .mat file
%parallel pool settings
nCores=19;                     %number of cores
nTimePoints=200;               %number of points on curve
parpool(nCores);
tic
nSims=1000000;                  %number of sims at each time point
finalTime=300;                 %last point of the curve (first is always 1)
timePoints=floor(linspace(1,finalTime,nTimePoints)); %points for which 
                                                        %sims are run

%parameters explored by the panel
rates=(0.01:.01:.5)';      %range of rates assumed by the observer 
                                %(i.e. number of curves - 1)
snrs=1;                       %could be a vector for exploration

param=1;                      %can take values 1-length(rates)*length(snrs)

% paramMat=zeros(0,2);                %this matrix is trivial here, as only 
%                                         %1 true rate and snr are used
% for i=1:length(rates)
%     for j=1:length(snrs)
%         paramMat=[paramMat;[rates(i),snrs(j)]];
%     end
% end

errEps=rates;
eps=.05;
%snr=paramMat(param,2);
snr=snrs;
nWrong=length(errEps);              %number of known rates assumed
%frequency of correct answers at each time point for unknown rate algorithm
correct=zeros(nTimePoints,1);
%frequency of correct answers at each time point for known rate algorithms
correctk=zeros(nWrong,nTimePoints);
m = 1;                      %half the distance between means of likelihoods

sigma=2*m/snr;              %sd of likelihoods
priorState=[.5;.5];         %prior on each state H^\pm
priorRatio=priorState(1)/priorState(2);

%hyperparameters for hyperprior over epsilon
priorPrec=2;                %a0+b0=priorPrec and a0/priorPrec=eps
a0=1;                       %priorPrec*eps;
b0=1;                       %priorPrec-a0;

%start loop on time points
parfor c=1:nTimePoints
    rng('shuffle')        %not sure this is the right place for this command
    N=timePoints(c)       %time at which each simulation stops.
    freqU=0;              %frequency of correct responses for unknown rate
    freqK=zeros(nWrong,1);%frequencies of correct responses for known rates
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
        
        %algorithm for unknown rate - first time step
        %compute likelihoods
        xp=exp(-(x-m)^2/(2*sigma^2));
        xm=exp(-(x+m)^2/(2*sigma^2));
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
        ld=priorRatio*ones(nWrong,1);%first entry used for the true rate
        ld=xp/xm*((1-errEps).*ld+errEps)./(errEps.*ld+1-errEps);
        
        %compute decision if interrogation time is N==1
        if N==1
            %decision variable for unknown rate algorithm
            decvaru=m*sign(log(lp/lm));
            if decvaru==strue
                freqU=freqU+1;
            end
            
            decvark=m*sign(log(ld));
            for ii=1:nWrong
                if decvark(ii)==strue
                    freqK(ii)=freqK(ii)+1;
                end
            end
        else       
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
                ld=xp/xm*((1-errEps).*ld+errEps)./(errEps.*ld+1-errEps);            
            end
            
            %compute decisions (interrogate the system)
            decvaru=m*sign(log(lp/lm));
            if decvaru==strue
                freqU=freqU+1;           %count correct answers
            end
            %decision variable for known rates
            decvark=m*sign(log(ld));
            for ii=1:nWrong
                if decvark(ii)==strue
                    freqK(ii)=freqK(ii)+1;
                end
            end
        end
    end
    correct(c)=freqU;
    correctk(:,c)=freqK;
end

save([datapath,filename,'.mat'],'-v7.3')

%shut pool of workers down
poolobj = gcp('nocreate');
delete(poolobj);
