function actions = distributeUnitActions(groups,gr1unitA,gr2unitA)
gr1=groups(1,:);
gr2=groups(2,:);
actions=zeros(4,1);
for i=1:2
    unitInd=gr1(i);
    actions(unitInd)=gr1unitA(i);
end
for i=1:2
    unitInd=gr2(i);
    actions(unitInd)=gr2unitA(i);
end