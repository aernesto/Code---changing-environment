for linIdx = 1:20
    tic
    computePerf('perf5DArray.mat', linIdx, 1000)
    toc
end