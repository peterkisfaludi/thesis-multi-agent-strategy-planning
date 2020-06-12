%player1 and player 2 are function handles to players' tactics
%parameter list : Adjacency matrix : LxL (NxMxNxM), Nodelist with types : Lx3, Position-Orientation-Healtpoint 2x Kx3 matrix)
%returns: N1/N2x1 size action-matrix
function [] = simulator(player1,player2)

%platform init

%[G,TR,N,M]=platform_template();
%[G,TR,N,M]=platform_template_small();
%[G,TR,N,M]=platform_template_1vs1();
%[G,TR,N,M]=platform_template_2vs2();
global G TR N M
[G,TR,N,M]=platform_template_6x6();
%tank init
%Si = 
%[nodeindex_1(position_1) orientation_1 health_1]
%                        ...
%[nodeindex_N(position_N) orientation_N health_N]

global S1 S2

global P1_score P2_score
P1_score = 0;
P2_score = 0;
score_limit = 100;
pause_interval = 0.00000000000001;
global SILENTMODE

S=vertcat(S1,S2);
LIMIT=size(S,1);

p1state = [];
p2state = [];
DeathList=[];
ShootList=[];

%add tanks to TR
for i=1 : size(S)
	TR(S(i,1),3)=i;
end	  

%load graphics
Tank_1 = imread('tank_1.jpg');
Tank_2 = imread('tank_2.jpg');
Tank_1_a = imread('tank_1_1_elet.jpg');
Tank_2_a = imread('tank_2_1_elet.jpg');
Stop = imread('forbidden.png');

%Main loop
dl_counter=1;

%game over? 0=false 1=true
VEGE=0;

global WINNER MAXLEPES
WINNER = [];
LEPES=1;

while (VEGE==0)
    
S1_size=size(S1,1);
S2_size=size(S2,1);

%%------------------------
%Drawing

if(isempty(SILENTMODE)==true || SILENTMODE~= true)
    gplot(G,TR,'-rs');

    for b=1 : size(TR,1)
        hold on
        plot([-100,600],[-100,600],'wx');
        for shh = 1:size(ShootList,1)
            plot(ShootList(shh,1:2),ShootList(shh,3:4),char(ShootList(shh,5)),'LineWidth',3);
        end
        if(TR(b,3)==-1)
            %plot(TR(b,1), TR(b,2),'--rs','MarkerEdgeColor','k','MarkerFaceColor','black','MarkerSize',15)
            image(TR(b,1)-10,TR(b,2)-10,Stop);
        end
        %control point
        %neutral
        if(TR(b,3)==-2)
            plot(TR(b,1), TR(b,2),'--rs','MarkerEdgeColor','k','MarkerFaceColor','black','MarkerSize',15)
        %team1
        elseif(TR(b,3)==-3)
            plot(TR(b,1), TR(b,2),'--rs','MarkerEdgeColor','k','MarkerFaceColor','white','MarkerSize',15)
        %team2
        elseif(TR(b,3)==-4)
            plot(TR(b,1), TR(b,2),'--rs','MarkerEdgeColor','k','MarkerFaceColor','green','MarkerSize',15)
        end
        if(TR(b,3)>0)

            if(TR(b,3)<=S1_size)
                if(S1(TR(b,3),3)==1)
                    %plot(TR(b,1), TR(b,2),'--s','MarkerEdgeColor','k','MarkerFaceColor','red','MarkerSize',10)
                    Tank_2_tempa=imrotate(Tank_2_a,180-S1(TR(b,3),2));
                    image(TR(b,1)-10,TR(b,2)-10,Tank_2_tempa);
                    hf=text(TR(b,1)+15, TR(b,2)+15,[int2str(TR(b,3))]);
                end
                if(S1(TR(b,3),3)>=2)
                    %plot(TR(b,1), TR(b,2),'--s','MarkerEdgeColor','k','MarkerFaceColor','blue','MarkerSize',10)
                    Tank_2_temp=imrotate(Tank_2,180-S1(TR(b,3),2));
                    image(TR(b,1)-10,TR(b,2)-10,Tank_2_temp);
                    hf=text(TR(b,1)+15, TR(b,2)+15,[int2str(TR(b,3))]);
                end
            end
            if(TR(b,3)>S1_size && TR(b,3)<=S2_size+S1_size)

                if(S2(TR(b,3)-S1_size,3)==1)
                    %plot(TR(b,1), TR(b,2),'--s','MarkerEdgeColor','k','MarkerFaceColor','red','MarkerSize',10)
                    Tank_1_tempa=imrotate(Tank_1_a,270-S2(TR(b,3)-S1_size,2));
                    image(TR(b,1)-10,TR(b,2)-10,Tank_1_tempa);
                    hf=text(TR(b,1)+15, TR(b,2)+15,[int2str(TR(b,3)-S1_size)]);
                end
                if(S2(TR(b,3)-S1_size,3)>=2)
                    %plot(TR(b,1), TR(b,2),'--s','MarkerEdgeColor','k','MarkerFaceColor','green','MarkerSize',10)
                    Tank_1_temp=imrotate(Tank_1,270-S2(TR(b,3)-S1_size,2));
                    image(TR(b,1)-10,TR(b,2)-10,Tank_1_temp);
                    hf=text(TR(b,1)+15, TR(b,2)+15,[int2str(TR(b,3)-S1_size)]);
                end
            end
        end
        hold off
    end
    pause(pause_interval)
end
%%------------------------

ShootList=[];
sl_counter = 1;
Stry = zeros(size(S,1),3);

[V1,p1state]=player1(G,TR,S1,S2,N,M,1,p1state);
[V2,p2state]=player2(G,TR,S1,S2,N,M,2,p2state);

%Left  - 0
%Right - 1
%Forward  - 2
%Shoot  - 3
%Halt 	- 4 

V=vertcat(V1,V2);

%Handle actions
for i=1:LIMIT
    if(iselement(DeathList,i)==1)
		%if tank is in deathlist, it cannot do actions
    else
        Stry(i,:)=[S(i,1) S(i,1) i];
		%0 - turn left
		if(V(i,1)==0)			
            S(i,2)=mod(S(i,2)+90,360);
		end	
		%1 - turn right
		if(V(i,1)==1)
            S(i,2)=mod(S(i,2)-90,360);			
		end
		%2 - try to move forward
        if(V(i,1)==2)
            pos = S(i,1);
            ori = S(i,2);
            %move direction is determined by orientation
            if(ori==0)
                nchk = pos+1;
            elseif(ori==180)
                nchk = pos-1;
            elseif(ori==90)
                nchk = pos+M;
            elseif(ori==270)
                nchk = pos-M;
            end
            %trying to move
            if(TR(nchk,3)>=0)
                Stry(i,:)=[pos nchk i];
            end
        end
        		
        %3 - shoot        
		if(V(i,1)==3)
            
            %get (x,y) coordinates
            pos = TR(S(i,1),1:2);
            posx = pos(1);
            posy = pos(2);
            %get orientation
            ori = S(i,2);
            %add starting coordinates and color of shooting to shootlist
            ShootList(sl_counter,1)=posx;
            ShootList(sl_counter,3)=posy;
            if(i<=S1_size)
                ShootList(sl_counter,5) = 'k';
            else
                ShootList(sl_counter,5) = 'g';
            end
                
            %calculate shoot angle
            phi = calculate_shoot_angle(ori);
            
            %calculate sampling frequency
            mina=(TR(2,1)-TR(1,1))*0.5;
            maxdiam=sqrt(2)*(TR(end,1)-TR(1,1));
            
            for svlen = mina:mina:maxdiam
                %(x,y) coordinates to check
                xchk = posx + svlen*cos(phi);
                ychk = posy + svlen*sin(phi);
                %convert (x,y) to node index
                dist = sqrt(sum((TR(:,1:2)-repmat([xchk ychk],size(TR(:,1:2),1),1)).^2,2));
                [minp indp] = min(dist);
                %the node to check
                nchk =TR(indp,:);                
                
                %someone has been shot
                if(nchk(3)>0  && i~=nchk(3))
                    %PLAYER1 has shot, cannot shoot itself
                    if(i<=S1_size)
                        if(nchk(3)<=S1_size)
                            routed_display(['#' int2str(LEPES) '#  PLAYER1''s  ' int2str(i) '. tank has shot PLAYER1''s  ' int2str(nchk(3)) '. tank']);
                        else
                            routed_display(['#' int2str(LEPES) '#  PLAYER1''s  ' int2str(i) '. tank has shot PLAYER2''s  ' int2str(nchk(3)-S1_size) '. tank']);
                        end
                    %PLAYER2 has shot, cannot shoot itself
                    else
                        if(nchk(3)<=S1_size)
                            routed_display(['#' int2str(LEPES) '#  PLAYER2''s  ' int2str(i-S1_size) '. tank has shot PLAYER1''s  ' int2str(nchk(3)) '. tank']);
                        else
                            routed_display(['#' int2str(LEPES) '#  PLAYER2''s  ' int2str(i-S1_size) '. tank has shot PLAYER2''s  ' int2str(nchk(3)-S1_size) '. tank']);
                        end
                    end                    

                    S(nchk(3),3)=S(nchk(3),3)-1; %decrease health
                    if(S(nchk(3),3)==0) %if the shot tank lost all of its health
                        DeathList(dl_counter)=nchk(3); %add to DeathList
                        dl_counter=dl_counter+1;
                        if(nchk(3)<=S1_size)
                            routed_display(['#' int2str(LEPES) '#  PLAYER1''s  '  int2str(nchk(3)) '. tank was blown up']);
                        else
                            routed_display(['#' int2str(LEPES) '#  PLAYER2''s  '  int2str(nchk(3)-S1_size) '. tank was blown up']);
                        end									
                        TR(indp,3)=0; %field is marked free (tank was blown up)
                    end
                    %the bullet is blocked by the tank it has shot
                    ShootList(sl_counter,2) = nchk(1);
                    ShootList(sl_counter,4) = nchk(2);
                    sl_counter = sl_counter+1;
                    break;
                end
                %the bullet is blocked by an obstacle
                if(nchk(3)==-1)
                    ShootList(sl_counter,2) = nchk(1);
                    ShootList(sl_counter,4) = nchk(2);
                    sl_counter = sl_counter+1;
                    break;
                end
            end            
            
		end
		%4 - halt -> do nothing
    end
end

%resolve possibly conflicting actions
%two tanks trying to swap tiles: forbidden
for b = 1:size(Stry,1)
    row = Stry(b,:);
    if(row(1)==row(2))
       continue;
   end
    conf = Stry(:,1:2)==repmat([row(:,2) row(:,1)],size(Stry,1),1);
    confloc = find(conf(:,1) & conf(:,2));
    if(isempty(confloc)==false)
        %resolve conflict -> every tank halts
        Stry(b,2) = Stry(b,1);
        Stry(confloc,2) = Stry(confloc,1);
    end
end
%one tank trying to go to a static tank's location
b=1;
while (b<=size(Stry,1))
   row = Stry(b,:);
   if(iselement(DeathList,b)==1)
       b = b+1;
       continue;
   end
   if(row(1)==row(2))
       b = b+1;
       continue;
   end
   %check if the tank is static
%    if(row(1)==row(2))
%        confloc = find(row(2)==Stry(:,2));
%        if(length(confloc)>=2)
%            %the other tanks halt
%            Stry(confloc,2)=Stry(confloc,1);
%            b=0;
%            %continue;
%        end       
%    end
   confloc = find(row(2)==Stry(:,2));
   %more than one tanks trying to go to the same location
   if(length(confloc)>=2)
       %check if there is a static tank in the conflicting location
       statloc = find(Stry(:,1)==row(2) & Stry(:,2)==row(2));
       %the conflicting location is empty
       if(isempty(statloc))
           %choose one tank to move (random), the other tanks halt
           chosenind = round(rand*(length(confloc)-1))+1;
           chosendest = Stry(confloc(chosenind),2);
           Stry(confloc,2)=Stry(confloc,1);
           Stry(confloc(chosenind),2)=chosendest;
       else
           %the moving tank halts
           Stry(b,2) = Stry(b,1);           
       end
       b=0;       
   end
   b=b+1;
end
%remove tanks from previous location and move tanks to desired locations
for b=1:size(S,1)
    if(iselement(DeathList,b)==1)
        continue;
    end
    TR(S(b,1),3)=0;
    S(b,1)=Stry(b,2);    
end
for b=1:size(S,1)
    if(iselement(DeathList,b)==1)
        continue;
    end
    TR(S(b,1),3)=b;
end
    

%set control point owner
%\author KP
for b = 1:size(TR,1)
    tip = TR(b,3);
    if(tip <= -2)
        %get adjacent tiles
        rowb = G(b,:);
        neighpt = find(rowb);
        neigh = TR(neighpt,3);
        for n=1:length(neigh)
            if(neigh(n)>0)
                %a member of team1 is nearby
                if(neigh(n)<=S1_size)
                    if(tip==-2 || tip==-4)
                        TR(b,3)=-3;
                    end
                %a member of team2 is nearby
                else
                    if(tip==-2 || tip==-3)
                        TR(b,3)=-4;
                    end
                end
            end
        end
    end    
end

%update player scores
%\author KP
tip = TR(:,3);
P1_score = P1_score + length(find(tip==-3));
P2_score = P2_score + length(find(tip==-4));
routed_display(['#' int2str(LEPES) '#  PLAYER1 score  '  int2str(P1_score) ' #  PLAYER2 score  '  int2str(P2_score)]);

%reshape matrices
S1(:,:)=[];
S2(:,:)=[];

for b=1 : S1_size
	S1(b,:)=S(b,:);
end
for b=1: S2_size
	S2(b,:)=S(b+S1_size,:);
end

V(:,:)=[];

	PLAYER1_LOOSE=0;
	PLAYER2_LOOSE=0;
	
	szamlalo=0;
	for i=1 : S1_size
		if(S1(i,3)>0)
			szamlalo=szamlalo+1; %number of alive units
		end
	end
	if(szamlalo==0)
		PLAYER1_LOOSE=1;
	end

	S1_size=size(S1,1);
	S2_size=size(S2,1);
	
	szamlalo=0;
	for i=1 : S2_size
		if(S2(i,3)>0)
			szamlalo=szamlalo+1; %number of alive units
		end
	end
	if(szamlalo==0)
		PLAYER2_LOOSE=1;
    end
	
    %game over if score limit is reached
    if(P1_score>=score_limit)
        PLAYER2_LOOSE=1;
    end
    if(P2_score>=score_limit)
        PLAYER1_LOOSE=1;
    end
    
	if(PLAYER1_LOOSE==1 && PLAYER2_LOOSE==1)
		routed_display('Draw');
        WINNER = [];
		VEGE=1;
	else
		if(PLAYER1_LOOSE==1 && PLAYER2_LOOSE==0)
			routed_display('Player 2 is the winner');
            WINNER = 2;
			VEGE=1;
		else
			if(PLAYER1_LOOSE==0 && PLAYER2_LOOSE==1)
				routed_display('Player 1 is the winner');
                WINNER = 1;
				VEGE=1;
			end
		end
	end

	LEPES=LEPES+1;
    if(LEPES>MAXLEPES)
        WINNER=[];
        VEGE=1;
    end
end

return;
end

%------- functions ---------

%calculate shoot angle
%ori - the orientation of the shooting tank
%returns orientation of bullet
function phi = calculate_shoot_angle(ori)
    %convert to radians
    ori = ori*pi/180;
    spread = pi/6;
    delta_phi = spread*rand-spread/2;
    phi = ori + delta_phi;
end

%display message
%str - the string to display
%prints message to console or message box in GUI, depending on running
%environment
function [] = routed_display(str)
    global LOGGERHANDLE SILENTMODE
    if(SILENTMODE==true)
        return;
    end
    if(isempty(LOGGERHANDLE)==0)
        try        
            newline = sprintf('\n');
            str_old = get(LOGGERHANDLE,'String');
            str_old = [str_old,repmat(newline,size(str_old,1),1)];
            str_old = reshape(str_old',1,numel(str_old));
            set(LOGGERHANDLE,'String',[str,newline,strcat(str_old)]);
        catch        
            disp(str);
        end
    else
        disp(str);        
    end
end
