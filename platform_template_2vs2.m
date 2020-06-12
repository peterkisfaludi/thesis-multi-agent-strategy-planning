function [G,TR,N,M] = platform_template_2vs2()

N=6  +2; %platform magasság
M=6  +2; %platform szélesség

Xinterval=[0;500];
Yinterval=[0;500];

[G,TR]=genplatform(N,M,Xinterval, Yinterval);

%0 - szabad mezõ
%-1 - akadály
%-2 - neutral control point
%-3 - control point owned by team1
%-4 - control point owned by team2

TYPE = [0 0 0 0 0 0;
        0 0 0 0 0 0;
        0 0 -2 -2 0 0;
        0 0 -2 -2 0 0;
        0 0 0 0 0 0;
        0 0 0 0 0 0];

TYPE = enclose_with_obstacles(TYPE);
    
for i=1 : N
	for j=1 : M
		TR((i-1)*N+j,3)=TYPE(i,j);
	end
end


return;