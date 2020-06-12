global S1 S2
global G TR N M

global stratactions
%         beker elore visszavon
stratactions = [1 2 3];
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

plnum=1;
oppPlnum=2;

stratA=1;

try
simulator(@strategy_err,@strategy_err);
catch
end

tactical_action = strategicBreakdown(G,TR,S1,S2,N,M,plnum,stratA)