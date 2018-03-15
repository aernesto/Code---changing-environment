function postVarTelegraph(alpha0, beta0, n, t, dtmin, dtmax)
% Exploring posterior variance for perfectly observed telegraph process
% plots the difference in posterior variance as a function of the last
% dwell time
alpha=alpha0+n; % hyperparam of Gamma prior over h
beta=beta0+t; % second hyperparam of Gamma prior over h
%n=4;     % # of time steps elapsed before computing difference in variance
%t=3;     % time elapsed before computing difference in variance
dt=dtmin:0.001:dtmax; % range of last dwell times to investigate

% analytical value for change of sign of derivative of posterior variance
C=beta*((sqrt((alpha+1)*alpha)/alpha)-1);

% if X~Gamma(a,b), then var(X)=a/b^2;
var2=(alpha+1)./((beta+dt).^2); % posterior variance at point n+1
var1=(alpha/(beta^2))*ones(size(var2)); % posterior var at point n

% plot var(n+1) - var(n)
figure(1)
ax=axes;
p1=plot(dt,var2-var1,'-b','LineWidth',3);
hold on
longExp=beta^2-alpha*dt.^2-2*alpha*beta*dt;
%p11=plot(dt,longExp,'-b','LineWidth',3);
p3=line([0,dtmax],[0,0],'Color',[0,0,0],'LineWidth',2); % analytical change of sign of the diff
p4=plot(alpha/beta,0,'*r','MarkerSize',14,'LineWidth',2);
p2=line([C,C],get(ax,'YLim'),'Color',[.7,.7,.7],'LineWidth',3); % analytical change of sign of the diff
hold off
legend([p1,p2,p4],'dvar','theo root','mean dt')
xlabel('dwell time')
ylabel('increment in var')
%title('posterior variance step over h')
title(['alpha0=',num2str(alpha0),'; beta0=',num2str(beta0),'; n=',num2str(n),'; t=',num2str(t)])
ax.FontSize=20;

end