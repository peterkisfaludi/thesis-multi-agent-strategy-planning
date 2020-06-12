function [action,state] = strategy_rl(G,TR,S1,S2,N,M,plnum,state)
    global theta theta_f w    
    global TR
    myS = [S1;S2];
    %action = round(rand(size(myS,1),1)*2);
    
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
    epsilon = 0.05;

    global actions;
    %       left right forward shoot
    actions = [0 1 2 3];
    %length of feature vector
    l=16*4;    

    %init
    if(isempty(state))
        s=myS;
        %w = zeros(l,1);        
        %theta = zeros(l,1);
        %theta_f = zeros(l,1);
        e = zeros(l,1);
        t=t0;
        action = select_action(s,theta,epsilon);
        
        state.s=s;
        state.w = w;
        state.theta = theta;
        state.theta_f = theta_f;
        state.e = e;
        state.t = t;
        state.a = action;
        action = repmat(action,2,1);
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
    r = get_reward(myS);    
    %r = get_reward(a);    
    sv = myS;
    
    %do the learning
    phi_sa = phi(s,a);
    phi_svav = phi(sv,select_action(sv,theta,0));    
    Qw_sa = w'*phi_sa;    
    Qw_svav = w'*phi_svav;
    sumphi = zeros(l,1);
    sumpi = 0;
    sumpif = 0;
    for b=1:length(actions)
        act = actions(b);
        phi_sb = phi(s,act);
        Qw_sb = w'*phi_sb;
        sumpi = sumpi + policy(s,act,theta)*Qw_sb;        
        sumpif = sumpif + policy(s,act,theta_f)*Qw_sb;        
    end    
    for b = 1:length(actions)
       act = actions(b);
       phi_sb = phi(s,act);
       Qw_sb = w'*phi_sb;
       fw_sb = Qw_sb - sumpi;       
       sumphi = sumphi + phi_sb*policy(s,act,theta)*fw_sb;         
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
    action = select_action(myS,theta,epsilon);
    
    %store data in state
    state.s = sv;
    state.w = w;
    state.theta = theta;
    state.theta_f = theta_f;
    state.e = e;
    state.t = t;
    state.a = action;
    action = repmat(action,2,1);

end

%% functions
function a = select_action(s,theta,epsilon)        
    global actions;    
    rnd = rand;
    sm = 0;
    a = actions(1);
    for i=1:length(actions)
       sm = sm + policy(s,actions(i),theta);
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
function p = policy(s,a,theta)    
    global actions;    
    sm = 0;
    for i = 1:length(actions)
        b = actions(i);
        phi_sb = phi(s,b);
        sm = sm+exp(theta'*phi_sb);
    end
    phi_sa = phi(s,a);
    p = exp(theta'*phi_sa) / sm;    
end

function phi_sa = phi(s,a)
    global actions TR
    alen = length(actions);
    salen = 16;
    
    pos1 = TR(s(1,1),1:2);
    posx1 = pos1(1);
    posy1 = pos1(2);
    
    pos2 = TR(s(2,1),1:2);
    posx2 = pos2(1);
    posy2 = pos2(2);
    
    ori1 = s(1,2);
    ori2 = s(2,2);
    
%     hp1  = s(1,3);
%     hp2  = s(2,3);
    

    %player 1's feature vector
    if(posx1>=0 && posx1<250)
        sx1 = [1 0];
    elseif(posx1>=250 && posx1<=500)
        sx1 = [0 1];
    end

    if(posy1>=0 && posy1<250)
        sy1 = [1 0];
    elseif(posy1>=250 && posy1<=500)
        sy1 = [0 1];
    end

    if(ori1==0)
        so1 = [1 0 0 0];
    elseif(ori1==90)
        so1 = [0 1 0 0];
    elseif(ori1==180)
        so1 = [0 0 1 0];
    elseif(ori1==270)
        so1 = [0 0 0 1];
    end
    
    %player2's feature vectror
    if(posx2>=0 && posx2<250)
        sx2 = [1 0];
    elseif(posx2>=250 && posx2<=500)
        sx2 = [0 1];
    end

    if(posy2>=0 && posy2<250)
        sy2 = [1 0];
    elseif(posy2>=250 && posy2<=500)
        sy2 = [0 1];
    end

    if(ori2==0)
        so2 = [1 0 0 0];
    elseif(ori2==90)
        so2 = [0 1 0 0];
    elseif(ori2==180)
        so2 = [0 0 1 0];
    elseif(ori2==270)
        so2 = [0 0 0 1];
    end
    
    phi_sa = zeros(alen*salen,1);
    sa = [sx1 sy1 so1 sx2 sy2 so2];
    aloc = find(a==actions);
%     if(a==actions(1))
%         phi_sa(1:salen)=sa;
%     elseif(a==actions(2))
%         phi_sa(salen+1:2*salen)=sa;
%     elseif(a==actions(3))
%         phi_sa(2*salen+1:3*salen)=sa;
%     elseif(a==actions(4))
%         phi_sa(3*salen+1:4*salen)=sa;
%     end
    phi_sa((aloc-1)*salen+1:aloc*salen)=sa;
end

function r=get_reward(s)
    global P1_score P2_score
    %normal approach
%     hp1  = s(1,3);
%     hp2  = s(2,3);
%     r=-1;
%     if(hp2==1)
%         r=r + 10;
%     end
%     if(hp2==0)
%         r=r + 100;
%     end
%     if(hp1==1)
%         r=r - 10;
%     end
%     if(hp1==0)
%         r=r - 100;
%     end
%     if(P1_score > P2_score)
%         r = r + 10;
%     else
%         r = r - 1;
%     end
    
    %try to allways score
    if(P1_score > P2_score)
        r = 10;
    else
        r = -10;
    end
end

