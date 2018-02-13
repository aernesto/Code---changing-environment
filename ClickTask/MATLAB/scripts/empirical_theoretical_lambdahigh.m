% this script checks that my inversion function to recover lambdahigh,
% given lambdalow and snr is correct, by plotting empirical and theoretical
% curves
clear
% set multiplot environment
% subplot(3,1,1)
%plot empirical curve
lambdalow=15;
lambdahigh=18:50;
snr=(lambdahigh-lambdalow)./sqrt(lambdahigh+lambdalow);
snr2=1:.5:5;
theolambda=getlambdahigh(lambdalow, snr, false);
plot(lambdahigh, snr, 'r*', theolambda, snr, 'bo')
title('error in recovery of lambda high, for lambda low=100Hz')
legend('forward','inverse')
%xlim([0.2,32])
xlabel('lambdahigh')
ylabel('SNR')
grid on
%plot theoretical curve
% theolambda=getlambdahigh(lambdalow, snr, true);
% subplot(3,1,2)
% plot(theolambda, snr, '*')
% xlim([0.2,32])
% grid on
% subplot(3,1,3)
% theolambda2=getlambdahigh(lambdalow,snr,false);
% plot(theolambda2, snr,'*')
% grid on
