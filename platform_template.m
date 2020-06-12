function [G,TR,N,M] = platform_template();

N=17; %platform magass�g
M=17; %platform sz�less�g

Xinterval=[0;700];
Yinterval=[0;700];

[G,TR]=genplatform(N,M,Xinterval, Yinterval);

%0 - szabad mez�
%-1 - akad�ly
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

%a sarkokban lehet�leg legyen egy egy akad�ly, mert k�l�nben a plot v�ltoztatja a tartom�nyt
TYPE = enclose_with_obstacles(TYPE);

for i=1 : N
	for j=1 : M
		TR((i-1)*N+j,3)=TYPE(i,j);
	end
end


return;