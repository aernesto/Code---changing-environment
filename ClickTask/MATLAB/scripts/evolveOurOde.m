function x=evolveOurOde(train, params, fullEvolution)
% train: vector containing positive times of clicks
% params: [init, k,dt,T,h]
    nclicks=length(train);
    init=params(1); % intial condition
    highrate= params(2);
    lowrate=params(3);
    diffrate=highrate-lowrate;
    k = log(highrate/lowrate);  % jump size
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
            deriv = -diffrate-2*h*sinh(x(t));
            x(new_idx)=x(t) + deriv*dt;
        else
            deriv = -diffrate-2*h*sinh(x);
            x=x+deriv*dt;
        end
        if time>nxtclick
            if fullEvolution
                x(new_idx)=x(new_idx)+k; % add jump to solution
            else
                x=x+k;
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