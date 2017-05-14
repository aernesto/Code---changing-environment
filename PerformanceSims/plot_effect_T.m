function plot_effect_T(Table,params)
% returns a plot of performance as function of interrogation time T
% params contains the frozen values for [SNR, h, alpha]
rows = abs(Table.SNR - params(1))<1e-5 &...
        abs(Table.h - params(2))<1e-5 &...
        abs(Table.alpha - params(3))<1e-5;
vars={'T','perf'};
perfMatrix=Table{rows,vars};
plot(perfMatrix(:,1),perfMatrix(:,2),'LineWidth',4)
ax=gca;
%ax.XLim=[];
ax.YLim=[.5,1];
title(['Effect of T; SNR=',num2str(params(1)),...
    ' h=',num2str(params(2)),...
    ' alpha=',num2str(params(3))])
xlabel('Interrogation time')
ylabel('Performance')
%ax.XTickLabel={'FLAT','INTERM.','NARROW'};
ax.FontSize=20;