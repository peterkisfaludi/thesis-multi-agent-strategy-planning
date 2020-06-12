function [action,state] = strategy_rl_strategy(G,TR,S1,S2,N,M,plnum,state)
    %global theta_f w    
    %global G TR N M S1 S2 plnum
    global MAXLEPES
    MAXLEPES = Inf;
    global stratactions;
    %       encircle advance retreat destroy
    stratactions = [0 1 2 3];    
    
    %test
    stratA=round(rand*3);
    %action=1;
    groups = makeGroups(G,TR,S1,S2,N,M,6,plnum);
    tact_actions = strategicBreakdown(G,TR,S1,S2,N,M,plnum,groups,stratA);
    gr1unitA=tacticalBreakdown(G,TR,S1,S2,N,M,groups,1,tact_actions(1));
    gr2unitA=tacticalBreakdown(G,TR,S1,S2,N,M,groups,2,tact_actions(2));
    action=distributeUnitActions(groups,gr1unitA,gr2unitA);
    return;
    
    %% ------------ reinforcement learning --------------- 
    %params
    alpha = 0.3;
    delta_l = 0.2;
    delta_w = 0.008;
    beta = 0.6;
    lambda = 0.5;
    gamma = 0.99;
    dt = 1;
    t0 = 0;
    epsilon = 0.9;
    
    %length of feature vector
    l=24*4;
    
    %init
    if(isempty(state))
        s=myS;
        e = zeros(l,1);
        t=t0;
        action = select_action(s,theta,epsilon,G,TR,N,M);
        
        state.s=s;
        state.w = w;
        state.theta = theta;
        state.theta_f = theta_f;
        state.e = e;
        state.t = t;
        state.a = action;
        tact_actions = strategicBreakdown(G,TR,S1,S2,N,M,plnum,groups,action);
        gr1unitA=tacticalBreakdown(G,TR,S1,S2,N,M,groups,1,tact_actions(1));
        gr2unitA=tacticalBreakdown(G,TR,S1,S2,N,M,groups,2,tact_actions(2));
        action=distributeUnitActions(groups,gr1unitA,gr2unitA);
        return;
    end
    %retrieve data from state
    s = state.s;
    w = state.w;
    theta = state.theta;
    theta_f = state.theta_f;
    e = state.e;
    t = state.t;
    a = state.a;

    %(b) observe reward and next state
    r = get_reward(G,TR,S1,S2,N,M,plnum);    
    %r = get_reward(a);    
    sv = myS;
    
    %do the learning
    phi_sa = phi(s,a,G,TR,N,M);
    phi_svav = phi(sv,select_action(sv,theta,0),G,TR,N,M);    
    Qw_sa = w'*phi_sa;    
    Qw_svav = w'*phi_svav;
    sumphi = zeros(l,1);
    sumpi = 0;
    sumpif = 0;
    for b=1:length(stratactions)
        act = stratactions(b);
        phi_sb = phi(s,act,G,TR,N,M);
        Qw_sb = w'*phi_sb;
        sumpi = sumpi + policy(s,act,theta,G,TR,N,M)*Qw_sb;        
        sumpif = sumpif + policy(s,act,theta_f,G,TR,N,M)*Qw_sb;        
    end    
    for b = 1:length(stratactions)
       act = stratactions(b);
       phi_sb = phi(s,act,G,TR,N,M);
       Qw_sb = w'*phi_sb;
       fw_sb = Qw_sb - sumpi;       
       sumphi = sumphi + phi_sb*policy(s,act,theta,G,TR,N,M)*fw_sb;         
    end    
    delta = delta_l;
    if (sumpi > sumpif)
        delta = delta_w;
    end    
       
    e = lambda*gamma^dt*e+phi_sa;    
    w = w + e*alpha*(r+gamma^dt*Qw_svav-Qw_sa);        
    theta = theta+gamma^t*delta*sumphi;
    
    %(c) Maintain average parameter vector (theta_f)
    theta_f = (1-beta)*theta_f + beta*theta;
    %(d) decay alpha and beta  
    t=t+dt;
    
    %(a) select action according to mixed strategy
    action = select_action(myS,theta,epsilon,G,TR,N,M);
    
    %store data in state
    state.s = sv;
    state.w = w;
    state.theta = theta;
    state.theta_f = theta_f;
    state.e = e;
    state.t = t;
    state.a = action;
    tact_actions = strategicBreakdown(G,TR,S1,S2,N,M,plnum,groups,action);
    gr1unitA=tacticalBreakdown(G,TR,S1,S2,N,M,groups,1,tact_actions(1));
    gr2unitA=tacticalBreakdown(G,TR,S1,S2,N,M,groups,2,tact_actions(2));
    action=distributeUnitActions(groups,gr1unitA,gr2unitA);
end

%% functions
function a = select_action(s,theta,epsilon,G,TR,N,M)        
    global stratactions;    
    rnd = rand;
    sm = 0;
    a = stratactions(1);
    for i=1:length(stratactions)
       sm = sm + policy(s,stratactions(i),theta,G,TR,N,M);
       if (sm >= rnd)
           a = stratactions(i);          
           break;
       end
    end

    %e-greedy stratégia
    %epsilon = 0.05;
    rnd = rand;
    if (rnd < epsilon)        
        a = stratactions(ceil(rand*length(stratactions)));        
    end      
end

%calculate probability of choosing action a from state s according to
%policy parametrized by theta
function p = policy(s,a,theta,G,TR,N,M)    
    global stratactions;    
    sm = 0;
    for i = 1:length(stratactions)
        b = stratactions(i);
        phi_sb = phi(s,b,G,TR,N,M);
        sm = sm+exp(theta'*phi_sb);
    end
    phi_sa = phi(s,a,G,TR,N,M);
    p = exp(theta'*phi_sa) / sm;    
end

function phi_sa = phi(s,a,G,TR,N,M)
    global stratactions
    plnum=1;
    alen = length(stratactions);
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
    aloc = find(a==stratactions);
    phi_sa((aloc-1)*salen+1:aloc*salen)=sa;
end

function r=get_reward(G,TR,S1,S2,N,M,plnum)
    %global P1_score P2_score
    ROI=10;
    ROI_length=6;
    myUnits=1:4;
    [moreUnit moreHP moreEncircle moreSpread oppDistance] = feature_detection(myUnits,ROI,ROI_length,G,TR,N,M,S1,S2,plnum);
    %TODO: set r in a sophisticated way
    r=moreUnit;
end

