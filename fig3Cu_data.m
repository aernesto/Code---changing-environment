%produce data for unknown rate curve of fig3C
%produces a .mat file

clear
datapath='~/MatlabCode/data/'; %where you want the .mat file to be saved
filename='fig3Cu';              %how the .mat file will be called
parpool(19);
N=5000;                 %number of time steps
nSims=100000;
prec=linspace(0.5,.98,400); %not the true precision
theta=log(prec./(1-prec));
nTheta=length(prec);

eps=.1;
m = 1;                            %mean of H^+ likelihood
snr=.75;                          %difference in means divided by sd
sigma=2*m/snr; 
priorState=[.5;.5];
hittingTimes=zeros(nSims,nTheta); %stores the hitting times
answers=false(nSims,nTheta);      %stores correctness of answers

%loop over sims
parfor sim=1:nSims
    rng('shuffle') %not sure whether this is the right place for this command
    indx=1:N;
    localAnswers=false(N,1); 
    Hpn = zeros(N,1);
    Hpc = Hpn;
    
    Hmn = Hpn; 
    Hmc = Hpn;
    
    decu=Hpn;                       %decision variable
    
    strue = m*(2*round(rand)-1);    %random initial state
    envt=zeros(1,N);
    envt(1)=strue;
    
    x = strue+sigma*randn;
    % observations=zeros(1,N);
    % observations(1)=x;
    xp=exp(-(x-m)^2/(2*sigma^2));
    xm=exp(-(x+m)^2/(2*sigma^2));
    Hpc(1) = xp;
    Hmc(1) = xm;
    Fd = Hpc(1)+Hmc(1);
    Hpc(1) = Hpc(1)/Fd;
    Hmc(1) = Hmc(1)/Fd;
    lp = Hpc(1);
    lm = Hmc(1);
    
    %decision variable
    decu(1)=log(lp/lm);  
    localAnswers(1)=sign(decu(1))==strue;
    
    %hyperparameters for hyperprior over epsilon
    priorPrec=2; %a0+b0=priorPrec and a0/priorPrec=eps
    a0=1;%priorPrec*eps;
    b0=1;%priorPrec-a0;
    
    
    %loop over time

    for j=1:N-1
        %if highest threshold crossed at time step 1, exit current for loop 
        if abs(decu(1))>max(theta)
            break
        end
        % update the true state and changepoint count
        if rand<eps, strue=-strue; end
        envt(j+1)=strue;
        
        % make an observation
        x = strue+sigma*randn;
        %observations(j+1)=x;
        xp = exp(-(x-m)^2/(2*sigma^2)); %normalization constant absorbed in the global one
        xm = exp(-(x+m)^2/(2*sigma^2));
        
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
            ep = 1-(vk-1+a0)/(j-1+priorPrec); %no change coef
            em=(vk-2+a0)/(j-1+priorPrec);   %change coef
            Hpn(vk) = xp*(ep.*Hpc(vk)+em.*Hmc(vk-1));
            Hmn(vk) = xm*(ep.*Hmc(vk)+em.*Hpc(vk-1));
        end
        
        % sum probabilities in order to normalize
        Hs = sum(Hpn)+sum(Hmn);
        Hpc=Hpn/Hs;
        Hmc=Hmn/Hs;
        lp=sum(Hpc);
        lm=sum(Hmc);
        
        %decision variable
        decu(j+1)=log(lp/lm);
        localAnswers(j+1)=sign(decu(j+1))==strue;
        
        %if highest threshold crossed, go to the hitting times storage part
        if abs(decu(j+1))>max(theta)
            break 
        end        
    end
    
    %store hitting times for this sim
    for th=1:nTheta
        if sum(abs(decu)>theta(th)) %threshold theta(th) has been crossed
            hittingTime=min(indx(abs(decu)>theta(th)));
            hittingTimes(sim,th)=hittingTime;
            answers(sim,th)=localAnswers(hittingTime);
        end
    end
end

perf=mean(answers); %size= 1 x nTheta
avgtimesu=mean(hittingTimes);

save([datapath,filename,'.mat'],'-v7.3')

