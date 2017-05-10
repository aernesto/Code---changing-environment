function computePerf(filename, params, linearIdx, nSims, perfTable)
% computes the performance at the given linear index  and stores it in the 
% performance array filename

% compute the performance and write it to file
perfTable(linearIdx,end) = perfGenPrior(params,nSims);
end