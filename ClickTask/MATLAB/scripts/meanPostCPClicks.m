function mean_gamma_inferred = meanPostCPClicks(P)
% P is the 3D joint posterior
% returns mean_gamma_inferred, an 1-by-N vector representing the evolution
% of the mean posterior change point count as function of time
global N
margA = squeeze(sum(P,2));
cp=0:N-1;
mean_gamma_inferred = cp * margA;
end