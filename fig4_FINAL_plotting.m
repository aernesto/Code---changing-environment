%plots all panels of figure 4
%requires 1 .mat file named fig4.mat
clear

imagepath='~/images/fig4/';             %where you want the figure to be saved
datapath='~/matlab_neuralcomp/data/';   %where to find the required .mat file
filename='fig4AC';                 %name of the required .mat file
load([datapath,filename,'.mat'])
filenamesave='fig4';                    %how the .png figure file should be named

%graphical parameters
fsBig=9;    %big FontSize
fsSmall=8;  %small FontSize
axWidth=1;  %axes LineWidth
spax=1.7;	%special axWidth for pcolor
lw=1.5;     %linewidth
mk=5;       %MarkerSize panel B

uh=.475;    %height of upper panels in normalized units
bh=.475;    %height of bottom panels in normalized units


tiny=0.01;  %for manual fine tuning
frac=3.3;     %multiplying constant for fine tuning
figposition=[0,0,14.65,11.55];
aposition=[3*tiny,1-uh,.4,uh];
bposition=[.5+3*tiny,1-uh,.4,uh];
cposition=[0,0.02,1/3-frac*tiny,bh];
dposition=[1/3-frac*tiny,0.02,1/3-frac*tiny,bh];
eposition=[2/3-2*frac*tiny,0.02,1/3+2*frac*tiny,bh];

blegendpos=[.6+2*tiny,.85,.1,.1];

%toPlotA=1:10;
toPlotA=70:80;
toplotB=1:2:25;

xticksa=[70,75,80];
xticksb=[1,13,25];
yticksb=[1,1000,1000000];
mygreen=[0,.74,0];


%create figure
fig1=figure(1);
fig1.Visible='off';
fig1.Units='centimeters';
fig1.OuterPosition=figposition;

%%%%%%%%%%%%%%%%% PANEL A

axa=subplot('Position',aposition);
axa.ActivePositionProperty='OuterPosition';

RZ = log(R(toPlotA));
[AX,H1,H2]=plotyy(toPlotA,data(toPlotA),...
    [toPlotA',toPlotA'],[RZ',zeros(size(toPlotA))'],'plot','stairs');
%plot(toPlot,data(toPlot),'.','MarkerSize',25)
%hold on
%stairs(log(R(toPlot)),'LineWidth',1.5,'Color','r')
%hold off

%info in caption
%title(['SNR$=$',num2str(snr)],'Interpreter','latex')

%graphics parameters
AX(1).FontSize=fsBig;
AX(1).ActivePositionProperty='OuterPosition';
AX(2).ActivePositionProperty='OuterPosition';
AX(1).Box='off';
%AX(1).XLim=[1,toPlot(end)];
AX(1).XTick=xticksa;
AX(1).XLim=[toPlotA(1),toPlotA(end)];
ylim=[.5-2,.5+2];
AX(1).YLim=ylim;
AX(1).YTick=[0,1];
AX(1).TickLabelInterpreter='latex';
AX(2).TickLabelInterpreter='latex';
AX(1).YTickLabel={'$H^2$','$H^1$'};
%AX(1).YTickLabel={'',''};
AX(1).YColor=[13,8,200]/255;
AX(1).LineWidth=axWidth;
H1.LineStyle='none';
H1.Marker='o';
H1.MarkerSize=mk;
H1.MarkerFaceColor=[13,8,200]/255;
H1.MarkerEdgeColor='none';
H1.LineWidth=lw;
ylabel(AX(1),'$\xi_n$','Interpreter','latex')
xlabel(AX(1),'$n$','Interpreter','latex')

AX(2).FontSize=fsBig;
AX(2).Box='off';
AX(2).XLim=[toPlotA(1),toPlotA(end)];
AX(2).YLim=(ylim-.5)*2;
AX(2).YTick=-2:2:2;
ylabel(AX(2),'$L_n$','Interpreter','latex')
AX(2).YColor='k';
AX(2).LineWidth=axWidth;
H2(1).Color='k';
H2(1).LineWidth=lw;
H2(2).Color='k';
H2(2).LineWidth=axWidth;

axa.OuterPosition=aposition;

%saveas(fig1,[imagepath,filename,'_1.png'])



%%%%%%%%%%%%%%%%% PANEL B

%plot the number of nodes in both 2-state and 3-state asymmetric cases

time=(1:25)';
twostate=2+time.*(time-1);

threestate=[3,9,27,75,186,414,840,1578,2784,4662,7476,11556,...
    17313,25245,35955,50157,68697,92559,122889,161001,208404,...
    266808,338154,424620,528654]';

%fit3=fit(time,threestate,'poly3');
%fit4=fit(time,threestate,'poly4');
%fit5=fit(time,threestate,'poly5');
%fit6=fit(time,threestate,'poly6');

% p3=plot(fit5,time,threestate);
% p3(1).Color='m';
% p3(1).Marker='o';
% p3(2).Color='r';
axb=subplot('Position',bposition);

hold on
p4=plot(time(toplotB),threestate(toplotB),'^b','MarkerSize',mk,'LineWidth',axWidth);
%p4(1).Color='b';
%p4(1).Marker='^';
%p4(1).MarkerSize=mk;
%p4(1).LineWidth=axWidth;
% p4(2).Color='k';
% p4(2).LineWidth=axWidth;

%p5=plot(fit5,time,threestate);
%p6=plot(fit6,time,threestate);

q=plot(time(toplotB),twostate(toplotB),'ob','MarkerSize',mk,'LineWidth',axWidth);
hold off
%semilogy([twostate,threestate],'o','LineWidth',2)
xlabel('$n$','Interpreter','latex')
ylabel('number of nodes','Interpreter','latex')
mylegend=legend([p4(1);q],{'$N=3$','$N=2$'},...
    'Interpreter','latex','Position',blegendpos);
mylegend.Box='off';
%ax=gca;
axb.TickLabelInterpreter='latex';
axb.LineWidth=axWidth;
axb.FontSize=fsBig;
axb.YScale='log';
axb.ActivePositionProperty='OuterPosition';
axb.OuterPosition=bposition;
axb.XLim=[0,25];
axb.YLim=[1,1000000];
axb.XTick=xticksb;
axb.YTick=yticksb;
% fig1.Units='centimeters';
% fig1.Position=[0,0,14.65,10];



%%%%%%%%%%%%%%%%% PANELS C D E
nsubplots=min([3,T]);
timesToPlot=[30,100,200];
for i=1:nsubplots
%surface plot
%surf(X,Y,Z(:,:,t)) if you like a surface representation of the joint
%density

%pcolor plot
t=timesToPlot(i);

switch i
    case 1
    ax=subplot('Position',cposition);
    ax.OuterPosition=cposition;
    %colorbarticks=[.1,1.4,2.8];
    case 2
    ax=subplot('Position',dposition);
    ax.OuterPosition=dposition;
    %colorbarticks=[.2,6,12];
    case 3
    ax=subplot('Position',eposition);
    ax.OuterPosition=eposition;
    colorbarticks=[1,44];
end

hh=pcolor(Z(:,:,t)');
hh.LineStyle='none';
colormap('bone')
if i==3
colorbar('Ticks',colorbarticks,'TickLabelInterpreter','latex','TickLabels',...
    {'low','high'})
end
hold on
plot1=plot((res-1)*meanEps(1,t)+1,(res-1)*meanEps(2,t)+1,'*r','MarkerSize',mk);
plot1.LineWidth=axWidth;
plot2=plot((res-1)*eps(2,1)+1,(res-1)*eps(1,2)+1,'o','MarkerSize',mk);
plot2.Color=mygreen;
plot2.LineWidth=lw;
hold off
title(['$n=$',num2str(t)],'Interpreter','latex')
%recall epsilon+=0.2 and epsilon-=0.1
xlabel('$\epsilon^{21}$','Interpreter','latex')
if i==1
    ylabel('$\epsilon^{12}$','Interpreter','latex')
end
ax.ActivePositionProperty='OuterPosition';
ax.TickLabelInterpreter='latex';
ax.FontSize=fsBig;
ax.XTick=linspace(1,res,3);
if i==1
    ax.YTickLabel={'0','.5','1'};
else
    ax.YTickLabel={'','',''};
end
ax.YTick=linspace(1,res,3);
ax.XTickLabel={'0','.5','1'};

%legend('density','mean rates','true rates')
end

%printing/saving output
rez=300;                                %resolution (dpi) of final graphic
figpos=getpixelposition(fig1);          %dont need to change anything here
resolution=get(0,'ScreenPixelsPerInch');%dont need to change anything here
set(fig1,'paperunits','inches',...
    'papersize',figpos(3:4)/resolution,...
'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
print(fig1,fullfile(imagepath,filenamesave),'-dpng',['-r',num2str(rez)]) %save file
