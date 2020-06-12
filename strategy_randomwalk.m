function [action,state] = strategy_randomwalk(G,TR,S1,S2,N,M,plnum,state)
    if(plnum==1)
        myS = S1;
    elseif(plnum==2)
        myS = S2;
    end
    action = round(rand(size(myS,1),1)*2);
    state = 0;    

return;