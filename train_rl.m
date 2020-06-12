global theta theta_f w WINNER SILENTMODE
SILENTMODE = true;
warning off;
locmaxnum = 5;
stepnum = 30;
maxwinnum = 0;
maxindex = 1;
for j=1:locmaxnum
    theta = zeros(16*4,1);
    w = theta;
    theta_f = theta;
    winnum = 0;
    for i=1:stepnum    
        simulator(@strategy_rl,@strategy_purerandom);            
        %simulator(@strategy_rl,@strategy_randomwalk);
        if(WINNER == 1)
            winnum = winnum + 1;
        end
    end
    avgwinnum=winnum/stepnum;
    strats(j).theta = theta;
    strats(j).avgwinnum = avgwinnum;
    if(avgwinnum > maxwinnum)
        maxwinnum = avgwinnum;
        maxindex = j;
    end
end
theta = strats(maxindex).theta;
SILENTMODE = false;    