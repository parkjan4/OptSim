%% Set the Scenario
scenario = NewDay();
Draws = 1;
        
%% Customer Arrival Process & Visualization
allArrivals.times = [];
allArrivals.groupsize = [];
for count = 1:Draws   % For all draws
    arrivalinfo.times = []; 
    arrivalinfo.groupsize = [];
    for T = 1:3       % For each draw
        process = HomogeneousPoissonProcess(T, scenario.arrival);
        arrivalinfo.times = [arrivalinfo.times, process.times];
        arrivalinfo.groupsize = [arrivalinfo.groupsize, process.groupsize];
    end
    allArrivals.times = [allArrivals.times, arrivalinfo.times];
    allArrivals.groupsize = [allArrivals.groupsize, arrivalinfo.groupsize];
end

close all;

% Arrival times
figure; histogram(allArrivals.times, 'BinWidth', 0.1, 'FaceAlpha', 0.3, 'Facecolor', 'k');
xlabel('Arrival time inside the Poisson process period');
ylabel('Frequency [-] number of arrivals');

% Group sizes
figure; histogram(allArrivals.groupsize, 'BinWidth', 0.1, 'FaceAlpha', 0.3, 'Facecolor', 'k'); 
xlabel('Groups size inside the Poisson process period');
ylabel('Frequency [-] number of arrivals');

%% Dinner Duration & Visualization
durations = [];
for count = 1:Draws
    r = rand();
    d = min(scenario.dmax, scenario.dmin - log(1 - r)*scenario.dmean);
    durations = [durations, d];
end
figure; histogram(durations, 'BinWidth', 0.1, 'FaceAlpha', 0.3, 'Facecolor', 'k');
xlabel('Dinner duration times');
ylabel('Frequency');
