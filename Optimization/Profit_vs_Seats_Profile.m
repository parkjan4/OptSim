%% Greedy solution
scenario = NewDay([]);
num_seats = [200, 204, 208, 212, 216, 220, 225, 250, 300, 350, 400];

Gsolns = [];
Gobjs = [];
for n=1:length(num_seats)
    Gsoln = GreedySeats(num_seats(n),scenario);
    Gsolns = [Gsolns, Gsoln];
    Gobjs = [Gobjs, Run_Simulation(Gsoln)];
end

%% VNS solution
problem.RANDOMIZE1 = @table_neighborSM1;          
problem.RANDOMIZE2 = @table_neighborSM2;          
problem.OBJECTIVE_FUNCTION = @Run_Simulation;

%VNSsolns = [];
%VNSobjs = [];
num_seats = [208, 212, 216, 220, 225, 250, 300, 350, 400];
for n=1:length(num_seats)
    [SAsols, SAvals] = VNS(problem, GreedySeats(num_seats(n),scenario));
    VNSsolns = [VNSsolns, SAsols(:,end)];
    VNSobjs = [VNSobjs, SAvals(end)];
end

%% Plot profile
plot(num_seats, Gobjs);
hold on;
plot(num_seats, VNSobjs);
title("Mean Profit vs. Number of Seats");
ylabel("Mean Profit");
xlabel("Number of Seats");
legend("Greedy Method","VNS");