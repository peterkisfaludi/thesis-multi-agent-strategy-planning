%[G,TR,N,M]=platform_template_featuretest();
global S1 S2
global G TR N M
S1=[30 0 2;
    22 0 2;
    23 0 2;
    35 0 2;
    34 0 2;
    39 0 2;
    47 0 2;
    ];
S2=[31 0 4;    
    38 0 2;
    29 0 2
    ];
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

%S1=[10 0 2];
%S2=[11 0 2];

plnum=1;
oppPlnum=2;
myUnits=[1 2 3 4];
ROI=10;
ROI_length=6;

try
simulator(@strategy_err,@strategy_err);
catch
end
[moreUnit moreHP moreEncircle moreSpread oppDistance] = feature_detection(myUnits,ROI,ROI_length,G,TR,N,M,S1,S2,plnum)
myGroups = makeGroups(G,TR,S1,S2,N,M,ROI_length,plnum)
oppGroups = makeGroups(G,TR,S1,S2,N,M,ROI_length,oppPlnum)

try
simulator(@strategy_err,@strategy_err);
catch
end