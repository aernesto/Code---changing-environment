% Aim is to produce plots of performance as function of assumed h, 
% for fixed interrogation time

load('perfMatrix_known.mat')
varNames={'SNR','T','h','assumed_h','perf'};
Table=array2table(knownRatePerfMatrix,...
    'VariableNames',varNames);

frozenVars={'SNR','T','h'};
values=[.8,301,0.1];
freeVars={'assumed_h','perf'};

nVars=length(frozenVars);

% create column for logical indexing of rows
rowIdx=ones(size(Table,1),1);
for col=1:nVars
    rowIdx=rowIdx & abs(Table{:,frozenVars(col)}-values(col)) < 1e-5;
end

mat=Table{rowIdx,freeVars};
ah=mat(:,1);
perf=mat(:,2);
plot(ah,perf,'LineWidth',3)

s=' ';
for string=1:nVars
    s=[s,frozenVars{string},'=',num2str(values(string)), '; '];
end
title(['Perf 10000 sims;',s])
xlabel('Assumed h')
ylabel('Performance')
ax=gca;
ax.FontSize=15;