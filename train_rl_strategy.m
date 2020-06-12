%train strategy
%clear all
global theta theta_f w WINNER SILENTMODE
global S1 S2
global G TR N M MAXLEPES
MAXLEPES=Inf;
%start RL
SILENTMODE = false;
warning off;
locmaxnum = 3;
stepnum = 10;
maxPerf = -Inf;
maxindex = 1;
for j=1:locmaxnum
    theta = zeros(24*4,1);
    w = theta;
    theta_f = theta;
    perf = 0;
    for i=1:stepnum
        %init map
        S1=[10 0 2;
            11 0 2;
            12 0 2;
            13 0 2;        
            ];
        S2=[55 0 2;
            54 0 2;
            53 0 2;
            52 0 2
            ];
        simulator(@strategy_rl_strategy,@strategy_purerandom);            
        if(WINNER == 1)
            perf=perf+1;
        end        
    end
    avgPerf=perf/stepnum;
    strats(j).theta = theta;
    strats(j).avgPerf = avgPerf;
    if(avgPerf > maxPerf)
        maxPerf = avgPerf;
        maxindex = j;
    end
end
theta = strats(maxindex).theta;
avgPerf = strats(maxindex).avgPerf;
SILENTMODE = false;    