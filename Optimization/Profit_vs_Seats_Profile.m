%% Greedy solution
scenario = NewDay([]);
num_seats = [200, 225, 250, 300, 350, 400];

Gsolns = [];
Gobjs = [];
for n=1:length(num_seats)
    Gsoln = GreedySeats(num_seats(n),scenario);
    Gsolns = [Gsolns, Gsoln];
    Gobjs = [Gobjs, Run_Simulation(Gsoln)];
end

%% Simulated annealing solution
problem.M = 2;                          % Number of temperature changes
problem.K = 5;                          % Number of iterations per level of temperature
problem.D = 500;                        % Average increase of the objective function
problem.P0 = 0.999;                     % Initial acceptance probability
problem.Pf = 0.00001;                   % Final acceptance probability
problem.RANDOMIZE1 = @table_neighbor1;          
problem.RANDOMIZE2 = @table_neighbor2;          
problem.OBJECTIVE_FUNCTION = @Run_Simulation;

SAsolns = [];
SAobjs = [];
for n=1:length(num_seats)
    [SAobj, SAsoln] = SimulatedAnnealing(problem, GreedySeats(num_seats(n),scenario));
    SAsolns = [SAsolns, SAsoln];
    SAobjs = [SAobjs, SAobj];
end

%% Plot profile
plot(num_seats, Gobjs);
hold on;
plot(num_seats, -SAobjs);
title("Mean Profit vs. Number of Seats  ");
ylabel("Mean Profit");
xlabel("Number of Seats");
legend("Greedy Method","Simulated Annealing");