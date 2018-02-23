function [ct,E]=genClickEnvt(stimulusLength,h)
%returns two column vectors: 
    %ct contains the change point times
    %E of length length(ct)+1, contains the states S+ and S-, as 1 and 0
    %respectively.

ct=genPoissonTrain(h, stimulusLength); % generate change point times

E=zeros(length(ct)+1,1);
idx=1; % initialize idx for coming while loop

% draw initial state uniformly
initialState=round(rand); % 0 codes for S- ,1 for S+
E(idx)=initialState;

while idx < length(E)
    E(idx+1)=1-E(idx);  % switch state after each change point
    idx=idx+1;
end
end