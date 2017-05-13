% parallel script to compute performance with Delta prior
% uses SAME linear indexing as the general prior script

clear
rng('shuffle')
params_filename='perfTable.mat';
load(params_filename)

params = table2array(perfTable(:,1:3));
nSims=10000;

perf_filename = 'perfDeltaTable.mat';
load(perf_filename)
tic
var={'perfDelta'};
parfor linIdx = 1:54400
   perfDeltaTable(linIdx,var) =...
       array2table(perfDeltaPrior(params(linIdx,:),nSims),...
       'VariableNames',var);
end
toc

save(perf_filename,'perfDeltaTable','-v7.3')
