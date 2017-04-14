function t=genPoissonTrain(rate,timeLength)
%generates poisson train of timeLength seconds with rate rate in Hz, 
%using the Gillespie algorithm.
t=zeros(10*rate*timeLength,1); %pre-allocate ten times the mean array size 
%for speed, will be shrinked after computation
totalTime=0;
eventIndex=0;
    while totalTime < timeLength
        sojournTime=exprnd(1/rate);
        totalTime=totalTime+sojournTime;
        eventIndex=eventIndex+1;
        t(eventIndex) = totalTime;
    end
%trim unused nodes
[~,I]=max(t);
t=t(1:I);
end