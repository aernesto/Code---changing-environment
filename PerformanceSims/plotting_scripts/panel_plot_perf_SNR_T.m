% subplots
h=.1:.2:.9;
for i=1:length(h)
    subplot(2,3,i)
    plot_perf_SNR_T(h(i),1,1, 'perfTable.mat')
end
subplot(2,3,6)
plot_perf_SNR_T(.1,2,1, 'perfTable.mat')