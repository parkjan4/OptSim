
function arrivalinfo = HomogeneousPoissonProcess(T, arrival)

% ============================================================================
% DESCRIPTION
%
% usage: times = HomogeneousPoissonProcess(lambda, duration)
%
% Generates a row vector of event times for a homogenous Poisson process
% with rate lambda and given duration.
%
% ----------------------------------------------------------------------------
% PARAMETERS
%
% lambda    the rate of the Poisson process
% T         the duration of the Poisson process
%
% ---------------------------------------------------------------------------
% RETURN VALUES
%
% arrivalinfo(:,1) = times     a row vector of event times
% arrivalinfo(:,2) = group size
%
% ============================================================================

% Step 1: initialize t, k
t = T-1;
arrivalinfo = [];

% Obtain arrival rate
rate = lambda(arrival, t);

% Step 2: Simulate until t > T
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
    arrivalinfo = [arrivalinfo; t, group_size];
end



end
