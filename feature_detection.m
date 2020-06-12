function [moreUnit moreHP moreEncircle moreSpread oppDistance] = feature_detection(myUnits,ROI,ROI_length,G,TR,N,M,S1,S2,plnum)
myS = S1;
oppS = S2;
if(plnum==2)
    myS=S2;
    oppS=S1;
end
myS_size = size(myS,1);
oppS_size = size(oppS,1);
S=[S1;S2];


myNum = 0;
oppNum = 0;
myAvgHP = 0;
oppAvgHP = 0;
myUnits = [];
oppUnits = [];

for row=0:ROI_length
    for col=0:ROI_length
        nodeInd=M*row+col+ROI;
        typ=TR(nodeInd,3);        
        if(typ>0)
            if(plnum==1)
                if(typ <= myS_size)
                    myNum = myNum+1;
                    myHP=S(typ,3);
                    myAvgHP = myAvgHP+myHP;
                    myUnits = [myUnits typ];
                else
                    oppNum = oppNum+1;
                    oppHP=S(typ,3);
                    oppAvgHP = oppAvgHP+oppHP;
                    oppUnits = [oppUnits typ];
                end
            elseif(plnum==2)
                if(typ > oppS_size)
                    myNum = myNum+1;
                else
                    oppNum = oppNum+1;
                end
            end
        end
    end
end

%calculate moreUnit feature
moreUnit = myNum/(myNum+oppNum);
if(isnan(moreUnit))
    %disp('moreunit wasnan');
    moreUnit=0.5;
end

%calculate moreHP feature
myAvgHP=myAvgHP/myNum;
oppAvgHP=oppAvgHP/oppNum;
moreHP = myAvgHP/(myAvgHP+oppAvgHP);
if(isnan(moreHP))
    %disp('moreHP wasnan');
    moreHP=0.5;
end

%calculate moreSpread feature
myAvgNdist = calculate_ndist(myUnits,S,TR);
oppAvgNdist = calculate_ndist(oppUnits,S,TR);
moreSpread = myAvgNdist/(myAvgNdist+oppAvgNdist);
if(isnan(moreSpread))
    %disp('moreSpread wasnan');
    moreSpread=0.5;
end

%calculate moreEncircle feature
myAvgEncircle=calculate_encircle(myUnits,oppUnits,S,TR,N,M);
oppAvgEncircle=calculate_encircle(oppUnits,myUnits,S,TR,N,M);
moreEncircle = myAvgEncircle/(myAvgEncircle+oppAvgEncircle);
if(isnan(moreEncircle))
    %disp('encircle wasnan');
    moreEncircle=0.5;
end

%calculate oppDistance feature
oppDistance = calc_group_dist(G,TR,S1,S2);
end

%% helper functions
function avgNdist = calculate_ndist(myUnits,S,TR)
neighdistlist = [];
for i=1:length(myUnits)
    myUnit=myUnits(i);
    nodeInd = S(myUnit,1);
    posx=TR(nodeInd,1);
    posy=TR(nodeInd,2);
    neighs=myUnits;
    neighs(i)=[];
    for j=1:length(neighs)
        neigh=neighs(j);
        neighInd=S(neigh,1);
        neighx=TR(neighInd,1);
        neighy=TR(neighInd,2);        
        neighdistlist=[neighdistlist sqrt((posx-neighx)^2+(posy-neighy)^2)];        
    end
end
avgNdist=sum(neighdistlist)/length(neighdistlist);
end

function avgEncircle = calculate_encircle(myUnits,oppUnits,S,TR,N,M)
avgEncircle=0;
for i=1:length(oppUnits)
    oppUnit=oppUnits(i);
    nodeInd=S(oppUnit);
    updl=[0 0 0 0];
    for j=1:length(myUnits)
        myUnit=myUnits(j);
        myNodeInd=S(myUnit);
        if(sameline('UP',nodeInd,myNodeInd,N,M))
            updl(1)=1;
        end
        if(sameline('DOWN',nodeInd,myNodeInd,N,M))
            updl(2)=1;
        end
        if(sameline('LEFT',nodeInd,myNodeInd,N,M))
            updl(3)=1;
        end
        if(sameline('RIGHT',nodeInd,myNodeInd,N,M))
            updl(4)=1;
        end
    end
    b=sum(updl,2)/4;
    avgEncircle = avgEncircle + b;
end
avgEncircle=avgEncircle/length(oppUnits);
end

function ret = sameline(DIR,oppNodeInd,myNodeInd,N,M)
%TODO: add line checking at perimeter
ret=0;
switch DIR
    case 'UP'
        for i=1:4
            nodeChk = oppNodeInd + i*M;
            if(nodeChk==myNodeInd)
                ret=1;
                break
            end
        end
    case 'DOWN'
        for i=1:4
            nodeChk = oppNodeInd - i*M;
            if(nodeChk==myNodeInd)
                ret=1;
                break
            end
        end
    case 'LEFT'
        for i=1:4
            nodeChk = oppNodeInd - i;
            if(nodeChk==myNodeInd)
                ret=1;
                break
            end
        end
    case 'RIGHT'
        for i=1:4
            nodeChk = oppNodeInd + i;
            if(nodeChk==myNodeInd)
                ret=1;
                break
            end
        end
end
end

function sumDist = calc_group_dist(G,TR,S1,S2)
sumDist=0;
S1_size=size(S1,1);
for i=1:S1_size
    myPos=S1(i,1);
    myPosx=TR(myPos,1);
    myPosy=TR(myPos,2);
    distlist=[];
    for j=1:size(S2,1)
        oppPos=S2(j,1);
        oppPosx=TR(oppPos,1);
        oppPosy=TR(oppPos,2);
        dist=sqrt((myPosx-oppPosx)^2+(myPosy-oppPosy)^2);
        %sumDist=sumDist+dist;
        distlist(j)=dist;
    end
    mindist=min(distlist);
    sumDist=sumDist+mindist;
end
sumDist=sumDist/S1_size;
end