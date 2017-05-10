% benchmark the perfGenPrior function runtime
T = 1:10:300;
M=length(T);
SNR = [.25,1.25];
nSims = 1000;
runTimes=zeros(2,M);
for Tidx = 1:M
    for SNRidx = 1:length(SNR)
        tic
        a = perfGenPrior(SNR(SNRidx),T(Tidx),.1,1,1,nSims);
        runTimes(SNRidx,Tidx) = toc; 
    end
end

figure(1)
plot(T,runTimes(1,:))
title(['SNR=',num2str(SNR(1)),' ',num2str(nSims),' sims'])
xlabel('Interrogation time')
ylabel('run time in sec')
ax=gca;
ax.FontSize=15;

figure(2)
plot(T,runTimes(2,:))
title(['SNR=',num2str(SNR(2)),' ',num2str(nSims),' sims'])
xlabel('Interrogation time')
ylabel('run time in sec')
ax=gca;
ax.FontSize=15;