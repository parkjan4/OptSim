function rate = lambda(arrival, time)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if time<1
    rate=sum(arrival(:,1));
elseif time<2
    rate=sum(arrival(:,2));
elseif time<3
    rate=sum(arrival(:,3));
else
    rate=0;
end

end