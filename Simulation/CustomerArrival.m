
function [time_arrival, group_size] = CustomerArrival(t, arrival)

% ============================================================================
% DESCRIPTION
%
% usage: [time_arrival, group_size = CustomerArrival(t, arrival)
%
% One sampling of homogeneous Poisson process for customer arrival time
%
% ----------------------------------------------------------------------------
% PARAMETERS
%
% t         Current time
%
% arrival   5 x 3 matrix of customer arrival rates
%
% ---------------------------------------------------------------------------
% RETURN VALUES
%
% time_arrival
% group_size
%
% ============================================================================

% Define arrival rate
rate = lambda(arrival, t);

% Generate inter-arrival time
r = rand();
time_arrival = t - log(1-r)/rate;

% Determine group size (Inverse Transform Method)
s = rand(); k=0; i=1;
while k==0
    if s < sum(arrival(1:i,ceil(t)))/rate
        k = 1;
        group_size = i;
    end
    i = i + 1;
end

end
