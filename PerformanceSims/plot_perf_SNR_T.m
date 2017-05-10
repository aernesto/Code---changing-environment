function plot_perf_SNR_T(h,alpha,beta)
% plots performance as pcolor plot, 
% ARGS:
% h, alpha, beta are frozen values
% OUTPUT: a pcolor plot where,
% x axis is interrogation time
% y axis is SNR

matObj = matfile('perf5DArray.mat');

% re-create indices for 5D array
range_SNR=.3:.3:3;
    ls=length(range_SNR);
    
range_T=1:15:500;
    lt=length(range_T);
    
range_h=.1:.2:.9;
    lh=length(range_h);
    
range_alpha=1:8;
    la=length(range_alpha);
    
range_beta=1:8;
    lb=length(range_beta);

%freeze h, alpha, beta
dummy=1:lh;
hIdx=dummy(range_h == h);

dummy=1:la;
aIdx=dummy(range_alpha == alpha);

dummy=1:lb;
bIdx=dummy(range_beta == beta);

% Only load data to plot into workspace    
perfData=squeeze(matObj.perfArray(:,:,hIdx,aIdx,bIdx));

PLOT=pcolor(perfData);
colormap(bone)
[cmin,cmax]=caxis;
caxis([.5,cmax]) % set floor color to perf of 50%
colorbar
title(['Performance 1000 sims ','h=',num2str(h),...
    ' alpha=',num2str(alpha),' beta=',num2str(beta)])
xlabel('Interrogation time')
ylabel('SNR')
ax=gca;
ax.FontSize=15;
subsample_T=1:3:lt;
ax.XTick=subsample_T;
subsample_SNR=1:2:ls;
ax.YTick=subsample_SNR;
ax.XTickLabel=strread(num2str(range_T(subsample_T)),'%s');
ax.YTickLabel=strread(num2str(range_SNR(subsample_SNR)),'%s');
end




