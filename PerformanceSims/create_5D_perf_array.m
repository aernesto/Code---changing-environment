% create the five dimensional array that will store the performance values
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

meshValues = cell(ls,lt,lh,la,lb);

for snr=1:ls
    for t=1:lt
        for hh=1:lh
            for a=1:la
                for b=1:lb
                    meshValues{snr,t,hh,a,b}=...
                        [SNR(snr),T(t),h(hh),alpha(a),beta(b)];
                end
            end
        end
    end
end

perfArray=zeros(ls,lt,lh,la,lb);
save('perf5DArray.mat','perfArray','meshValues','-v7.3')