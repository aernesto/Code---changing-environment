%produces data .mat file necessary for panels A and B of figure 3

%parallel code that performs nSims simulations to compute the performance 
%of 3 types of models
%1. the correctly known rate model 
%2. the wrongly assumed rate model 
%3. the unknown rate model

function [x1,y1,x2,y2]=paramRange(snr,nSims)

nTimePoints=1;               %number of points on curve

finalTime=300;                 %last point of the curve (first is always 1)
timePoints=floor(linspace(finalTime,finalTime,nTimePoints)); %points for which 
                                                        %sims are run
%parameters explored by the panel
rates=(0:.01:.5)';      %range of rates assumed by the observer 

errEps=rates;
eps=.1;
%snr=paramMat(param,2);
%snr=snrs;
nWrong=length(errEps);              %number of known rates assumed

%frequency of correct answers at each time point for known rate algorithms
correctk=zeros(nWrong,nTimePoints);
m = 1;                      %half the distance between means of likelihoods

sigma=2*m/snr;              %sd of likelihoods
priorState=[.5;.5];         %prior on each state H^\pm
priorRatio=priorState(1)/priorState(2);

%start loop on time points
c=1;
N=timePoints(c);       %time at which each simulation stops.
%freqU=0;              %frequency of correct responses for unknown rate
freqK=zeros(nWrong,1);%frequencies of correct responses for known rates
%loop over sims
for s=1:nSims
    if rand<.5
        strue=m;
    else
        strue=-m;
    end
%make an observation
x = strue+sigma*randn;

%compute likelihoods
xp=exp(-(x-m)^2/(2*sigma^2));
xm=exp(-(x+m)^2/(2*sigma^2));

%known rate algorithms - first time step
ld=priorRatio*ones(nWrong,1);%first entry used for the true rate
ld=xp/xm*((1-errEps).*ld+errEps)./(errEps.*ld+1-errEps);

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

        %update evidence for known rate algorithms
        ld=xp/xm*((1-errEps).*ld+errEps)./(errEps.*ld+1-errEps);            
    end

    %decision variable for known rates
    decvark=m*sign(log(ld));
    for ii=1:nWrong
        if decvark(ii)==strue
            freqK(ii)=freqK(ii)+1;
        end
    end
end
correctk(:,c)=freqK;

    
rows=1:size(errEps,1);
lastrow=rows(errEps==max(errEps));
finalPoints=correctk(1:lastrow(1),nTimePoints)/nSims;
x1=errEps(1:lastrow(1));
y1=finalPoints;
x2=eps;
y2=finalPoints(abs(errEps-eps)<0.0001);
end