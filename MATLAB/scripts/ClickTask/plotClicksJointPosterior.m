function plotClicksJointPosterior(P)
% produces one plot per time step
N=size(P,3);
for i=1:N
    subplot(2,ceil(N/2),i)
    bar3(P(:,:,i))
    title(['step ',num2str(i)])
    xlabel('State')
    ylabel('gamma')
    zlabel('Probability')
    %ax= gca;
    %ax.FontSize=14;
end
end