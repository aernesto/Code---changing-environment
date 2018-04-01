% Aim of this script is to compare the solution of the ODEs for the LLR in
% the clicks task with known h from Rudemo 1972 and from us.
clear
% Get 1 synthetic trial (with single stream of clicks)
stream = [.2,.25,.4,.9];
highrate=20;
lowrate=10;
kappa=log(highrate/lowrate);
% compute evolution of p according to our model
euler_dt=0.0001;
T=1;
h=2;
init_cond=0;
params= [init_cond,highrate,lowrate,euler_dt,T,h];
tic
p_ours = evolveOurOde(stream, params, true);
toc
% compute evolution of p according to Rudemo's model
paramsRudemo= [init_cond,highrate,lowrate,euler_dt,T,h];
tic
p_Rudemo = evolveRudemoOde(stream, paramsRudemo, true);
toc
% plot both on same graph, and show true state on graph
time=0:euler_dt:T;
plot(time, p_ours,time,p_Rudemo,'LineWidth',3)
legend('our model','Rudemo')
xlabel('time')
ylabel('LLR')
title('comparison of ODEs')
ax=gca;
ax.FontSize=20;