function [action,state] = strategy_humancontrol(G,TR,S1,S2,N,M,plnum,state)
    global pressed_key
%     action = round(rand*4)*ones(size(S1,1),1);    
%     %action = 4*ones(size(S1,1),1);
     state = 0;

%player's actions are determined by user input
    if(plnum==1)
        myS = S1;
    elseif(plnum==2)
        myS = S2;
    end
    
    action = 4*ones(size(myS,1),1);
    for i=1:size(myS,1);
        xchk = -10;
        while(xchk < 0)            
            [xchk ychk] = ginput(1);                    
        end
        %determine which tank was chosen
        dist = sqrt(sum((TR(:,1:2)-repmat([xchk ychk],size(TR(:,1:2),1),1)).^2,2));
        [minp indp] = min(dist);
        nchk = TR(indp,:);
        typ=nchk(3);
        if(plnum==2)
            typ = typ - size(S1,1);
        end
        if(typ > 0)
            if(typ <= size(myS,1))                
                action(typ) = pressed_key;
            end
        end
                
    end    

return;