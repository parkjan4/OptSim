function [newAverage, newVariance] = UpdatedStatistics(oldAverage, oldVariance, newData, iteration)
% ============================================================================
% DESCRIPTION
%
% usage: [newAverage, newVariance] = UpdatedStatistics(oldAverage, ...
%                                            oldVariance, newData, iteration)
%
% Recursively updates "oldAverages" and "oldVariances" based on the data
% "newData", which arrived in iteration "iteration".
%
% ----------------------------------------------------------------------------
% PARAMETERS
%
% oldAverage    the previously calculated average, must be initially zero
% oldVariance   the previously calculated variance, must be initially zero
% newData       a newly sampled random number
% iteration     the iteration in which "newData" arrived, where the i-th data
%               item arrives in iteration i
%
% ---------------------------------------------------------------------------
% RETURN VALUES
%
% newAverage    the updated average including the new data
% newVariance   the updated variance including the new data
% ============================================================================

newAverage = oldAverage + (newData - oldAverage) / (iteration+1);
newVariance = (1-1/iteration)*oldVariance + (iteration+1)*(newAverage-oldAverage)^2;

end
