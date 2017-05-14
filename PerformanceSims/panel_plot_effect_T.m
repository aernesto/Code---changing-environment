clear
close all
load('perfMatrix_unknown.mat')
Table=array2table(unknownRatePerfMatrix,...
    'VariableNames',{'SNR','T','h','alpha','beta','perf'});

SNRvals=.8:.5:1.8;
hvals=[.01,.1,.5,.8];
FLAT=1;
NARROW=7/3;

counter=0;
for hh=1:length(hvals)
    for ss=1:length(SNRvals)
        counter=counter+1;
        params=[SNRvals(ss),hvals(hh),NARROW];
        figure
        plot_effect_T(Table, params)
        saveas(gcf,['panel',num2str(counter),'.png'])
    end
end