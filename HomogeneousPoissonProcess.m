
function arrivalinfo = HomogeneousPoissonProcess(T, arrival)

% ============================================================================
% DESCRIPTION
%
% usage: times = HomogeneousPoissonProcess(T, arrival)
%
% Homogeneous Poisson process for customer arrival times.
%
% ----------------------------------------------------------------------------
% PARAMETERS
%
% T         Index for the current time block i.e. T = {1, 2, 3}
%
% arrival   5 x 3 matrix of customer arrival rates
%
% ---------------------------------------------------------------------------
% RETURN VALUES
%
% arrivalinfo.times          a vector of event times
% arrivalinfo.groupsize      a vector of corresponding group size
%
% ============================================================================

% Step 1: initialize t and output matrix
t = T-1;
arrivalinfo.times = [];
arrivalinfo.groupsize = [];

% Step 2: obtain the right arrival rate based on current time block
rate = lambda(arrival, t);

% Step 3: simulate arrival times until t > T
while t <= T
    % Generate inter-arrival time
    r = rand();
    t = t - log(1-r)/rate;
    
    % Determine group size (Inverse Transform Method)
    s = rand(); k=0; i=1;
    while k==0
        if s < sum(arrival(1:i,T))/rate
            k = 1;
            group_size = i;
        end
        i = i + 1;
    end
    
    if t > T 
        break
    end
    
    arrivalinfo.times = [arrivalinfo.times, t];
    arrivalinfo.groupsize = [arrivalinfo.groupsize, group_size];
end



end
