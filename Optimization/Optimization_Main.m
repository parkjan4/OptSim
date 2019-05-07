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
l = 20;                         % "tolerance" between bk and ak

%% Greedy Search Method
problem.lk_SOLUTION = GreedySeats(lk, scenario);  % candidate arrangement
problem.mk_SOLUTION = GreedySeats(mk, scenario);
theta_lk = -Run_Simulation(problem.lk_SOLUTION);  % negative profit
theta_mk = -Run_Simulation(problem.mk_SOLUTION);  

% Used to collect number of seats investigated
ak_all_gm = [];
bk_all_gm = [];
lk_all_gm = [];
mk_all_gm = [];

tic                                 % start time
while bk - ak >= l
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
    ak_all_gm = [ak_all_gm, ak];
    bk_all_gm = [bk_all_gm, bk];
    lk_all_gm = [lk_all_gm, lk];
    mk_all_gm = [mk_all_gm, mk];
    
end
toc                                    % end time
opt_ak_gm = GreedySeats(ak, scenario);
opt_bk_gm = GreedySeats(bk, scenario);
optimal_profit_ak_gm = Run_Simulation(opt_ak_gm);
optimal_profit_bk_gm = Run_Simulation(opt_bk_gm);
fprintf('The optimal number of seats lies in interval: [%d %d]\n', ak, bk);
fprintf('The optimal profit lies in interval: [%d %d]\n', optimal_profit_ak_gm, optimal_profit_bk_gm);

%% Simulated Annealing Method

% Define parameters for simulated annealing (optimizing table arrangement)
problem.M = 2;                        % Number of temperature changes
problem.K = 5;                         % Number of iterations per level of temperature
problem.D = 500;                        % Average increase of the objective function
problem.P0 = 0.999;                     % Initial acceptance probability
problem.Pf = 0.00001;                   % Final acceptance probability
problem.RANDOMIZE = @table_neighbor2;          
problem.OBJECTIVE_FUNCTION = @Run_Simulation;

% Returns 'optima' profit and table arrangement given lk, mk number of seats
[theta_lk, problem.lk_SOLUTION] = SimulatedAnnealing(problem, GreedySeats(lk, scenario));
[theta_mk, problem.mk_SOLUTION] = SimulatedAnnealing(problem, GreedySeats(mk, scenario));

% Used to collect number of seats investigated
ak_all_sa = [];
bk_all_sa = [];
lk_all_sa = [];
mk_all_sa = [];

tic                                 % start time
while bk - ak >= l
    if theta_lk > theta_mk          % i.e. If profit with mk is higher
        ak = lk;
        lk = mk;
        mk = ak + alpha*(bk - ak);
        
        % Update lk, mk solutions
        theta_lk = theta_mk;
        problem.lk_SOLUTION = problem.mk_SOLUTION;
        [theta_mk, problem.mk_SOLUTION] = SimulatedAnnealing(problem, GreedySeats(mk, scenario));
        
    else                            % i.e. If profit with lk is higher
        bk = mk;
        mk = lk;
        lk = ak + (1 - alpha)*(bk - ak);
        
        % Update lk, mk solutions
        theta_mk = theta_lk;
        problem.mk_SOLUTION = problem.lk_SOLUTION;
        [theta_lk, problem.lk_SOLUTION] = SimulatedAnnealing(problem, GreedySeats(lk, scenario));
    end
    
    % Store progress
    ak_all_sa = [ak_all_sa, ak];
    bk_all_sa = [bk_all_sa, bk];
    lk_all_sa = [lk_all_sa, lk];
    mk_all_sa = [mk_all_sa, mk];
    
end
toc                                 % end time
[optimal_profit_ak_sa, opt_ak_sa] = SimulatedAnnealing(problem, GreedySeats(ak, scenario));
[optimal_profit_bk_sa, opt_bk_sa] = SimulatedAnnealing(problem, GreedySeats(bk, scenario));
fprintf('The optimal number of seats lies in interval: [%d %d]\n', ak, bk);
fprintf('The optimal profit lies in interval: [%d %d]\n', optimal_profit_ak_sa, optimal_profit_bk_sa);