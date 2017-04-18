function [lTrain,rTrain]=genClickObs(ct,E)
% generates the two trains of clicks that the rat hears
%   ct is a column vector with change point times
%   E is a column vector of length length(ct)+1 with the state S+/- of the
%   environment encoded as binary value (1 for S+)
% returns two column vectors for left and right trains respectively
% We use the convention, S+ corresponds to rate_high to the right ear

% We use the memoryless property of the Poisson trains to simply 'stack'
% them, after each change point.

if ~((length(ct) + 1) == length(E))
    error('change point times vector should have one more entry than environment vector')
end

% global variables
global rate_low
global rate_high
global stimulusLength


nTrains=length(E); % number of trains to stack, for each ear

trains=cell(nTrains,2); % cell array storing event trains for each ear
                        % column 1/2 for train left/right
                        
%construct trains between each change point
for tt=1:nTrains
    
    % extract time length of current train
    if tt == 1
        timeLength = ct(tt);
        offset = 0;
    elseif tt == nTrains
        offset = ct(end);
        timeLength = stimulusLength - offset;    
    else
        offset = ct(tt-1);
        timeLength = ct(tt) - offset;    
    end
        
    % construct trains for both ears, depending on envt state
    if E(tt) % evaluates to true if envt is in state S+ ---> high rate to right ear
        trains{tt,2}=genPoissonTrain(rate_high,timeLength)+ offset; % right ear
        trains{tt,1}=genPoissonTrain(rate_low,timeLength) + offset;  % left ear
    else % envt in state S- ---> high rate to left ear
        trains{tt,2}=genPoissonTrain(rate_low,timeLength) + offset;  % right ear
        trains{tt,1}=genPoissonTrain(rate_high,timeLength) + offset; % left ear
    end
end

% concatenate trains
lTrain = cell2mat(trains(:,1));
rTrain = cell2mat(trains(:,2));
end