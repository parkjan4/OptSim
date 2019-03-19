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

rate = sum(arrival(:,ceil(time)));

end