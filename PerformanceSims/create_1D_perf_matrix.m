% create the N x 6 matrix that will store the performance values
% 6th column is for performance
%

SNR=.3:.5:3;
    ls=length(SNR);
    
T=1:15:500;
    lt=length(T);
    
h=[.01,.1,.5,.8];
    lh=length(h);
    
% chosen so that median = .1 roughly
alphabeta=1/3+[1,2;9,18];
alphabeta=[ones(2,1),alphabeta]; % include flat prior as first column
    lab=size(alphabeta,2);

totalRows=ls*lt*lh*lab;    
unknownRatePerfMatrix=zeros(totalRows,6);
counter=0;

for snr=1:ls
    for t=1:lt
        for hh=1:lh
            for a=1:lab
                counter = counter+1;
                unknownRatePerfMatrix(counter,1:end-1)=...
                    [SNR(snr),T(t),h(hh),alphabeta(1,a),alphabeta(2,a)];
            end
        end
    end
end

save('perfMatrix_unknown.mat','unknownRatePerfMatrix','-v7.3')


assumed_h=.01:.5:1;
    lah=length(assumed_h);

totalRows=ls*lt*lh*lah;    
knownRatePerfMatrix=zeros(totalRows,5);
counter=0;

for snr=1:ls
    for t=1:lt
        for hh=1:lh
            for ah=1:lah
                counter = counter+1;
                knownRatePerfMatrix(counter,1:end-1)=...
                    [SNR(snr),T(t),h(hh),assumed_h(ah)];
   
            end
        end
    end
end

save('perfMatrix_known.mat','knownRatePerfMatrix','-v7.3')



