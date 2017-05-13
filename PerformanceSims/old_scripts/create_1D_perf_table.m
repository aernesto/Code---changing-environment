% create the N x 6 Table that will store the performance values
% 6th column is for performance
%
% Dim 1 = SNR
%   Values: .3 : .3 : 3 
%
% Dim 2 = T
%   Values: 1 : 15 : 500
%
% Dim 3 = h
%   Values: .1 : .2 : .9
%
% Dim 4 = alpha
%   Values: 1 : 8
%
% Dim 5 = beta
%   Values: 1 : 8

SNR=.3:.3:3;
    ls=length(SNR);
    
T=1:15:500;
    lt=length(T);
    
h=.1:.2:.9;
    lh=length(h);
    
alpha=1:8;
    la=length(alpha);
    
beta=1:8;
    lb=length(beta);

totalRows=ls*lt*lh*la*lb;    
tableAsmatrix=zeros(totalRows,6);
counter=0;

for snr=1:ls
    for t=1:lt
        for hh=1:lh
            for a=1:la
                for b=1:lb
counter = counter+1;
tableAsmatrix(counter,1:end-1)=[SNR(snr),T(t),h(hh),alpha(a),beta(b)];
                end
            end
        end
    end
end

perfTable=array2table(tableAsmatrix,...
    'VariableNames', {'SNR' 'T' 'h' 'alpha' 'beta' 'perf'});
save('perfTable.mat','perfTable','-v7.3')