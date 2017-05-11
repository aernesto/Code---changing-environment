function perf = perfDeltaPrior(snr,T,h,nSims)
% computes the posterior of an ideal-observer over the state, 
% for a 2-state changing envt with symmetric rates

m = 1;                      %half the distance between means of likelihoods

sigma=2*m/snr;              %sd of likelihoods
priorState=[.5;.5];         %prior on each state H^\pm
priorRatio=priorState(1)/priorState(2);

N=T;       %time at which each simulation stops.
%freqU=0;              %frequency of correct responses for unknown rate
freqK=0;%frequencies of correct responses for known rates
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
ld=priorRatio;%first entry used for the true rate
ld=xp/xm*((1-h)*ld+h)/(h*ld+1-h);

    %pursue the algorithms if the interrogation time is >1     
    %loop over time
    for j=1:N-1
        %update the true state
        if rand<h
            strue=-strue;
        end

        % make an observation
        x = strue+sigma*randn;
        %compute likelihoods
        xp = exp(-(x-m)^2/(2*sigma^2));
        xm = exp(-(x+m)^2/(2*sigma^2));

        %update evidence for known rate algorithms
        ld=xp/xm*((1-h)*ld+h)/(h*ld+1-h);            
    end

    %decision variable for known rates
    decvark=m*sign(log(ld));

    if decvark == strue
        freqK = freqK+1;
    end

end
perf = freqK / nSims;
end