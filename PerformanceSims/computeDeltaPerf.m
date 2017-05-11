function computeDeltaPerf(params, linearIdx, nSims, perfTable)
% computes the performance for delta prior on h, at the given linear index  
% and stores it in the performance table perfTable

% compute the performance and write it to file
perfTable(linearIdx) = perfDeltaPrior(params,nSims);
end