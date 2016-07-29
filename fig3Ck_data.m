%produces the .mat data file required for panel C from figure C
%free response protocol performances for known rates. Code is not parallelized
clear

%%%%%%%%%%%%%%  PARAMETERS
datapath='~/matlabCode/data/';  %path where you want the .mat file to be saved
filename='fig3Ck';              %name of the produced .mat file
rng('shuffle');
%parpool(19);
N=5000;                         %maximum number of time steps
nSims=100000;                    %number of simulations
precision=linspace(.5,.99,400); %different precision levels
thresholds=log(precision./(1-precision));  %corresponding thresholds
maxThreshold=thresholds(end);   %maximum threshold
nThresholds=length(precision);  %number of thresholds
epsilon=.1;                     %true rate

rates=.05:.05:.4;               %true rate + wrongly assumed rates                                  
nRates=length(rates);           %number of assumed rates 
trueRateIndx=1:nRates;          %index of epsilon in rates
trueRateIndx=trueRateIndx(rates==epsilon);    
m = 1;                          %mean of H^+ likelihood
snr=.75;                          %difference in means divided by sd
sigma=2*m/snr;                  %sd of likelihoods
priorState=[.5;.5];             %prior prob. of each state

%%%%%%%%%%%%%%  STORAGE VARIABLES

%variables to store the hitting times and the correctness of the decisions
hittingTimes=zeros(nThresholds,nRates,nSims);   
answers=false(size(hittingTimes));
trueState=zeros(size(hittingTimes));

ld_init=priorState(1)/priorState(2);%initialize inference - used later

%%%%%%%%%%%%%%  LOOP OVER SIMS

for sim=1:nSims
    thresholdStart=1;               %index of first threshold to start exploring
    thresholdCrossed=false(nThresholds,nRates);
    decisionVariable=zeros(N,nRates); %To store the decision variable over time
                                %first column for true rate                             
    strue = m*(2*round(rand)-1);%random initial state
    ld=ld_init; %posterior odds ratio - at this stage a scalar
    
%%%%%%%%%%  LOOP OVER TIME

    ratesIndx=1:nRates;             %logical for rates to consider
    ratesLoop=rates(ratesIndx);     %rates to consider in the loops

    for t=1:N
        
        % update the true state and changepoint count
        if (rand<epsilon) && (t>1)
            strue=-strue;
        end

        % make an observation and compute likelihoods and lhratio
        x = strue+sigma*randn;
        xp = exp(-(x-m)^2/(2*sigma^2)); 
        xm = exp(-(x+m)^2/(2*sigma^2));
        lhratio=xp/xm;
        
        %update equation (now ld becomes a row vector of length(ratesLoop)
        ld=lhratio*((1-ratesLoop).*ld+ratesLoop)./(ratesLoop.*ld+1-ratesLoop);
        decisionVariable(t,ratesIndx)=log(ld); %update decision var at time t

        %decide for current set of rates
        decisions=sign(decisionVariable(t,ratesIndx));
            %settle ambiguous decisions at random 
            if prod(decisions)==0
                decisions(find(not(decisions)))=2*round(rand(1,length(ratesIndx)));
            end
            %expand dimensions to get 1 row per threshold
        %logicDecisions=zeros(nThresholds-thresholdStart+1,length(decisions),1);
        decisions=repmat(decisions,nThresholds-thresholdStart+1,1);
        
        %update thresholdCrossed matrix 
        thresholdsCompare=repmat(thresholds(thresholdStart:end)',...
            1,length(ratesIndx));    
        current=abs(repmat(decisionVariable(t,ratesIndx),...
            nThresholds-thresholdStart+1,1))>thresholdsCompare;
        old=thresholdCrossed(thresholdStart:end,ratesIndx);      
        justSwitched=current & not(old);
        thresholdCrossed(thresholdStart:end,ratesIndx)=old | justSwitched; 
        
        %store hitting times for each threshold and rate
        IND=find(justSwitched)';
        s=size(justSwitched);
        [rows,cols]=ind2sub(s,IND);
        
        decisionsToRecord=decisions(justSwitched);
        
        for kk=1:length(rows)
            rIndx=rows(kk)+thresholdStart-1;
            cIndx=ratesIndx(cols(kk));
            hittingTimes(rIndx,cIndx,sim)=t;
            trueState(rIndx,cIndx,sim)=strue;
            answers(rIndx,cIndx,sim)=decisionsToRecord(kk)==strue;
        end
        
        if thresholdCrossed
            break
        end
        %update variables for next loop iteration
        %smallest non-reached threshold=first row of thresholdCrossed
        %containing a zero - use find
        thresholdStart=find(not(prod(thresholdCrossed,2)),1);
        
        %rates for which we continue the simulation are those that 
            %have not yet reached the top threshold
        oldratesIndx=ratesIndx;
        ratesIndx=find(not(thresholdCrossed(end,:)));%logical indexing
        ratesLoop=rates(ratesIndx);
        ld=ld(ismember(oldratesIndx,ratesIndx));
    end
end

%%%%%%%%%%%%%%  FINAL PROCESSING

% average times for each threshold and rate
avgtimes=zeros(nThresholds,nRates);

%empirical precision for each threshold
empPrecision=avgtimes;
for ii=1:nRates
    avgtimes(:,ii)=mean(hittingTimes(:,ii,:),3);
    empPrecision(:,ii)=mean(answers(:,ii,:),3);
end

%%%%%%%%%%%%%%  SAVE WORKSPACE

save([datapath,filename,'.mat'],'-v7.3')

