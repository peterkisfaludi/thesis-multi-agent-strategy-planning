function [RET] = iselement (AR,item);

	RET =0;
	
	for i=1 : size(AR,2)
		if(AR(i)==item)
			RET=1;
			break;
		else
		end
	end

return