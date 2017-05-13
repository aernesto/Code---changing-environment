% main script to be run on compute servers to compute the performance
% of the ideal-observer who doesn't know the change rate
% data is stored into a MAT-file 

clear
rng('shuffle')
filename='perfMatrix_unknown.mat';

load(filename)

params = unknownRatePerfMatrix(:,1:end-1);
nSims=10000;

tic
parfor linIdx = 1:2448
   unknownRatePerfMatrix(linIdx,6) = perfGenPrior(params(linIdx,:),nSims);
end
toc

save(filename,'unknownRatePerfMatrix','-v7.3')
% MAT-file strategy found there:
%   https://www.mathworks.com/matlabcentral/answers/307763-how-to-update-variable-within-a-matfile-inside-a-parfor-loop
% %% step 1: create a mat-file per worker using SPMD
% spmd
%     myFname = tempname(); % each worker gets a unique filename
%     myMatfile = matfile(myFname, 'Writable', true);
% end
% 
% %% step 2: create a parallel.pool.Constant from the 'Composite'
% % This allows the worker-local variable to used inside PARFOR
% myMatfileConstant = parallel.pool.Constant(myMatfile);
% 
% %% Step 3: run PARFOR
% parfor idx = 1:100
%     resultToSave = idx * 100;
%     matfileObj = myMatfileConstant.Value;
%     % Append into 'testOut', storing the index
%     matfileObj.testOut(1, idx) = resultToSave;
%     matfileObj.gotResult(1, idx) = true;
% end
% 
% %% Step 4: accumulate the results on the client
% % Here we retrieve the filenames from 'myFname' Composite,
% % and use them to accumulate the overall result
% outmatfile = matfile('out.mat', 'Writable', true);
% for idx = 1:numel(myFname)
%     workerFname = myFname{idx};
%     workerMatfile = matfile(workerFname);
%     workerOutSz = size(workerMatfile, 'testOut');
%     for jdx = 1:workerOutSz(2)
%         if workerMatfile.gotResult(1, jdx)
%             outmatfile.out(1, jdx) = workerMatfile.testOut(1, jdx);
%         end
%     end
% end