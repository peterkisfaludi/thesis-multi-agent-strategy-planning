function unit_action = tacticalBreakdown(G,TR,S1,S2,N,M,groups,groupInd,tactA)
%simple breakdown: everybody does the same thing
unit_action=[tactA;tactA];
%if orientation of follower differs from leader's
%groups = makeGroups(G,TR,S1,S2,N,M,6,1);
group=groups(groupInd,:);
leader=group(1);
follower=group(2);
if(follower==0)
    return;
end
leaderOri=S1(leader,2);
followerOri=S1(follower,2);
oriDiff=leaderOri-followerOri;
%default follower action is left
folAct=0;
switch oriDiff
    case 0
        return;
    case 270
        folAct=1;
    case -90
        folAct=1;
end
unit_action(2)=folAct;
end