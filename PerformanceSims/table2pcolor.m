function table2pcolor(filename, frozenVars, values, freeVars)
% Freezes the variables vars from the table represented by filename and
% plots the performance data as a pcolor plot for the remaining two free
% dimensions in the table
%
% ARGS:
% 	- filename = .mat file name containing a table named perfTable or
% 	perfDeltaTable
%   - frozenVars = a cell array of strings containing the variable names of the
%   variables to freeze.
%   - values = a vector of values that the frozen variables are set to
%   - freeVars = cell array of strings containing the variable names of the
%   free variables to use for plotting.
%   - delta = Boolean. True if the table is for delta prior
%
% CONSTRAINTS ON INPUT:
%   - frozenVars and values must have same length
%   - freeVars must have length 2
%   - last element of freeVars must be one of 'perf' and 'perfDelta'
%
% OUTPUT: a pcolor plot where,
% x axis is the first non-frozen variable
% y axis is the second non-frozen variable

if ~(length(freeVars) == 3 &&...
        length(frozenVars)==length(values) &&...
        (strcmp(freeVars{end},'perf') ||...
            strcmp(freeVars{end},'perfDelta')))
    error('MyComponent:incorrectType',...
        ['Error\nConstraints on input args not fulfilled',...
        '.\nRead CONSTRAINTS on INPUT section of the help'])
end

load(filename)
% if delta
%     Table=perfDeltaTable;
% else
%     Table=perfTable;
% end

nVars=length(frozenVars);

% create column for logical indexing of rows
rowIdx=ones(size(Table,1),1);
for col=1:nVars
    rowIdx=rowIdx & abs(Table{:,frozenVars(col)}-values(col)) < 1e-5;
end

%conditions on table freeze h, alpha, beta
perfMatrix=Table{rowIdx,freeVars};

lx=length(unique(Table{:,freeVars(1)}));
ly=length(unique(Table{:,freeVars(2)}));

% size(perfMatrix)
% lx
% ly

x_mat=reshape(perfMatrix(:,1),lx,ly);
y_mat=reshape(perfMatrix(:,2),lx,ly);
perf_mat=reshape(perfMatrix(:,3),lx,ly);

pcolor(x_mat,y_mat,perf_mat);
colormap(bone)
[~,cmax]=caxis;
caxis([.5,cmax]) % set floor color to perf of 50%
colorbar
s=' ';
for string=1:length(frozenVars)
    s=[s,frozenVars{string},'=',num2str(values(string)), '; '];
end
title(['Perf 10000 sims;',s])
xlabel(freeVars{1})
ylabel(freeVars{2})
ax=gca;
ax.FontSize=15;
% subsample_T=1:3:lt;
% ax.XTick=subsample_T;
% subsample_SNR=1:2:ls;
% ax.YTick=subsample_SNR;
% ax.XTickLabel=strread(num2str(range_T(subsample_T)),'%s');
% ax.YTickLabel=strread(num2str(range_SNR(subsample_SNR)),'%s');
end