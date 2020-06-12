function [G,TR,N,M] = platform_template();

N=17; %platform magasság
M=17; %platform szélesség

Xinterval=[0;700];
Yinterval=[0;700];

[G,TR]=genplatform(N,M,Xinterval, Yinterval);

%0 - szabad mezõ
%-1 - akadály
%-2 - central point

		%1    2    3    4    5    6    7    8    9    10   11   12   13   14   15
TYPE = [ -1   0    0    0    0    0    0    0    0    0    -1   0    -1   0    -1 ;
		 0    0    0    0    0    0    0   0    0    0    0    0    0    0    0 ;
 		 0    -1   0    -1   0    0    0    0    0    0    -1   0    0    -1   0 ;
		 0 	  0    0    0    0    0    0    0    0    0    0    0    0    0    0 ;
		 -1   0    0    0    0    -1   0    0    -1   -1   0    0    0    0    -1;
		 0    0    0    0    0    0    0    -1   0    0    0    0    0    0    0 ;
		 0    0    0    0    0    0    0    0    -1   -1   -1   0    -1   0    0 ;
		 0    0    0    -1   0    0    0    0    0    0    0    0    0    0    0 ;
		 0    -1   0    0  	 0    0    0    -1   0    0    0    0    0    0    -1;
		 0    0    0    0 	 0    0    0    0    0    0    0    0    0    0    0 ;
		 -1   0    0    0  	 0    -1   0    -1   0    0    0    -1   0    -1   0 ;
		 0    0    0    -1   0    0    0    0    0    0    0    0    0    0    0 ;
		 0    0    0    0    0    0    0    0    0    0   0    0    0    0    0 ;
		 0    0    0    0    0    0    0    0    0    0    0    0    0    -1   0 ;
		 -1   0    0    0    0    0    0   -1    0    0    0    0   0    0    -1] ;

%a sarkokban lehetõleg legyen egy egy akadály, mert különben a plot változtatja a tartományt
TYPE = enclose_with_obstacles(TYPE);

for i=1 : N
	for j=1 : M
		TR((i-1)*N+j,3)=TYPE(i,j);
	end
end


return;