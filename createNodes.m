function d=createNodes(n)
%returns a matrix containing all the nodes P_n(H^\pm,a_n)
%one node is represented as a row vector of length 5. The first entry is H_n and the remaining 4 stand for the entries of the matrix a_n
%n>1 is an integer

nRows=n*(n-1)+2;
tempMat=zeros(nRows,6);

%fill in the time column
tempMat(:,1)=n*ones(nRows,1);

%create the 2 trivial nodes that correspond to no changepoint
tempMat(1:2,2:end)=[1,n-1,0,0,  0; %H^+
                    0,  0,0,0,n-1];%H^-
start=3; %row index at which the filling of the matrix tempMat should start 
for m=1:n-1
    cardncp=n-1-m; %number of non-changepoints
    incr=cardncp+1; %half the number of rows to fill in tempMat for each value of m
    seq1=(0:cardncp)';
    seq2=(cardncp:-1:0)';
    %create the nodes with odd number of changepoints m
    if mod(m,2)
        %there are cardncp+1 ways of filling in the entries a^11 and a^44
        tempMat(start:start+incr-1,2:end)=...
            [ones(incr,1),...%state
            seq1,...%a^11
            floor(m/2)*ones(incr,1),...
            ceil(m/2)*ones(incr,1),...
            seq2];  %a^22
        tempMat(start+incr:start+2*incr-1,2:end)=...
            [zeros(incr,1),...%state
            seq1,...%a^11
            ceil(m/2)*ones(incr,1),...
            floor(m/2)*ones(incr,1),...
            seq2];
        %create the nodes with even number of changepoints m
    else
        tempMat(start:start+incr-1,2:end)=...
            [ones(incr,1),...%state
            seq1,...%a^11
            m/2*ones(incr,2),...%changepoint counts
            seq2];  %a^22
        tempMat(start+incr:start+2*incr-1,2:end)=...
            [zeros(incr,1),...%state
            seq1,...%a^21
            m/2*ones(incr,2),...%changepoint counts
            seq2];
    end
    start=start+2*incr;
end
d=tempMat;
end
