clear all
close all
clc

%% Optimization by Golden Section Method (minimize negative mean profit)

% Initialization
scenario = NewDay([]);
ak = 200;                       % min. number of seats
bk = 400;                       % max. number of seats
alpha = 0.618;                  % Fibonacci convergence
lk = ak + (1 - alpha)*(bk - ak);% lambda_k
mk = ak + alpha*(bk - ak);      % mu_k
l = 5;                         % "tolerance" between bk and ak
thresh = 20;                    % "threshold" for switching from Greedy to another method

%% Greedy Search Method
problem.lk_SOLUTION = GreedySeats(lk, scenario);  % candidate arrangement
problem.mk_SOLUTION = GreedySeats(mk, scenario);
theta_lk = -Run_Simulation(problem.lk_SOLUTION);  % negative profit
theta_mk = -Run_Simulation(problem.mk_SOLUTION);  

% Used to collect number of seats investigated
ak_all = [];
bk_all = [];
lk_all = [];
mk_all = [];

tic                                 % start time
while bk - ak >= thresh
    if theta_lk > theta_mk          % i.e. If profit with mk is higher
        ak = lk;
        lk = mk;
        mk = ak + alpha*(bk - ak);
        
        % Update lk, mk solutions
        theta_lk = theta_mk;
        problem.lk_SOLUTION = problem.mk_SOLUTION;
        problem.mk_SOLUTION = GreedySeats(mk, scenario);
        theta_mk = -Run_Simulation(problem.mk_SOLUTION);
        
    else                            % i.e. If profit with lk is higher
        bk = mk;
        mk = lk;
        lk = ak + (1 - alpha)*(bk - ak);
        
        % Update lk, mk solutions
        theta_mk = theta_lk;
        problem.mk_SOLUTION = problem.lk_SOLUTION;
        problem.lk_SOLUTION = GreedySeats(lk, scenario);
        theta_lk = -Run_Simulation(problem.lk_SOLUTION);
    end
    
    % Store progress
    ak_all = [ak_all, ak];
    bk_all = [bk_all, bk];
    lk_all = [lk_all, lk];
    mk_all = [mk_all, mk];
    
end
toc                                    % end time
opt_ak_gm = GreedySeats(ak, scenario);
opt_bk_gm = GreedySeats(bk, scenario);
fprintf('The optimal number of seats lies in interval: [%d %d]\n', ak, bk);
fprintf('The optimal profit lies is about: %d\n', (-theta_lk + -theta_mk)/2);
disp(opt_ak_gm)
disp(opt_bk_gm)

%% Simulated Annealing Method (Hybrid with Greedy Method)

% Define parameters for simulated annealing (optimizing table arrangement)
problem.M = 20;                          % Number of temperature changes
problem.K = 10;                          % Number of iterations per level of temperature
problem.D = 100;                        % Average increase of the objective function
problem.P0 = 0.999;                     % Initial acceptance probability
problem.Pf = 0.00001;                   % Final acceptance probability
problem.RANDOMIZE1 = @table_neighbor1;     
problem.RANDOMIZE2 = @table_neighbor2; 
problem.OBJECTIVE_FUNCTION = @Run_Simulation;

counter = 1;
tic                                 % start time
while bk - ak >= l
    if theta_lk > theta_mk          % i.e. If profit with mk is higher
        ak = lk;
        lk = mk;
        mk = ak + alpha*(bk - ak);
        
        % Update lk, mk solutions
        theta_lk = theta_mk;
        problem.lk_SOLUTION = problem.mk_SOLUTION;
        [theta_mk, problem.mk_SOLUTION, values] = SimulatedAnnealing(problem, GreedySeats(mk, scenario));
        all_values.('run'+string(counter)) = values; counter = counter + 1;
        
    else                            % i.e. If profit with lk is higher
        bk = mk;
        mk = lk;
        lk = ak + (1 - alpha)*(bk - ak);
        
        % Update lk, mk solutions
        theta_mk = theta_lk;
        problem.mk_SOLUTION = problem.lk_SOLUTION;
        [theta_lk, problem.lk_SOLUTION, values] = SimulatedAnnealing(problem, GreedySeats(lk, scenario));
        all_values.('run'+string(counter)) = values; counter = counter + 1;
        
    end
    
    % Store progress (continuing from Greedy)
    ak_all = [ak_all, ak];
    bk_all = [bk_all, bk];
    lk_all = [lk_all, lk];
    mk_all = [mk_all, mk];
    
end
toc                                 % end time
%[optimal_profit_ak_sa, opt_ak_sa, values] = SimulatedAnnealing(problem, GreedySeats(ak, scenario));
%all_values.('run'+string(counter)) = values; counter = counter + 1;
%[optimal_profit_bk_sa, opt_bk_sa, values] = SimulatedAnnealing(problem, GreedySeats(bk, scenario));
%all_values.('run'+string(counter)) = values; counter = counter + 1;

fprintf('The optimal number of seats lies in interval: [%d %d]\n', ak, bk);
fprintf('The optimal profit is about: %d\n', (-theta_lk + -theta_mk)/2);
disp(ak_all)
disp(bk_all)
disp(problem.lk_SOLUTION)
disp(problem.mk_SOLUTION)

%% Plot objective values over iterations
% plot the values for each iteration
values = all_values.run1;
plot(values,'-ko');title('Objective function values over iterations');

% plot the best value
best_values = values(1);
for i=1:length(values)
    if(values(i)<best_values(end))
        best_values(i)=values(i);
    else
        best_values(i)=best_values(end);
    end
end
hold on;plot(best_values,'k:');
xlabel('Iteration');legend('iteration value','best value');