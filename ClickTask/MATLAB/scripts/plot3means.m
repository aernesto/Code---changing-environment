% loads data for three posterior mean curves computed on same 5sec stimulus
% but for 3 distinct dt size, 0.5, 1 and 2 msec respectively. Then plots
% the three curves with log-scale y-axis to investigate convergence...
clear

dt05=load('dt05msec2614.mat');
time05=dt05.ttime;
means05=dt05.mean_cpc;
dt1=load('dt1msec2614.mat');
time1=dt1.ttime;
means1=dt1.mean_cpc;
dt2=load('dt2msec2614.mat');
time2=dt2.ttime;
means2=dt2.mean_cpc;

semilogy(time05, means05, time1, means1, time2, means2,'LineWidth',2)
legend('dt=0.5ms','dt=1ms','dt=2ms')
title('posterior means for a','FontSize',16)
xlabel('time in sec','FontSize',16)
ylabel('log CP count','FontSize',16)