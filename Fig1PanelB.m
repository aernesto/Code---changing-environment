%figure 1 panel B: aim is to represent the evolution of a 2-state symmetric 
%environment together with the evolution of the change-point count
clear

%create environment
eps=.3;         %change rate
N=10;           %total number of timesteps
H=zeros(N,1);   %environment vector
logicChangePoint=zeros(N-1,1);%presence of change point
for i=1:N-1
    logicChangePoint(i)=rand<eps;
    if logicChangePoint(i)  %force H(1)=0
        H(i+1)=1-H(i);
    else
        H(i+1)=H(i);
    end
end

%count change points
a=[0;cumsum(logicChangePoint)];%force a(1)=0
b=(0:N-1)'-a;

amplitude=max([a;b]);
abscissa=1:N;

save('fig1B.mat')
