% Produce pcolor plots of performance with Time on x-axis and SNR on
% y-axis.

% colSNR=1;
% colT=2;
% colh=3;
% colalpha=4;
% colbeta=5;
load('perfMatrix_unknown.mat')
Table=array2table(unknownRatePerfMatrix,...
    'VariableNames',{'SNR','T','h','alpha','beta','perf'});
hvals=[.01,.1,.5,.8];
alphavals=[1, 4/3, 7/3];
betavals=[1,28/3,55/3];
frozenVars={'h','alpha','beta'};
freeVars={'T','SNR','perf'};
counter=0;
for hh=1:length(hvals)
    for aa=1:length(alphavals)
        counter=counter+1;
        values=[hvals(hh),alphavals(aa),betavals(aa)];
        figure
        table2pcolor(Table, frozenVars, values, freeVars)
        saveas(gcf,['panel',num2str(counter),'.png'])
    end
end