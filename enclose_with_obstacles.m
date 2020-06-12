%this function places obstacles around the map
%returns a new TYPE matrix
function [TN] = enclose_with_obstacles(TYPE)
    obstc = -1*ones(size(TYPE)+2);
    obstc(2:end-1,2:end-1)=TYPE;
    TN = obstc;
end