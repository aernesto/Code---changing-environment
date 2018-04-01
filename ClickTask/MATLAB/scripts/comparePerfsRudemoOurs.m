% Compares performance of our model to Rudemo's one, for single-stream
% evidence
clearvars -except data
% load data
highrate=38;
lowrate=2;
h=1;
kappa=log(highrate/lowrate);
euler_dt=0.0001;
init=0;
filename=['/home/radillo/Git/GitHub/LearningClicksTask/data/',...
    'ClickTrains_h1_rateHigh38_rateLow2_nTrials10000.mat'];
load(filename)

% now a cell array named data is in the environment with dimensions 15x2
% dim1 corresponds to trial duration
% the second column along dim2 is the trial duration in seconds
row=15; % 5 for trial duration of 1 second
T=data{row,2}; % trial duration in seconds
% the first column along dim2 contains cells of dimension 10,000x4
% first dim of these cells is the trial number
% col1=left train
% col2=right train
% col3=CP times
% col4=state vector

% cell array subdata below has dimensions 10,000 x 4
subdata=data{row,1};
ntrials=size(subdata,1);
perf_ours=0;
perf_Rudemo=0;
confirm=0;
nempty=0;
tic
for trial=1:ntrials
    lefttrain=subdata{trial, 1};
    righttrain=subdata{trial, 2};
    if isempty(lefttrain)
        leftempty=true;
    else
        leftempty=false;
    end
    if isempty(righttrain)
        rightempty=true;
    else
        rightempty=false;
    end
    if ~leftempty && ~rightempty
        noempty=true;
    else
        noempty=false;
    end
    end_state=subdata{trial, 4}(end);
    % following for debugging
    if end_state == 1
        % expect last click on the right
        if noempty && righttrain(end)>lefttrain(end)
            confirm=confirm+1;
        elseif ~rightempty && leftempty
            confirm=confirm+1;
        elseif leftempty && rightempty
            nempty=nempty+1;
        end
    else
        % expect last click on the left
        if noempty && lefttrain(end)>righttrain(end)
            confirm=confirm+1;
        elseif ~leftempty && rightempty
            confirm=confirm+1;
        elseif leftempty && rightempty
            nempty=nempty+1;
        end
    end
% compute performance with our model
    dec_var_ours=evolveOurOde(righttrain',[init,highrate,lowrate,euler_dt,T,h],false);
    if dec_var_ours>0
        dec_ours=1;
    else
        dec_ours=0;
    end
    if dec_ours==end_state
        perf_ours=perf_ours+1;
    end
% compute performance with Rudemo's model
    dec_var_Rudemo=evolveRudemoOde(righttrain',...
        [init,highrate, lowrate,euler_dt,T,h],false);
    if dec_var_Rudemo>0
        dec_Rudemo=1;
    else
        dec_Rudemo=0;
    end
    if dec_Rudemo==end_state
        perf_Rudemo=perf_Rudemo+1;
    end
end
toc
perf_ours=perf_ours/ntrials
perf_Rudemo=perf_Rudemo/ntrials
nempty
correct_expectation=confirm / (ntrials - nempty)
% conclude