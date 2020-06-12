%train for "destroy" strategic command execution
clear all
global theta theta_f w WINNER SILENTMODE
global S1 S2
global G TR N M MAXLEPES
MAXLEPES=300;

%start RL
SILENTMODE = true;
warning off;
locmaxnum = 2;
stepnum = 10;
maxPerf = -Inf;
maxindex = 1;
for j=1:locmaxnum
    theta = zeros(24*16,1);
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
        simulator(@strategy_rl_destroy,@strategy_purerandom);            
        [moreUnit moreHP moreEncircle moreSpread oppDistance] = feature_detection(1:4,10,6,G,TR,N,M,S1,S2,1);
        perf=perf+moreUnit;
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