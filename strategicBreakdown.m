function tactical_action = strategicBreakdown(G,TR,S1,S2,N,M,plnum,groups,stratA)
    load('refDB7.mat');
    %global refDB
    S=[S1;S2];
    %refDB
    refs=refDB{stratA+1};
    groupLeaders=groups(:,1);
    refdist = zeros(size(refs));    
    for i=1:length(refs)
        ref=refs(i);
        ROI_length=6;        
        refgroups = makeGroups (ref.G,ref.TR,ref.S1,ref.S2,N,M,ROI_length,plnum);        
        refgroupLeaders=refgroups(:,1);
        rDist=0;
        for j=1:length(groupLeaders)
            groupLeader=groupLeaders(j);
            leaderpos=S(groupLeader,1);
            leaderx=TR(leaderpos,1);
            leadery=TR(leaderpos,2);
            leaderDistList=Inf*ones(size(refgroupLeaders));
            for k=1:length(refgroupLeaders)
                refgroupLeader=refgroupLeaders(k);
                if(refgroupLeader==0)
                    continue;
                end
                refleaderpos=ref.S1(refgroupLeader,1);
                if(plnum==2)
                    refleaderpos=ref.S2(refgroupLeader,1);
                end
                refleaderx=ref.TR(refleaderpos,1);
                refleadery=ref.TR(refleaderpos,2);
                leader_dist=sqrt((leaderx-refleaderx)^2+(leadery-refleadery)^2);
                leaderDistList(k)=leader_dist;
            end
            [mTmp mLeadInd] = min(leaderDistList);
            refgroupLeaders(mLeadInd) = 0;
            rDist = rDist + mTmp;
        end
        refdist(i)=rDist;
    end
    %refdist
    [mTmp,mInd]=min(refdist);
    mr=refs(mInd);
    
    tactical_action_code=strategy_rl_fixedtheta(G,TR,S1,S2,mr.theta,N,M);    
    tactical_action = lookUpTacticalActionCode(tactical_action_code);
    return;
end