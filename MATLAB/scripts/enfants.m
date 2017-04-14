function d=enfants(node)
%returns the 2 children of node as a 2x6 matrix
    %1st row is the child at H^+=1. 
    %2nd row is the child at H^-=0
    d=zeros(2,6);
    t=node(1);
    state=node(2);
    d(:,1)=[t+1;t+1];
    d(:,2)=[1;0];
    if state %H^+
        d(1,3:end)=node(3:end)+[1,0,0,0];%stay
        d(2,3:end)=node(3:end)+[0,1,0,0];%jump
    else %H^-
        d(1,3:end)=node(3:end)+[0,0,1,0];%jump
        d(2,3:end)=node(3:end)+[0,0,0,1];%stay
    end
end