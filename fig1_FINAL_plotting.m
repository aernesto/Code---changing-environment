%produces figure 1 of the article.
%requires:fig1B.mat for panel B, panels A and C are produced in this script

clear

imagepath='~/images/fig1/';       %where to save the image
name='fig1_FINAL_2.png';          %what you want the file to be called
fsBig=9;        %big FontSize
fsSmall=8;      %small FontSize
axWidth=1;      %axes LineWidth
l=1.5;          %linewidth

%global figure
tiny=0.009; %for fine tuning
fig1=figure;
fig1.Visible='off';
fig1.Units='centimeters';
fig1.OuterPosition=[0,0,14.65,4.5];

%panel A
sA=subplot(1,3,1);
sA.ActivePositionProperty='OuterPosition';

myRed=[208,9,9]/255;
myOrange=[251,169,7]/255;
x=-5:0.1:5;
y1=normpdf(x,-1,1);
y2=normpdf(x,1,1);

plot(x,y1,'Color',myOrange,'LineWidth',l)
hold on
plot(x,y2,'Color',myRed,'LineWidth',l)
plot([-1,-1],[0,max(y1)],'--k','LineWidth',axWidth)
plot([1,1],[0,max(y2)],'--k','LineWidth',axWidth)
hold off
sA.FontSize=fsBig;
sA.LineWidth=axWidth;
sA.Box='off';
sA.YColor='none';
sA.YLim=[0,max(y1)+.1];
sA.XTick=[-1,1];
sA.TickLabelInterpreter='latex';
sA.XTickLabel={'$H^-$','$H^+$'};
sA.XTickMode='manual';
text(5.4,0,'$\xi_n$','Interpreter','latex','FontSize',fsBig)
text(2.27,.3,'${\rm P}(\xi_n|H^+)$','Interpreter','latex','FontSize',fsSmall)
text(-5,.3,'${\rm P}(\xi_n|H^-)$','Interpreter','latex','FontSize',fsSmall)
% axes(axG)
% text(-2.5,max(y1)+2,'$H^-$       $H^+$','Interpreter','latex','FontSize',fsBig)


%panel B
sB=subplot(1,3,2);
load('~/matlab_neuralcomp/data/fig1B.mat')
plot(abscissa,a,'black',abscissa,b,':black','LineWidth',l);
sB.ActivePositionProperty='OuterPosition';

sB.FontSize=fsBig;
sB.LineWidth=axWidth;
sB.Box='off';
sB.YAxisLocation='right';
sB.XAxis.Limits=[0.5,N+.5];
sB.XTick=[1,5,10];
sB.TickLabelInterpreter='latex';
sB.XTickLabel={'$t_1$','$t_5$','$t_{10}$'};
sB.YAxis.Limits=[-0.3,amplitude+.3];
sB.YAxis.TickValues=[0,3,6];
sB.YAxis.TickLabels=[0,3,6];
text(7,1,'$a_n$','Interpreter','latex','FontSize',fsSmall)
text(3,4,'$b_n$','Interpreter','latex','FontSize',fsSmall)
%ylabel('$\ \quad a_n, b_n$','Interpreter','latex','Rotation',90)

%panel C
sC=subplot(1,3,3);
%clear
x=linspace(0,1,150);
a=[0,1,3,30];%t_1, t_5, t_{10}, t_100
b=[0,3,6,70];
y1=betapdf(x,a(1)+1,b(1)+1);
y2=betapdf(x,a(2)+1,b(2)+1);
modey2=a(2)/(a(2)+b(2));
y2=y2/betapdf(modey2,a(2)+1,b(2)+1);
y3=betapdf(x,a(3)+1,b(3)+1);
modey3=a(3)/(a(3)+b(3));
y3=y3/betapdf(modey3,a(3)+1,b(3)+1);
y4=betapdf(x,a(4)+1,b(4)+1);
modey4=a(4)/(a(4)+b(4));
y4=y4/betapdf(modey4,a(4)+1,b(4)+1);


plot(repmat(.3,1,5),linspace(0,1,5),'--r','LineWidth',axWidth)
hold on
line=plot(x,y1,x,y2,x,y3,x,y4,'LineWidth',l);
line(1).Color=[0,3.8,0]/4;
line(2).Color=[0,3.2,0]/4;
line(3).Color=[0,2.6,0]/4;
line(4).Color=[0,2,0]/4;
ylabel('${\rm P}(\epsilon | a_n)$','FontSize',fsBig,'Interpreter','latex')

%axis properties
sC.ActivePositionProperty='OuterPosition';

sC.FontSize=fsBig;
sC.LineWidth=axWidth;
sC.Box='off';
sC.YTick=0:3;
sC.XTick=[0,.3,1];
sC.TickLabelInterpreter='latex';
sC.XTickLabel={'0','true $\epsilon$','1'};
p=get(sC,'Position');
p2=get(sC,'OuterPosition');
p3=p-p2;

p(3)=p(3)-p3(3)-p3(1)-tiny;
set(sC,'Position',p);

%legend
legend(line,{'$t_1$','$t_5$','$t_{10}$','$t_{100}$'},...
    'Interpreter','latex',...
    'FontSize',fsSmall,'Position',[.9,.55,1/27,.18]);
legend('boxoff');

sA.Position=[tiny,0.12,.26,0.6];
sB.OuterPosition=[.33,-.005,.28,1];
sC.OuterPosition=[.65,0,10/27,1];


%printing/saving output
rez=200; %resolution (dpi) of final graphic
figpos=getpixelposition(fig1); %dont need to change anything here
resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
set(fig1,'paperunits','inches','papersize',figpos(3:4)/resolution,...
'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
print(fig1,fullfile(imagepath,name),'-dpng',['-r',num2str(rez)]) %save file 






