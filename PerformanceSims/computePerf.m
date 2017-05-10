function computePerf(filename, linearIdx, nSims)
% computes the performance at the given linear index  and stores it in the 
% performance array filename

% create MAT-file object
matObj = matfile(filename);

% extract size of performance array
s = size(matObj.perfArray);

% convert linear index into usual indices
[idx1,idx2,idx3,idx4,idx5] = ind2sub(s,linearIdx);

% fetch necessary values for simulation
[SNR,T,h,alpha,beta]=fetchValues(filename,idx1,idx2,idx3,idx4,idx5);

% compute the performance
perf = perfGenPrior(SNR,T,h,alpha,beta,nSims);

% store the performance
writeToFile(filename,idx1,idx2,idx3,idx4,idx5,perf);
end