nPoints=108800;
perfDelta=zeros(nPoints,1);
perfDeltaTable=array2table(perfDelta);
save('perfDeltaTable.mat','perfDeltaTable','-v7.3')