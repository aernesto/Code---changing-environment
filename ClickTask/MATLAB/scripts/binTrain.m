function bt=binTrain(T,dt,totalTime)
%bins a Poisson train T into bins of width dt, up until totalTime
%dt and totalTime expressed in seconds
%returns an error if dt doesn't divide totalTime

%%WARNING
% this code doesn't check whether more than one event falls in the 
% same bin, and when this occurs, the bin value is still 1.

if mod(totalTime,dt)
    error('the bin width must divide total time')
else
    L=int64(totalTime/dt); %total number of bins
    binTimes=(1:L)*dt; %times in sec of right-endpoints of bins
    bt=zeros(L,1);  %binary vector with as many entries as bins.
    for i=1:length(T) %loop over events times in the train
        eventTime=T(i);
        %the following is a bolean vector lighting up all bins
        %corresponding to times greater than the event time
        binLog=binTimes >= eventTime;
        binIdx=find(binLog,1);  %bin index where event occurred
        bt(binIdx)=1;   %set bin value to 1
    end
end
end