%platformgráf

function[G,TR] = genplatform(N,M,Xinterval,Yinterval)



EPSI=0.000001;

diffx=abs(Xinterval(2,1)-Xinterval(1,1))/(N-1);
diffy=abs(Yinterval(2,1)-Yinterval(1,1))/(M-1);

for i=1 : N
	for j=1 : M
		TR((i-1)*N+j,1)=Xinterval(1,1)+(j-1)*diffx;
		TR((i-1)*N+j,2)=Yinterval(1,1)+(i-1)*diffy;
	end
end

for i=1 : (N)*(M)
	for j=1 : (N)*(M)
		if(i==j)
			G(i,j)=0;
		else		
			if((TR(i,2)==TR(j,2) && abs((TR(i,1)-TR(j,1))) > diffx-EPSI && abs((TR(i,1)-TR(j,1)))<diffx+EPSI) || (TR(i,1)==TR(j,1) && abs((TR(i,2)-TR(j,2))) > diffy-EPSI && abs((TR(i,2)-TR(j,2)))<diffy+EPSI))
					G(i,j)=1;
			else
				G(i,j)=0;
			end
		end
	end
end

for i=1 : N
	for j=1 : M
	k=0;
		while(k<0.8)
			k=rand(1);
			k=1;
		end
		TR((i-1)*N+j,1)=TR((i-1)*N+j,1)*k;
		TR((i-1)*N+j,2)=TR((i-1)*N+j,2)*k;
		
	end
end

for i=1 : N*M
	for j=1 : N*M
		if(G(i,j)>0)
			G(i,j)=sqrt((TR(i,1)-TR(j,1))^2 + (TR(i,2)-TR(j,2))^2);
		end
	end
end

%gplot(G,TR,'--rs')

%for i=1 : N*M
%	hold on
%	plot(TR(i,1), TR(i,2))
%	hold off
%	ht = text(TR(i,1), TR(i,2),[int2str(i)]);
%end


%plot(G,'--rs','LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',10)


return