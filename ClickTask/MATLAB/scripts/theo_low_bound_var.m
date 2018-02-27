clear
%exploring the theoretical posterior variance
n=1:10;
t=1:.1:4;
[X,Y]=meshgrid(n,t);
Z=(1+X) ./ (1+Y).^2;
surf(X,Y,Z)