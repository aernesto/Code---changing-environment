function x=evolveRudemoOde(train, params, fullEvolution)
% train: vector containing positive times of clicks
% params: [init, lambdahigh,lambdalow,dt,T,h]
    nclicks=length(train);
    init=params(1); % intial condition
    highrate = params(2);  % arrival rate 1
    lowrate= params(3);    % arrival rate 2
    diff=highrate-lowrate;
    dt= params(4);  % step size for Euler
    T= params(5);   % trial length
    h= params(6);   % hazard rate
    clicks_left=nclicks;
    if nclicks > 0
        nxtclickidx=1;
        nxtclick=train(nxtclickidx);
    else
        nxtclick=inf;
    end
    nbins=floor(T/dt);
    if fullEvolution
        x=zeros(1,nbins+1); % x(1)=init
        x(1)=init;
    else
        x=init;
    end
    for t=1:nbins
        new_idx=t+1;
        time = t*dt;
        if fullEvolution
            denom=highrate*exp(x(t))+lowrate;
            deriv = -2*h*sinh(x(t))-diff/denom;
            x(new_idx)=x(t) + deriv*dt;
        else
            denom=highrate*exp(x)+lowrate;
            deriv=-2*h*sinh(x)-diff/denom;
            oldx=x;
            x=x+deriv*dt;
        end
        if time>nxtclick
            if fullEvolution
                jump=diff*(exp(x(t))+1)/denom;
                x(new_idx)=x(new_idx)+jump; % add jump to solution
            else
                jump=diff*(exp(oldx)+1)/denom;
                x=x+jump;
            end
            clicks_left=clicks_left-1;
            if clicks_left > 0
                nxtclickidx=nxtclickidx+1;
                nxtclick=train(nxtclickidx);
            else
                nxtclick=inf;
            end
        end
    end
end