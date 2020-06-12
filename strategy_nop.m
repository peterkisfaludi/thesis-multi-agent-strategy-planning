function [action,state] = strategy_nop(G,TR,S1,S2,N,M,plnum,state)
    if(plnum==1)
        myS = S1;
    elseif(plnum==2)
        myS = S2;
    end
    action = 4*ones(size(myS,1),1);
    state = 0;    

return;