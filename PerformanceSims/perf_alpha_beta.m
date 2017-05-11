% To plot performance as a pcolor plot with xy-axes alpha and beta
% respectively:
load('perfTable1_5000.mat')
rows = perfTable.h==.1 & perfTable.T==100 & perfTable.SNR==.3;
vars={'alpha','beta','perf'};
perfMatrix=perfTable{rows,vars};
rows = perfTable.h==.1 & perfTable.T==151 & perfTable.SNR==.3;
perfMatrix=perfTable{rows,vars};
a_mat=reshape(perfMatrix(:,1),8,8);
b_mat=reshape(perfMatrix(:,2),8,8);
perf_mat=reshape(perfMatrix(:,3),8,8);
pcolor(a_mat,b_mat,perf_mat);
colormap(bone)
[cmin,cmax]=caxis;
caxis([.5,cmax]) % set floor color to perf of 50%
colorbar
figure

%surf(a_mat,b_mat,perf_mat) Surface plot