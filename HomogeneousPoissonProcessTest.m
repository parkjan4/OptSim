%% Test HomogeneousPoissonProcess.m function

%% clean the workspace
clear all; %Removes all variables, functions, and MEX-files from memory, leaving the workspace empty
close all; % delete all figures whose handles are not hidden
clc; % clear command window

%% Input
lambda   = 3;           % [-] Poisson process rate
T = 1;                  % [-] Poisson process duration
DrawsNumber   = 1000;   % [-] Number of Poisson process to be drawn

%% Program
allArrivals = [];   % [-] (vector) Initialize the vector containing all arrival times for all drawn Poisson process

for count = 1:DrawsNumber   % For all drawn Poisson process
	arrivals    = HomogeneousPoissonProcess(lambda, T); % return all the arrival times in this process
	allArrivals = [allArrivals, arrivals]; % Store all the arrival times of all processes
end

histogram(allArrivals, 'BinWidth', 0.1, 'FaceAlpha', 0.3, 'Facecolor', 'k'); % Plot the histogram of the arrival time
xlabel('Arrival time inside the Poisson process period');
ylabel('Frequency [-] number of arrivals');
