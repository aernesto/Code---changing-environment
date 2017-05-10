function computePerf(filename, linearIdx, nSims)
% computes the performance at the given linear index  and stores it in the 
% performance array filename

% create MAT-file object
matObj = matfile(filename, 'Writable', true);

params = matObj.perfTable(linearIdx,1:end-1);

% compute the performance and write it to file
matObj.perfTable(linearIdx,end) = perfGenPrior(params,nSims);
end