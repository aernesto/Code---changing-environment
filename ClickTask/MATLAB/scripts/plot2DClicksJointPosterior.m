function plot2DClicksJointPosterior(P,timeRange)
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
    figure(i)
    timeStep=timeRange(1)+i-1;
    subplot(1,2,1)
    bar(P(1:timeRange(2),1,timeStep))
    title(['S+; step ',num2str(timeStep), '; obs=', num2str(obs(timeStep,:))])
    xlabel('gamma')
    ylabel('Probability')
    %ax= gca;
    %ax.FontSize=14;
    
    
    subplot(1,2,2)
    bar(P(1:timeRange(2),2,timeStep))
    title(['S-; step ',num2str(timeStep), '; obs=', num2str(obs(timeStep,:))])
    xlabel('gamma')
    ylabel('Probability')
    %ax= gca;
    %ax.FontSize=14;
end

end