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
parfor linIdx = 1:108800
   perfDeltaTable(linIdx) =...
       array2table(perfDeltaPrior(params(linIdx,:),nSims));
end
toc

save(perf_filename,'perfDeltaTable','-v7.3')