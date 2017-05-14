clear
close all
load('perfMatrix_unknown.mat')
Table=array2table(unknownRatePerfMatrix,...
    'VariableNames',{'SNR','T','h','alpha','beta','perf'});
rows = abs(Table.h - .1)<1e-5 &...
    abs(Table.T - 406)<1e-5 &...
    abs(Table.SNR - .8)<1e-5;
vars={'alpha','beta','perf'};
perfMatrix=Table{rows,vars};
bar(perfMatrix(:,3))
ax=gca;
%ax.XLim=[];
ax.YLim=[.68,.74];
title('Effect of prior over h; SNR=0.8, T=406, h=0.1')
xlabel('Width of prior over change rate')
ylabel('Performance')
ax.XTickLabel={'FLAT','INTERM.','NARROW'};
ax.FontSize=24;