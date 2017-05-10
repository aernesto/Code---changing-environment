parfor linIdx = 21:25
    tic
    computePerf('perf5DArray.mat', linIdx, 1000)
    toc
end