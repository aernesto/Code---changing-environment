%produces panels B-D of figure 2
%requires two data files:
%smallFig2.mat
%bigFig2.mat

%pb with placement of panel B at the moment

clear
rng('shuffle')
imagepath='';
datapath='';
filename='fig2MATLAB_uh9';

fsBig=14;    %big FontSize
fsSmall=13;  %small FontSize
axWidth=1;  %axes LineWidth
spax=1.7;	%special axWidth for pcolor
lw=1.5;     %linewidth
mk=5;       %MarkerSize panel B

tiny=0.02;
myRed=[208,9,9]/255;
myOrange=[251,169,7]/255;

%figure
fig2=figure;
fig2.Visible='off';
fig2.Units='centimeters';
fig2.OuterPosition=[0,0,9,11.7];
%panel A empty for now, filled with inkscape

%panel B
%load([datapath,'fig2B.mat'])
%sB=subplot(2,2,3);
%sB.ActivePositionProperty='OuterPosition';
%create artificial sequence of 10 points with 2 change points.
%truth = [ones(1,3),-ones(1,5),ones(1,2)];
%sigma=2/.75;
%snr=0.75;
%data=sigma*[randn(1,3)+1,randn(1,5)-1,randn(1,2)+1];
%%%%%%%%%%%%%%%%%%%%
% N=10;                            %number of time steps
m = 1;                            %mean of H^+ likelihood
priorState=[.5;.5];
%Hpn below is the vector of joint probabilities (P_n(H^+,a))_a
%n and c stand for n and current respectively
%data=observations(1:N);
%Hpn = zeros(N,1); Hpc = Hpn; Hmn = Hpn; Hmc = Hpn;
%lp = zeros(N,1); lm = lp; 
%x=data(1);
%Hpc(1) = exp(-(x-m)^2/(2*sigma^2));%/sqrt(2*pi*sigma^2);
%Hmc(1) = exp(-(x+m)^2/(2*sigma^2));%/sqrt(2*pi*sigma^2);
%Fd = Hpc(1)+Hmc(1);
%Hpc(1) = Hpc(1)/Fd;
%Hmc(1) = Hmc(1)/Fd;
%lp(1) = Hpc(1);
%lm(1) = Hmc(1);
%hyperparameters for hyperprior over epsilon
%priorPrec=2; %a0+b0=priorPrec and a0/priorPrec=eps
%a0=1;%priorPrec*eps;
%b0=1;%priorPrec-a0;
%chgpt=zeros(1,N);
%for j=1:N-1
%    x=data(j+1);
%    xp = exp(-(x-m)^2/(2*sigma^2));%/sqrt(2*pi*sigma^2); %normalization constant absorbed in the global one
%    xm = exp(-(x+m)^2/(2*sigma^2));%/sqrt(2*pi*sigma^2);
%    
%    % update the boundaries (with 0 and j changepoints)
%    ea = 1-a0/(j-1+priorPrec);
%    eb= (j-1+a0)/(j-1+priorPrec);
%    Hpn(1) = xp*ea*Hpc(1);
%    Hmn(1) = xm*ea*Hmc(1);
%    Hpn(j+1) = xp*eb*Hmc(j);
%    Hmn(j+1) = xm*eb*Hpc(j);
%    
%    % update the interior values
%    if j>1
%        vk = (2:j)';
%        ep = 1-(vk-1+a0)/(j-1+priorPrec); %no change
%        em=(vk-2+a0)/(j-1+priorPrec);   %change
%        Hpn(vk) = xp*(ep.*Hpc(vk)+em.*Hmc(vk-1));
%        Hmn(vk) = xm*(ep.*Hmc(vk)+em.*Hpc(vk-1));
%    end
%    
%    % sum probabilities in order to normalize
%    Hs = sum(Hpn)+sum(Hmn);
%    Hpc=Hpn/Hs;
%    Hmc=Hmn/Hs;
%    lp(j+1) = sum(Hpc); lm(j+1) = sum(Hmc);
%end
%RZ = log(lp./lm);
%[AX,H1,H2]=plotyy(1:N,data,...
%     [(1:N)',(1:N)'],[RZ,zeros(N,1)],'plot','stairs');

%graphics parameters
%AX(1).FontSize=fsBig;
%AX(1).ActivePositionProperty='OuterPosition';
%AX(1).Box='off';
%AX(1).XLim=[1,N];
%AX(1).XTick=[1,5,10,15,20];
%AX(1).YLim=[-6,11];
%AX(1).YTick=[-1,1];
%AX(1).TickLabelInterpreter='latex';
%AX(1).YTickLabel={'$H^-$','$H^+$'};
%AX(1).YTickLabel={'',''};
%AX(1).YColor=[13,8,200]/255;
%AX(1).LineWidth=axWidth;
%H1.LineStyle='none';
%H1.Marker='o';
%H1.MarkerSize=mk;
% H1.MarkerFaceColor=[13,8,200]/255;
% H1.MarkerEdgeColor='none';
% H1.LineWidth=lw;
% %ylabel(AX(1),'$\xi_n$','Interpreter','latex')
% xlabel(AX(1),'$n$','Interpreter','latex')
% AX(2).FontSize=fsBig;
% AX(2).XLim=[1,N];
% AX(2).YLim=[-6,11]/2;
% AX(2).YTick=-2:2:2;
% ylabel(AX(2),'$L_n$','Interpreter','latex')
% AX(2).YColor='k';
% AX(2).LineWidth=axWidth;
% H2(1).Color='k';
% H2(1).LineWidth=lw;
% H2(2).Color='k';
% H2(2).LineWidth=axWidth;
%pB=get(sB,'Position');








%sB.OuterPosition=[.068-tiny,0,.35,.44];







%inset likelihoods plot
% p=get(sB,'Position');
% ax1bis=subplot('Position',[-tiny,p(2),0.11,p(4)]);
% % xl=linspace(-6,11,50);
% % lplus=normpdf(xl,ones(size(xl)),sigma*ones(size(xl)));
% % lminus=normpdf(xl,-ones(size(xl)),sigma*ones(size(xl)));
% plot(xl,lplus,'Color',myRed,'LineWidth',lw)
% hold on
% plot(xl,lminus,'Color',myOrange,'LineWidth',lw)
% hold off
% ax1bis.Box='off';
% ax1bis.YColor='none';
% ax1bis.XColor='none';
% ax1bis.XLim=[-6,11];
% %ax1bis.XTick=0:1;
% %ax1bis.TickLabelInterpreter='latex';
% %ax1bis.XTickLabel={'$H^-$','$H^+$'};
% ax1bis.View=[-90,90];

%panel C
load([datapath,'smallFig2.mat'])
load([datapath,'bigFig2.mat'])

N=length(am);

%for calibration
margA=margA(:,1:N);
sC=subplot(2,1,1);
h1=pcolor(margA);
sC.ActivePositionProperty='OuterPosition';
colormap(sC,'bone')
caxis([0 0.034])
cmap=colormap(sC);
l2=size(cmap,1);
cmap=cmap(l2:-1:1,:);
colormap(sC,cmap)
% colormap(ax,'pink')
% caxis([0 0.035])
colorbar('southoutside','Ticks',[0,0.034],...
         'TickLabels',{'low','high'},'TickLabelInterpreter','latex')
%shading flat
h1.LineStyle='none';
hold on
addedlines=plot([1,N],[0,eps*(N-1)],'--k',...
                1:N,am(1:N),'red','LineWidth',axWidth);
addedlines(2).LineWidth=lw;
hold off
sC.TickLabelInterpreter='latex';
sC.YLim=[0,600];
sC.YTick=[0,300,600];
sC.XTick=[1,N];
sC.LineWidth=spax;
ylabel('$a_n$','Interpreter','latex')
sC.FontSize=fsBig;
legend(addedlines,{'$E[a_n|h]$','$E[a_n|\mathcal{O}_{n}]$'},...
    'Location','northwest',...
    'Interpreter','latex')
legend('boxoff');

%title(['$\epsilon=$',num2str(eps)],'Interpreter','latex')


%panel D

%posterior over epsilon
storEps=storEps(:,1:N);
sD=subplot(2,1,2);
sD.ActivePositionProperty='OuterPosition';
h2=pcolor(storEps);
%shading flat

%colormap(ax,'pink')
colormap(sD,'bone')
caxis([0,max(max(storEps))])
cmap=colormap(sD);
l2=size(cmap,1);
cmap=cmap(l2:-1:1,:);
colormap(sD,cmap)
%colorbar('Ticks',[0,24.5],...
%         'TickLabels',{'low','high'})
h2.LineStyle='none';
xlabel('$n$','Interpreter','latex')
ylabel('$h$','Interpreter','latex')
sD.FontSize=fsBig;
sD.TickLabelInterpreter='latex';
hold on
otheraddedLines=plot([1,N],res*[eps,eps],...
    '--k',1:N,epsm(1:N)*res,'red','LineWidth',axWidth);
otheraddedLines(2).LineWidth=lw;                        
sD.XTick=[1,N];
sD.YLim=[1,.6*res];
sD.YTick=[1,.3*res,.6*res];
sD.YTickLabel=[0,0.3,0.6];
hold off
sD.LineWidth=spax;
legend(otheraddedLines,{'$h$','$E[h|\mathcal{O}_{n}]$'},...
    'Position',[.67,.29,.07,.1],...
    'Interpreter','latex')
legend('boxoff');
%sD.Position=pB

%axes positions for C and D





p=get(sC,'OuterPosition');
p2=get(sD,'OuterPosition');
sC.OuterPosition=[p(1),.393,p(3),.602];
sD.OuterPosition=[p2(1),0,p2(3),.44];













%text(2.27,.3,'${\rm P}(\xi_n|H^+)$','Interpreter','latex','FontSize',fsSmall)
%text(-5,.3,'${\rm P}(\xi_n|H^-)$','Interpreter','latex','FontSize',fsSmall)

%printing/saving output
rez=500; %resolution (dpi) of final graphic
figpos=getpixelposition(fig2); %dont need to change anything here
resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
set(fig2,'paperunits','inches','papersize',figpos(3:4)/resolution,...
'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
print(fig2,fullfile(imagepath,filename),'-dpng',['-r',num2str(rez)]) %save file 
