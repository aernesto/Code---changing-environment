function P=jointPosteriorClicks(lTrain,rTrain)
% TODO: store joint posterior P 

% global variables
%global kappa     % proxy for SNR
global stimulusLength
global dt        % time bin width

% bin both trains and form matrix of observations
lBinTrain=binTrain(lTrain,dt,stimulusLength);
rBinTrain=binTrain(rTrain,dt,stimulusLength);
global obs
    obs=[lBinTrain,rBinTrain]; % each row is an observation: 00,01,10,11

N = length(lBinTrain); % total number of observations (i.e. time steps)

%Hpn below is the vector of joint probabilities (P_n(S^+,a))_a
%n and c stand for new and current respectively
Hpn = zeros(N,1);
Hpc = Hpn;
Hmn = Hpn; Hmc = Hpn;
lp = zeros(N,1);
lm = lp;

P=zeros(N,2,N); % change point counts x state x time

x = obs(1,:);

Hpc(1) = likelihoodClicks(x,true);
Hmc(1) = likelihoodClicks(x,false);

Fd = Hpc(1)+Hmc(1);
Hpc(1) = Hpc(1)/Fd;
Hmc(1) = Hmc(1)/Fd;
% lp(1) = Hpc(1);
% lm(1) = Hmc(1);

% store joint posterior
P(:,:,1)=[Hpc,Hmc];

%hyperparameters for hyperprior over epsilon
priorPrec=2; %a0+b0=priorPrec and a0/priorPrec=eps
a0=1;%priorPrec*eps;
b0=1;%priorPrec-a0;

%loop over time
for j=1:N-1
    
    % make an observation
    x = obs(j+1,:);
    %%CHANGE FOLLOWING TWO LINES
    xp = likelihoodClicks(x,true); %normalization constant absorbed in the global one
    xm = likelihoodClicks(x,false);
    
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
    
    % store joint posterior
    P(:,:,j+1)=[Hpc,Hmc];
end
end

function L = likelihoodClicks(xi,state)
% xi is a 1-by-2 vector containing 1 observation
% state is a boolean. true for S+ and false for S-
% L is a scalar likelihood

% in an interval of time dt, the number of events has distribution 
% Poisson(rate * dt)

global rate_high
global rate_low

X=[0;0;1;1]; % respective presence or absence of clicks
LAMBDA=[rate_high; rate_low; rate_high; rate_low];
pC=poisspdf(X,LAMBDA);

if isequal(xi,[0,0])
    L = pC(1)*pC(2);
elseif isequal(xi,[1,1])
    L = pC(3)*pC(4);
elseif state        % S+ = rate_high to right ear
    if isequal(xi,[0,1])
        L = pC(2)*pC(3);
    else
        L = pC(4)*pC(1);
    end
else                % S-
    if isequal(xi,[0,1])
        L = pC(1)*pC(4);
    else
        L = pC(3)*pC(2);
    end
end    
end