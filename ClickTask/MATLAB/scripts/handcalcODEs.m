clear
% stimulus of 2 msec with single right click at 1 msec
t=0.0001:.00001:0.002;
msect=1000*t; % time vec in msec
timeidx=1:length(t);
lTrain=[];
rTrain=.001;
spikeidx=timeidx(t==rTrain);
bef=timeidx<spikeidx;
aft=timeidx>=spikeidx;

% set SNR
snr=4;
rateLow=0.01;
rateHigh=getlambdahigh(rateLow, snr, true);
rr=rateHigh/rateLow;
kappa=log(rr);

% theoretical evolution of nodes y^+-(0)
yp0=log(1./(2*(t+1)));
ym0=yp0;
yp0(aft)=yp0(aft)+kappa;

% theoretical evolution of nodes y^+-(1)
% arbitrary initial condition set at -1,000
C=2/exp(1000);
yp1=log((C+t)./(2*((t+1).^2)));
yp1(aft)=yp1(aft)+kappa;

ym1=zeros(size(yp1));
ym1(bef)=yp1(bef);
C2=C+rTrain*(1-rr);
ym1(aft)=log((C2+rr*t(aft))./(2*((t(aft)+1).^2)));

ax1=subplot(2,2,1);
ax1.FontSize=20;
plot(msect, yp0,'LineWidth',3)
xlim([0,2])
ylim([-1,7])
xlabel('msec')
ylabel('yp0')
%ylim([-.7,-.69])
ax2=subplot(2,2,2);
ax2.FontSize=20;
plot(msect,ym0,'r','LineWidth',3)
xlim([0,2])
ylim([-1,7])
xlabel('msec')
ylabel('ym0')
ax3=subplot(2,2,3);
ax3.FontSize=20;
plot(msect,yp1,'LineWidth',3)
xlabel('msec')
ylabel('yp1')
ylim([-10,1])
ax4=subplot(2,2,4);
ax4.FontSize=20;
plot(msect,ym1,'r','LineWidth',3)
ylim([-10,1])
xlabel('msec')
ylabel('ym1')
