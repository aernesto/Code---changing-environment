clear
close all
load('perfMatrix_known.mat')
Table=array2table(knownRatePerfMatrix,...
    'VariableNames',{'SNR','T','h','h_assumed','perf'});

SNRvals=[.3,.8];
hvals=[.01,.1,.5,.8];
havals=.11;

counter=0;
for hh=1:length(hvals)
    for ss=1:length(SNRvals)
        counter=counter+1;
        params=[SNRvals(ss),hvals(hh),havals];
        figure
        plot_effect_T_known(Table, params)
        saveas(gcf,['panel',num2str(counter),'.png'])
    end
end