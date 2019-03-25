
function [time_arrival, group_size] = CustomerArrival(t, arrival)

% ============================================================================
% DESCRIPTION
%
% usage: [time_arrival, group_size] = CustomerArrival(t, arrival)
%
% One sampling of homogeneous Poisson process for customer arrival time
%
% ----------------------------------------------------------------------------
% PARAMETERS
%
% t                 Current time
%
% arrival           5 x 3 matrix of customer arrival rates
%
% ---------------------------------------------------------------------------
% RETURN VALUES
%
% time_arrival      Current time + randomly sampled time
% 
% group_size        Group size of the next customer
%
% ============================================================================

k=0;
while k==false
    % Define arrival rate
    rate = sum(arrival(:,floor(t)+1));

    % Generate inter-arrival time
    r = rand();
    time_arrival = t - log(1-r)/rate;
    if floor(time_arrival)==floor(t)
        k=true;
    else
        t=floor(t)+1;
        % Verify whether there will be new arrivals.
        if t==size(arrival,2)
            k=true;
            time_arrival=Inf;
            group_size=0;
            return
        end
    end
end

% Determine group size (Inverse Transform Method)
s = rand(); k=0; i=1;
while k==0
    if s < sum(arrival(1:i,floor(t)+1))/rate
        k = 1;
        group_size = i;
    end
    i = i + 1;
end

end
