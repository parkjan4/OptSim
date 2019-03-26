
function MSE = BootstrapMSE(data, statistic, parameter, draws)

% ============================================================================
% DESCRIPTION
%
% usage: mse = BootstrapMSE(data, statistic, parameter, draws)
%
% Calculates the bootstrap mean square error "mse" for the function handle
% "statistic" applied to the data "data", using "draws" bootstrap draws.
%
% Example: If you want to estimate the Bootstrap MSE for the mean of a data
% set "data" with 100 bootstrap draws, call this: Bootstrap(data, @mean, 100)
% ----------------------------------------------------------------------------
% PARAMETERS
%
% data       a row vector of the data
% statistic  a function handle for the statistic to be evaluated; if this
%            statistic is implemented as a function f then you need to
%            -- pass @f as the statistic parameter
%            -- implement f such that f(data) yields the desired statistic
%            Help: use the function feval() to evaluate a function handle
% parameter  the empirical value of statistic
% draws      the number of bootstrap draws; a recommended value is 100
%
% ----------------------------------------------------------------------------
% RETURN VALUES
%
% MSE        the bootstrap mean square error of the given statistic over the
%            given data
% ============================================================================

for i=1:draws
    % Uniformaly sample from data with replacement (same length)
    sub_sample = randsample(data,length(data),true);
    
    % Collect statistics
    stats(i) = feval(statistic, sub_sample);
    
    % MSE of one instance of bootstrapping
    Mr(i) = (parameter - stats(i))^2; 
end

MSE = mean(Mr);

end
