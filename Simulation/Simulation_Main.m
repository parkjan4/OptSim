%% Test the implementation of DiscreteEventSimulation.m function

%% clean the workspace
clear all; %Removes all variables, functions, and MEX-files from memory, leaving the workspace empty
close all; % delete all figures whose handles are not hidden.
clc; % clear command window

%% Program
% Set the scenario
scenario = NewDay();

% Run the simulation
[customers, tables, times, queues] = DiscreteEventSimulation(scenario);

%% Compute indicators
% Abandonment/Arrival ratio
num_admitted = sum([customers.time_seated] ~= inf);
num_abandon = sum([customers.time_seated] == inf);
admit_abandon_ratio = num_admitted / num_abandon;

% Profit
revenue = sum([customers.revenue]);
cost = 0.10 * times(end) * 60 * ([1 2 3 4 5]*scenario.arrangement); % cost = 0.10 * closing time in minutes * total number of seats
profit = revenue - cost;

% Waiting times (vector)
waiting_times = [customers.time_seated] - [customers.time_arrival];

%% Visualization
% Graphical animation of the results
DrawNetwork(scenario, times, queues);

% Chart of the results
figure;DrawQueues(times, queues);
