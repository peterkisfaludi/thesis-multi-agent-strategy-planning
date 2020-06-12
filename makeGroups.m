function [groups] = makeGroups (G,TR,S1,S2,N,M,ROI_length,plnum)        
    myS = S1;
    oppS = S2;
    if(plnum==2)
        myS=S2;
        oppS=S1;
    end
    myS_size = size(myS,1);
    oppS_size = size(oppS,1);
    S=[S1;S2];
    group_size = 2;
    tankindBegin=0;
    if (plnum==2)
        tankindBegin=size(S1,1);
    end
    maxdist = ROI_length*sqrt(2);
    myUnits=1+tankindBegin:myS_size+tankindBegin;
    group=[];
    groups=[];
    for i=1:length(myUnits)
        myUnit=myUnits(i);
        if(myUnit==0)
            continue
        end
        nodeInd = S(myUnit,1);
        posx=TR(nodeInd,1);
        posy=TR(nodeInd,2);
        
        group = [group myUnit];
        neighs=myUnits;
        neighs(i)=[];
        neighsdist=Inf*ones(size(neighs));
        for j=1:length(neighs)
            neigh=neighs(j);
            if(neigh==0)
                continue;
            end
            neighInd=S(neigh,1);
            neighx=TR(neighInd,1);
            neighy=TR(neighInd,2);        
            dist=sqrt((posx-neighx)^2+(posy-neighy)^2);                    
            neighsdist(j)=dist;
        end
        for k=1:group_size-1
            [mTemp,mInd] = min(neighsdist);                            
            mNeigh = neighs(mInd);
            if(isfinite(mTemp)==0)
                group = [group 0];
            else
                group = [group mNeigh];
            end
            neighsdist(mInd)=Inf;
            myUnits(find(myUnits==mNeigh)) = 0;
        end
        groups = [groups;group];
        myUnits(i)=0;
        group = [];
    end    
end