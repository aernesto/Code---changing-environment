function plot_perf_SNR_T(hval,alphaval,betaval, filename)
% plots performance as pcolor plot, 
% ARGS:
% h, alpha, beta are frozen values
% OUTPUT: a pcolor plot where,
% x axis is interrogation time
% y axis is SNR
% filename: .mat file containing the performance data as a table with 
% name perfTable

load(filename)

%conditions on table freeze h, alpha, beta
rows = perfTable.h==hval & perfTable.alpha==alphaval &...
    perfTable.beta==betaval;
vars = {'SNR','T','perf'};
perfMatrix=perfTable{rows,vars};

lt=length(1 : 15 : 500);
ls=length(.3 : .3 : 3);
T_mat=reshape(perfMatrix(:,2),lt,ls);
S_mat=reshape(perfMatrix(:,1),lt,ls);
perf_mat=reshape(perfMatrix(:,3),lt,ls);

PLOT=pcolor(T_mat,S_mat,perf_mat);
colormap(bone)
[cmin,cmax]=caxis;
caxis([.5,cmax]) % set floor color to perf of 50%
colorbar
title(['Performance 1000 sims ','h=',num2str(hval),...
    ' alpha=',num2str(alphaval),' beta=',num2str(betaval)])
xlabel('Interrogation time')
ylabel('SNR')
ax=gca;
ax.FontSize=15;
% subsample_T=1:3:lt;
% ax.XTick=subsample_T;
% subsample_SNR=1:2:ls;
% ax.YTick=subsample_SNR;
% ax.XTickLabel=strread(num2str(range_T(subsample_T)),'%s');
% ax.YTickLabel=strread(num2str(range_SNR(subsample_SNR)),'%s');
end




