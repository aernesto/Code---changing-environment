%produces the data .mat files required for panels C and D of figure 2

clear
%%%%%%%%%%%%%%%%%%%%
N=5000;                            %number of time steps
eps=.1;
m = 1;                             %mean of H^+ likelihood
res=1000;                          %number of points for posterior over eps
snr=.75;                           %difference in means divided by sd
sigma=2*m/snr; priorState=[.5;.5];
meana=zeros(1,N); meaneps=zeros(1,N);
epsX=linspace(0,1,res);           %x values for posterior over epsilon
am = zeros(N,1); sav = am;        %mean and scaled (by n) variance of a_n
epsm = am; ev=am;                 %mean and variance of posterior over eps

%Hpn below is the vector of joint probabilities (P_n(H^+,a))_a
%n and c stand for n and current respectively
Hpn = zeros(N,1);
Hpc = Hpn;
Hmn = Hpn; Hmc = Hpn;
lp = zeros(N,1);
lm = lp;
strue = m*(2*round(rand)-1);    %random initial state
envt=zeros(1,N);
envt(1)=strue;
storEps=ones(res,N);
x = strue+sigma*randn;
observations=zeros(1,N);
observations(1)=x;
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

%no need to initialize am and av since P_1(a) is delta function at 0.
%initialize statistics of posterior over eps according to flat Beta.
epsm(1)=.5; ev(1)=1/12;

%hyperparameters for hyperprior over epsilon
priorPrec=2; %a0+b0=priorPrec and a0/priorPrec=eps
a0=1;%priorPrec*eps;
b0=1;%priorPrec-a0;

%loop over time
for j=1:N-1
    
    % update the true state and changepoint count
    if rand<eps, strue=-strue; end
    envt(j+1)=strue;
    
    % make an observation
    x = strue+sigma*randn;
    observations(j+1)=x;
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
    
    % now compute statistics on change point count 'a'
    Hadd=Hpc+Hmc;
    margA(:,j+1)=Hadd;
    am(j+1) = (0:N-1)*Hadd;             %mean
    sav(j+1)=(0:N-1).^2*Hadd-am(j+1)^2; %variance
    sav(j+1)=sav(j+1)/(j+1);            %scaled
    
    % compute the posterior over epsilon
    beta=[betapdf(repmat(epsX',1,j+1),...
        repmat(0+a0:j+a0,res,1),...     %alpha parameter
        repmat(j+b0:-1:0+b0,res,1)),...
        zeros(res,N-j-1)];
    postEps=beta*Hadd;
    storEps(:,j+1)=postEps;
    dEps=1/(res-1);
    epsm(j+1)=dEps*epsX*postEps;
    ev(j+1)=dEps*(epsX.^2)*postEps-epsm(j+1)^2;
end
save('~/smallFig2.mat','observations','envt','am','sav',...
    'epsm','ev','res','eps','snr','-v7.3')
save('~/bigFig2.mat','margA','storEps','-v7.3')