function rate = lambda(arrival, time)
% ============================================================================
% DESCRIPTION
% 
% usage: rate = lambda(arrival, time)
%
% Generates the customer arrival rate which depends on "time"
%
% ----------------------------------------------------------------------------
% PARAMETERS
%
% arrival   5 x 3 matrix of customer arrival rates
%
% time      Starting index of the current time block i.e. t = {0, 1 ,2}
%
% ---------------------------------------------------------------------------
% RETURN VALUES
%
% rate      Average customer arrival rate (groups/hour by default)
% ============================================================================

if time < 1
    rate = sum(arrival(:,1));
elseif time < 2
    rate = sum(arrival(:,2));
elseif time < 3
    rate = sum(arrival(:,3));
else
    rate = 0;
end

end