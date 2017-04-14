function P=jointPosteriorClicks(obs, kappa)
%% TODO: store joint posterior P 
global N         % number of time steps

%Hpn below is the vector of joint probabilities (P_n(H^+,a))_a
%n and c stand for n and current respectively
Hpn = zeros(N,1);
Hpc = Hpn;
Hmn = Hpn; Hmc = Hpn;
lp = zeros(N,1);
lm = lp;

x = obs(1,:);

%%CHANGE FOLLOWING TWO LINES
Hpc(1) = exp(-(x-m)^2/(2*sigma^2));
Hmc(1) = exp(-(x+m)^2/(2*sigma^2));

Fd = Hpc(1)+Hmc(1);
Hpc(1) = Hpc(1)/Fd;
Hmc(1) = Hmc(1)/Fd;
lp(1) = Hpc(1);
lm(1) = Hmc(1);
Hadd=Hpc+Hmc;
margA=zeros(N);
margA(:,1)=Hadd;

%hyperparameters for hyperprior over epsilon
priorPrec=2; %a0+b0=priorPrec and a0/priorPrec=eps
a0=1;%priorPrec*eps;
b0=1;%priorPrec-a0;

%loop over time
for j=1:N-1
    
    % make an observation
    x = obs(j+1,:);
    %%CHANGE FOLLOWING TWO LINES
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
end
end