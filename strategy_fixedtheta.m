function [action,state] = strategy_fixedtheta(G,TR,S1,S2,N,M,plnum,state)
    myS = [S1;S2];
    global actions theta;
    actions = [00 01 02 03 10 11 12 13 20 21 22 23 30 31 32 33];
    action = select_action(myS,theta,0.05,G,TR,N,M);
    groups = makeGroups(G,TR,S1,S2,N,M,6,1);
    tact_actions = lookUpTacticalActionCode(action);
    gr1unitA=tacticalBreakdown(G,TR,S1,S2,N,M,groups,1,tact_actions(1));
    gr2unitA=tacticalBreakdown(G,TR,S1,S2,N,M,groups,2,tact_actions(2));
    action=distributeUnitActions(groups,gr1unitA,gr2unitA);
end

%% functions
function a = select_action(s,theta,epsilon,G,TR,N,M)        
    global actions;    
    rnd = rand;
    sm = 0;
    a = actions(1);
    for i=1:length(actions)
       sm = sm + policy(s,actions(i),theta,G,TR,N,M);
       if (sm >= rnd)
           a = actions(i);          
           break;
       end
    end

    %e-greedy stratégia
    %epsilon = 0.05;
    rnd = rand;
    if (rnd < epsilon)        
        a = actions(ceil(rand*length(actions)));        
    end      
end

%calculate probability of choosing action a from state s according to
%policy parametrized by theta
function p = policy(s,a,theta,G,TR,N,M)    
    global actions;    
    sm = 0;
    for i = 1:length(actions)
        b = actions(i);
        phi_sb = phi(s,b,G,TR,N,M);
        sm = sm+exp(theta'*phi_sb);
    end
    phi_sa = phi(s,a,G,TR,N,M);
    p = exp(theta'*phi_sa) / sm;    
end

function phi_sa = phi(s,a,G,TR,N,M)
    global actions
    plnum=1;
    alen = length(actions);
    salen = 24;
    
    ROI_length=6;
    S1=s(1:4,:);
    S2=s(5:8,:);
    
    myGroups = makeGroups(G,TR,S1,S2,N,M,ROI_length,plnum);
    oppGroups = makeGroups(G,TR,S1,S2,N,M,ROI_length,plnum+1);
    myGroupLeaders=myGroups(:,1);
    oppGroupLeaders=oppGroups(:,1);
    
    %my groups
    mypos1 = TR(s(myGroupLeaders(1),1),1:2);
    myposx1 = mypos1(1);
    myposy1 = mypos1(2);
    
    mypos2 = TR(s(myGroupLeaders(2),1),1:2);
    myposx2 = mypos2(1);
    myposy2 = mypos2(2);            

    %opponent groups
    opppos1 = TR(s(oppGroupLeaders(1),1),1:2);
    oppposx1 = opppos1(1);
    oppposy1 = opppos1(2);
    
    opppos2 = TR(s(oppGroupLeaders(2),1),1:2);
    oppposx2 = opppos2(1);
    oppposy2 = opppos2(2);
    
    %my position feature vector
    mysx1 = [1 0];        
    if(myposx1>=250)
        mysx1 = [0 1];
    end

    mysy1 = [1 0];
    if(myposy1>=250)
        mysy1 = [0 1];
    end
    
    mysx2 = [1 0];        
    if(myposx2>=250)
        mysx2 = [0 1];
    end

    mysy2 = [1 0];
    if(myposy2>=250)
        mysy2 = [0 1];
    end
    
    %opponent position feature vector
    oppsx1 = [1 0];        
    if(oppposx1>=250)
        oppsx1 = [0 1];
    end

    oppsy1 = [1 0];
    if(oppposy1>=250)
        oppsy1 = [0 1];
    end
    
    oppsx2 = [1 0];        
    if(oppposx2>=250)
        oppsx2 = [0 1];
    end

    oppsy2 = [1 0];
    if(oppposy2>=250)
        oppsy2 = [0 1];
    end    
    
    %global features
    myUnits=1:4;
    ROI=10;
    [moreUnit moreHP moreEncircle moreSpread] = feature_detection(myUnits,ROI,ROI_length,G,TR,N,M,S1,S2,plnum);
    %pause
    
    moUn = [1 0];
    if(moreUnit > 0.5)
        moUn=[0 1];
    end

    moHp = [1 0];
    if(moreHP > 0.5)
        moHp=[0 1];
    end
    
    moEn = [1 0];
    if(moreEncircle > 0.5)
        moEn=[0 1];
    end
    
    moSp = [1 0];
    if(moreSpread > 0.5)
        moSp=[0 1];
    end
    
    phi_sa = zeros(alen*salen,1);
    sa = [moUn moHp moEn moSp mysx1 mysy1 mysx2 mysy2 oppsx1 oppsy1 oppsx2 oppsy2];
    aloc = find(a==actions);
    phi_sa((aloc-1)*salen+1:aloc*salen)=sa;
end