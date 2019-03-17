%% PART I: SIMULATION
%% Define data parameters
% Customer arrival table
arrival = [1, 8 ,3;
            2, 14, 20;
            3, 11, 15;
            4, 9, 13;
            5, 7 ,14];
        
%% Customer Arrival Process
Draws = 1000;
allArrivals.times = [];
allArrivals.groupsize = [];
for count = 1:Draws   % For all draws
    arrivalinfo.times = []; 
    arrivalinfo.groupsize = [];
    for T = 1:3       % For each draw
        process = HomogeneousPoissonProcess(T, arrival);
        arrivalinfo.times = [arrivalinfo.times, process.times];
        arrivalinfo.groupsize = [arrivalinfo.groupsize, process.groupsize];
    end
    allArrivals.times = [allArrivals.times, arrivalinfo.times];
    allArrivals.groupsize = [allArrivals.groupsize, arrivalinfo.groupsize];
end

%% Customer Arrival Visualization
close all;

% Arrival times
figure; histogram(allArrivals.times, 'BinWidth', 0.1, 'FaceAlpha', 0.3, 'Facecolor', 'k');
xlabel('Arrival time inside the Poisson process period');
ylabel('Frequency [-] number of arrivals');

% Group sizes
figure; histogram(allArrivals.groupsize, 'BinWidth', 0.1, 'FaceAlpha', 0.3, 'Facecolor', 'k'); 
xlabel('Groups size inside the Poisson process period');
ylabel('Frequency [-] number of arrivals');