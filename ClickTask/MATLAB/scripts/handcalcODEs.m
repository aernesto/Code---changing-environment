clear
% stimulus of 2 msec with single right click at 1 msec
t=0.0001:.00001:0.010;
msect=1000*t; % time vec in msec
timeidx=1:length(t);
lTrain=[];
rTrain=.0049;
spikeidx=timeidx(abs(t-rTrain)<0.0000000001);
bef=timeidx<spikeidx;
aft=timeidx>=spikeidx;

% set SNR
rateLow=0.01;


fig=figure(1); 
hax=axes; 
hold on 
SP=rTrain(1)*1000; %right click time in msec
for snr=[0.5,1,2,4]
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
    
    
    xp0=exp(yp0);
    xp1=exp(yp1);
    xm0=exp(ym0);
    xm1=exp(ym1);
    xTot=xp0+xp1+xm0+xm1;
    xp0=xp0./xTot;
    xp1=xp1./xTot;
    xm0=xm0./xTot;
    xm1=xm1./xTot;
    
    postHp=xp0+xp1;
    postHm=xm0+xm1;
    plot(msect,postHp,'LineWidth',2)
end

title('posterior prob of H+ as fcn of time')
ylabel('posterior prob(H+)')
xlabel('time within stimulus (msec)')
xlim([0,11])
ylim([0.45,1.05])
line([SP SP],get(hax,'YLim'),'Color',[1 0 0], 'LineWidth',2)
line(get(hax,'XLim'),[0.5,.5],'Color',[0 0 0], 'LineWidth',1)
line(get(hax,'XLim'),[1,1],'Color',[0 0 0], 'LineWidth',1)
legend('snr=0.5','snr=1','snr=2','snr=4','click time', 'Location', 'east')
hax.FontSize=20;

% 
% figure(1)
% ax1=subplot(2,2,1);
% ax1.FontSize=20;
% plot(msect, yp0,'LineWidth',3)
% xlim([0,10])
% ylim([-1,7])
% xlabel('msec')
% ylabel('yp0')
% %ylim([-.7,-.69])
% 
% ax2=subplot(2,2,2);
% ax2.FontSize=20;
% plot(msect,ym0,'r','LineWidth',3)
% xlim([0,10])
% ylim([-1,7])
% xlabel('msec')
% ylabel('ym0')
% 
% ax3=subplot(2,2,3);
% ax3.FontSize=20;
% plot(msect,yp1,'LineWidth',3)
% xlabel('msec')
% ylabel('yp1')
% ylim([-11,3])
% 
% ax4=subplot(2,2,4);
% ax4.FontSize=20;
% plot(msect,ym1,'r','LineWidth',3)
% ylim([-11,3])
% xlabel('msec')
% ylabel('ym1')
% 
% % figure 2
% 
% figure(2)
% ax1=subplot(2,2,1);
% ax1.FontSize=20;
% plot(msect, xp0,'LineWidth',3)
% xlim([0,10])
% ylim([0,1])
% xlabel('msec')
% ylabel('xp0')
% %ylim([-.7,-.69])
% 
% ax2=subplot(2,2,2);
% ax2.FontSize=20;
% plot(msect,xm0,'r','LineWidth',3)
% xlim([0,10])
% ylim([0,1])
% xlabel('msec')
% ylabel('xm0')
% 
% ax3=subplot(2,2,3);
% ax3.FontSize=20;
% plot(msect,xp1,'LineWidth',3)
% xlabel('msec')
% ylabel('xp1')
% ylim([0,1])
% 
% ax4=subplot(2,2,4);
% ax4.FontSize=20;
% plot(msect,xm1,'r','LineWidth',3)
% ylim([0,1])
% xlabel('msec')
% ylabel('xm1')
