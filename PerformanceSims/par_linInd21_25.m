clear

filename='perfTable.mat';
load(filename)

params = table2array(perfTable(:,1:5));
nSims=1000;

tic
parfor linIdx = 1:500
   perfTable(linIdx,6) =...
       array2table(perfGenPrior(params(linIdx,:),nSims));
end
toc

save('perfTable.mat','perfTable','-v7.3')