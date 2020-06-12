function ta = lookUpTacticalActionCode(tac)
    grA1=floor(tac/10);
    grA2=mod(tac,10);
    ta=[grA1;grA2];
end