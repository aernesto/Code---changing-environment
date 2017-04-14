function obs=genClickObs(E,ct)
% generates the two trains of clicks that the rats hear

rTrain=zeros();
lTrain=zeros();
%loop over change point times
for tt=1:length(ct)-1 % remove artificial last value of ct
    rTrain=[rTraing;genPoissonTrain()]; %right-ear train
end

obs=[lTrain,rTrain];
end