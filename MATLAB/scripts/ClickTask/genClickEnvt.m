function [E,ct]=genClickEnvt()
%returns a column vector 
global stimulusLength
global h

ct=genPoissonTrain(h, stimulusLength);
ct=[ct;-1]; %a negative value is appended to ct only to give it the same 
%size as E

E=zeros(size(ct));
idx=1; % initialize idx for coming while loop

% draw initial state uniformly
initialState=round(rand); % 0 codes for S1 ,1 for S2
E(idx)=initialState;

while idx < length(E)
    E(idx+1)=1-E(idx);  % switch state after each change point
    idx=idx+1;
end
end