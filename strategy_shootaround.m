function [action,state] = strategy_shootaround(G,TR,S1,S2,N,M,plnum,state)
    if(plnum==1)
        myS = S1;
    elseif(plnum==2)
        myS = S2;
    end
    if(state == 's')
        state = 't';
        action = 3*ones(size(myS,1),1);
    elseif(state == 't')
        state = 's';
        action = round(rand*1)*ones(size(myS,1),1);
    else
        state = 's';
        action = round(rand*1)*ones(size(myS,1),1);
    end
    
        

return;