%produces the required .mat file for panels A and C-E of figure 4
%simulation of the 2-state asymmetric case
%requires functions createNodes() and enfants()

clear
rng('shuffle')

datapath='~/matlabCode/data/';  %path where to save the .mat file
filename='fig4AC';              %name of .mat file that is output

% parameters and variables initializations
T=200;               %number of time steps
res=40;              %number of points for posteriors over eps
snr=1.4;             %width of likelihoods
epsilons=[.2,.1];    %[eps+,eps-]

data=zeros(1,T);    %observed data
envt=data;          %true state

eps=[1-epsilons(1),epsilons(2);      %true rates eps(i,j) is the rate of transition j->i
    epsilons(1), 1- epsilons(2)];
m = [1;0];       %means of likelihoods for H^+=1,H^-=0 respectively


epsValues=linspace(0,1,res);
[X,Y]=meshgrid(epsValues,epsValues);%X for eps+, Y for eps-
Z=ones([size(X),T]);                %will store the posterior density over eps+,eps-
meanEps=zeros(2,T);                 %first row for eps+, 2nd for eps-

sigma=1/snr;
priorState=[.5;.5]; %priors over state

% initialization of forthcoming loop
%initialize environment and observe first datum
strue=randi(2)-1;
envt(1)=strue;
x = strue+sigma*randn;

data(1)=x;

%create the list of positive nodes at time 1
%each row is a node. Its entries are:
%1. time n-1
%2. state at time n-1
%3. a^11, a^21, a^12, a^22
prevNodes=[1,1,0,0,0,0;
           1,0,0,0,0,0];

%posterior odds ratio
R=zeros(1,T);
       
%set all mass at those nodes for time 1
nprevNodes=size(prevNodes,1);
prevMass=exp(-(x-prevNodes(:,2)).^2/(2*sigma^2)).*priorState;
R(1)=prevMass(1)/prevMass(2);   %posterior odds ratio
prevMass=prevMass/sum(prevMass);%normalize
meanEps(:,1)=[.5;.5];           %doesn't take into account non-uniform prior


% start loop over time t>=2
    %at each t, I loop over the current nodes
        %for each current node, I give it the mass inherited from his 2 
        %ancestors
for t=2:T %t is the present
    
    %update environment and observe data point at time t
    if strue %H^+
            strue=randsample(m,1,true,eps(:,1));
    else
            strue=randsample(m,1,true,eps(:,2));
    end
    envt(t)=strue;
    x = strue+sigma*randn;
    
    data(t)=x;
    
    %create current list (t) 
    currNodes=createNodes(t);
    
    ncurrNodes=t*(t-1)+2;    %number of nodes at time t
    newMass=zeros(ncurrNodes,1);

    %start loop over nodes from previous list (t-1)
    for l=1:nprevNodes
        node=prevNodes(l,:);
        
        %compute empirical exit rates
        state=node(2);%last state to which the node corresponds
        %the following indices only work for the length 6 nodes
            %[time,state,a11,a21,a12,a22]
        if state %H^+
            stay=3; %+ -> +
            jump=4; %+ -> -
            order=[1,2]; %needed to put epHat in the right order
        else %H^-
            stay=6; %- -> -
            jump=5; %- -> +
            order=[2,1];
        end

        totExitRate=sum(node([stay,jump]));
        epHat=(node([stay,jump])'+1)/(2+totExitRate);
        epHat=epHat(order);
        %now epHat(1) is the probability of transition 'state' -> H^+
        %epHat(2) is the prob. of transition 'state' -> H^-
        
        %find children nodes - only two possibilities 
        children=enfants(node); %the 1st row is now at H^+ and 2nd row at H^-
        
        %get indices of these children in the current list
        [lia,rowIndx]=ismember(children,currNodes,'rows');

        %mass transfer
        %send messages to children
        newMass(rowIndx)=newMass(rowIndx)+prevMass(l)*epHat;
    end
    
    %multiply all nodes from current list by their
    %corresponding likelihood
        %get current states of new node
    currStates=currNodes(:,2);
        %update corresponding mass
    newMass=exp(-(x-currStates).^2/(2*sigma^2)).*newMass;
    
    R(t)=sum(newMass(currNodes(:,2)==1))/sum(newMass(currNodes(:,2)==0));
    
    %normalize 
    newMass=newMass/sum(newMass);
    
    %form the new prevMass and previousNodes vectors for next iteration
    prevMass=newMass;
    prevNodes=currNodes;
    nprevNodes=ncurrNodes;
        
    %infer the rates
    for epsPlus=1:res
        for epsMinus=1:res
            %compute the posterior joint density
            BetaNodes=currNodes+1;%doesn't take into account non-uniform priors over epsilons
            BetaVec=betapdf(repmat(epsValues(epsPlus),ncurrNodes,1),...
                BetaNodes(:,4),BetaNodes(:,3)).*...
                betapdf(repmat(epsValues(epsMinus),ncurrNodes,1),...
                BetaNodes(:,5),BetaNodes(:,6));
            Z(epsPlus,epsMinus,t)=dot(BetaVec,newMass);
            %compute the posterior mean, using the closed form formula
            
            hatEpsVec=[BetaNodes(:,4)./...
                                        sum(BetaNodes(:,3:4),2),...
                       BetaNodes(:,5)./...
                                        sum(BetaNodes(:,5:6),2)]';
            meanEps(:,t)=hatEpsVec*newMass;
        end
    end 
end
save([datapath,filename,'.mat'],'-v7.3')
