
function scenario = NewDay()

% ============================================================================
% DESCRIPTION
%
% usage: scenario = NewDay()
%
% Builds a single day scenario
%
% ----------------------------------------------------------------------------
% RETURN VALUES
%
% scenario
% .arrival          5 x 3 matrix that contains arrival rates 
% .dmin             Minimum dinner duration
% .dmax             Maximum dinner duration
% .dmean            Mean dinner duration
% .consum_min       Minimum consumption rate
% .consum_max       Maximum consumption rate
% .Tmax             Business closing time
% .arrangement      5 x 1 matrix that contains number of tables for each type
% .seating          Seating policy
%
% ============================================================================


scenario.arrival = [1, 8 ,3;
                    2, 14, 20;
                    3, 11, 15;
                    4, 9, 13;
                    5, 7 ,14];
scenario.dmin = 2/3;            % 40 minutes in hours
scenario.dmax = 2;              % 2 hours
scenario.dmean = 1/3;           % 20 minutes in hours
scenario.consum_min = 0.5;      % in EUR/minute
scenario.consum_max = 1.2;      % in EUR/minute
scenario.Tmax = 3;
scenario.arrangement = [0;0;0;0;40];
scenario.seating = 1;

end
