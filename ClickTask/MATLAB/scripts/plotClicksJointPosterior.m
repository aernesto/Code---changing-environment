function plotClicksJointPosterior(P,timeRange)
% P is the 3D joint posterior
% produces nPlots plots corresponding to the time steps in the range
    % [timeRange(1),timeRange(2)]
    % better if nPlots is the square of an integer, like 4, 9, 16

global obs

if (timeRange(2) > size(P,3)) || (timeRange(1) < 1)
    error(['Only ',num2str(size(P,3)),' steps exist'])
end
nPlots=timeRange(2)-timeRange(1)+1;
for i=1:nPlots
    timeStep=timeRange(1)+i-1;
    subplot(ceil(sqrt(nPlots)),ceil(sqrt(nPlots)),i)
    bar3(P(1:timeRange(2),:,timeStep))
    title(['step ',num2str(timeStep), '; obs=', num2str(obs(timeStep,:))])
    xlabel('State')
    ylabel('gamma')
    zlabel('Probability')
    %ax= gca;
    %ax.FontSize=14;
end

end