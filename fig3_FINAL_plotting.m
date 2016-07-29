%plots figure 3 using 3 .mat files
clear
datapath='~/matlab_neuralcomp/data/';
panelsAB=[datapath,'fig3ab_opuntia_FINAL_1.mat'];      % panels AB all curves
panelCu=[datapath,'fig3c_unknown_FINAL_opuntia_2.mat'];% panel C unknown rates
panelCk=[datapath,'fig3c_FINAL_uh_2.mat'];             % panel C known rates

tiny=0.009; %for fine tuning
posa=[0,0,1/3-tiny,1];
posb=[1/3+2*tiny,0,1/3-3*tiny,1];
posc=[2/3+2*tiny,0,1/3-2*tiny,1];

currimagepath='~/images/fig3/'; %where to save the image
currfilename='fig3_FINAL';

%parameters
fss=8;      %small font
fsb=9;     %big font
lwb=1.5;    %big line width
lws=1;   %small line width
aw=1;     %axis line width
ymin=0.7;

load(panelsAB)

%global figure

fig1=figure;
fig1.Visible='off';
fig1.Units='centimeters';
fig1.OuterPosition=[0,0,14.65,6.5];

%PANEL A
% 
ratesToPlot=[3,5,15,30];%be careful with indexing
trueRateIndx=2;
nCurves=length(ratesToPlot);

sA=subplot(1,3,1);

hold on
shades=plot(timePoints,correctk(ratesToPlot,:)/nSims,'--','LineWidth',lwb);
lp0=plot(timePoints,correct/nSims,'Color',[0,0,0],'LineWidth',lwb);
hold off

%green shades
shades(1).Color=[0,3.8,0]/4;
shades(2).Color=[0,3.2,0]/4;
shades(3).Color=[0,2.6,0]/4;
shades(4).Color=[0,2,0]/4;

shades(trueRateIndx).LineStyle='-';

%info to appear in figure caption:
    %title(['$\epsilon=$',num2str(eps),'; snr$=$',num2str(snr),...
    %   '; 1,000,000 sims'],'Interpreter','latex')

ylabel('performance','Interpreter','latex')
xlabel('interrogation time','Interpreter','latex')

% legend([lp0;shades],['unknown rate';...
%     cellstr(num2str(errEps(ratesToPlot)))],...
%     'Location','southeast','FontSize',fss,'Box','off',...
%     'Interpreter','latex')

sA.TickLabelInterpreter='latex';
sA.LineWidth=aw;
sA.Box='off';
sA.FontSize=fsb;
sA.YLim=[ymin,.85];
sA.YTick=[ymin,.85];
sA.XLim=[1,finalTime];
%sA.XTickMode='manual';
sA.XTick=[1,150,300];
sA.ActivePositionProperty='OuterPosition';
%sA.Position=[tiny,0.2,6/27,0.6];


%PANEL B
rows=1:size(errEps,1);
lastrow=rows(errEps==max(errEps));
finalPoints=correctk(1:lastrow(1),nTimePoints)/nSims;

sB=subplot(1,3,2);
hold on

%plot performance of the unknown rate algorithm at different times
times=[40,100,200,300];
indices=1:nTimePoints;

blueshades=gobjects(length(times),1);
for jj=1:length(times)
    t=indices(timePoints==times(jj));
    yval=correct(t);
    blueshades(jj)=plot([min(errEps),max(errEps)],[yval,yval]/nSims,...
        'LineWidth',lws);
    %text(.3,yval/nSims,['n=',num2str(timePoints(times(jj)))],...
     %   'HorizontalAlignment','right','FontSize',12)
end
blueshades(4).Color=[0,0,0];
blueshades(3).Color=[1,1,1]/8;
blueshades(2).Color=[1,1,1]/4;
blueshades(1).Color=[1,1,1]*3/8;
%alpha(blueshades,0.3) line objects do not support transparancy

plot(errEps(1:lastrow(1)),finalPoints,'Color',[0,3.2,0]/4,...
    'LineWidth',lwb)
%plot best performance when rate is known
plot(eps,finalPoints(errEps==eps),'*r','MarkerSize',8,'LineWidth',lws)
hold off

%title(['performance as a function of the assumed rate; $\epsilon=$',...
%    num2str(eps),'; snr$=$',...
%    num2str(snr)],...
%    'Interpreter','latex')
xlabel('assumed $\epsilon$','Interpreter','latex')
%ylabel('percentage correct','Interpreter','latex')

% legend({'uknown rate n=40',...
%     'uknown rate n=100',...
%     'uknown rate n=200',...
%     'uknown rate n=300','assumed rates','true rate'},...
%     'Location','southwest','FontSize',fss,'Box','off',...
%     'Interpreter','latex')

sB.FontSize=fsb;
sB.TickLabelInterpreter='latex';
sB.LineWidth=aw;
sB.Box='off';
sB.XLim=[0.01,0.5];
sB.XTick=[.01,.25,.5];
sB.YLim=[ymin,.85];
sB.YTick=[ymin,.85];
sB.ActivePositionProperty='OuterPosition';
%sB.OuterPosition=[8/27+tiny,0,7/27,1];
%replace previous legend by text in the plot


%PANEL C

%atm axis box missing, I don't know why

load(panelCk)    

sC=subplot(1,3,3);
%plot empirical precision curves
hold on
line=gobjects(nRates,1);        %initialize graphic objects
curvesToPlot=[1,2,5,7];
for ii=curvesToPlot
    line(ii)=plot(avgtimes(:,ii),empPrecision(:,ii),'--','LineWidth',lwb);
    %line(ii).Color=[0,1+nRates-ii,0]/nRates; %shades of green
end
line(1).Color=[0,3.8,0]/4;
line(2).Color=[0,3.2,0]/4;
line(5).Color=[0,2.6,0]/4;
line(7).Color=[0,2,0]/4;
line(2).LineStyle='-';

%add unknown rate curve
load(panelCu)

lp=plot(avgtimesu,perf,'LineWidth',lwb,'Color',[0,0,0]);

hold off

%title(['free resp.; $\epsilon =$',num2str(eps),'; snr$=$',num2str(snr),'; 50,000 sims'],'Interpreter','latex')

xlabel('average waiting time','Interpreter','latex')
%ylabel('performance')

% legend([lp;line(curvesToPlot)],...
%     ['unknown rate';cellstr(num2str(rates(curvesToPlot)'))],...
%     'FontSize',fss,'Location','southeast','Box','off',...
%     'Interpreter','latex')

sC.TickLabelInterpreter='latex';
sC.LineWidth=aw;
sC.FontSize=fsb;
sC.Box='off';
sC.XLim=[1,300];
sC.XTick=[1,150,300];
sC.YLim=[.85,1];
sC.YTick=[.85,1];
sC.ActivePositionProperty='OuterPosition';


sA.Units='normalized';
sB.Units='normalized';
sC.Units='normalized';
sA.OuterPosition=posa;
sB.OuterPosition=posb;
sC.OuterPosition=posc;

%printing/saving output
rez=200; %resolution (dpi) of final graphic
figpos=getpixelposition(fig1); %dont need to change anything here
resolution=get(0,'ScreenPixelsPerInch'); %dont need to change anything here
set(fig1,'paperunits','inches','papersize',figpos(3:4)/resolution,...
'paperposition',[0 0 figpos(3:4)/resolution]); %dont need to change anything here
print(fig1,fullfile(currimagepath,currfilename),'-dpng',['-r',num2str(rez)]) %save file 


