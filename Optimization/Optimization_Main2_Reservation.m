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
thresh = 50;                    % "threshold" for switching from Greedy to another method

% Struct to store all sub-level structs of results from each Run_Simulation_Reservation()
OUTPUT = [];
Arrangement = [];

%% Greedy Search Method
problem.ak_SOLUTION = GreedySeats(ak, scenario);
problem.lk_SOLUTION = GreedySeats(lk, scenario);  % candidate arrangement
problem.mk_SOLUTION = GreedySeats(mk, scenario);
problem.bk_SOLUTION = GreedySeats(bk, scenario);

Arrangement.arrangement1 = problem.ak_SOLUTION;
Arrangement.arrangement2 = problem.lk_SOLUTION;
Arrangement.arrangement3 = problem.mk_SOLUTION;
Arrangement.arrangement4 = problem.bk_SOLUTION;

[theta_ak, outputs] = Run_Simulation_Reservation(problem.ak_SOLUTION);
theta_ak = -theta_ak;                             % negative profit
OUTPUT.arrangement1 = outputs;
[theta_lk, outputs] = Run_Simulation_Reservation(problem.lk_SOLUTION);  
theta_lk = -theta_lk;
OUTPUT.arrangement2 = outputs;
[theta_mk, outputs] = Run_Simulation_Reservation(problem.mk_SOLUTION);  
theta_mk = -theta_mk;
OUTPUT.arrangement3 = outputs;
[theta_bk, outputs] = Run_Simulation_Reservation(problem.bk_SOLUTION);
theta_bk = -theta_bk;
OUTPUT.arrangement4 = outputs;

% Used to collect number of seats investigated
ak_all = [];
bk_all = [];
lk_all = [];
mk_all = [];

ind = 5;
tic                                 % start time
while bk - ak >= thresh
    if theta_lk > theta_mk          % i.e. If profit with mk is higher
        ak = lk;
        lk = mk;
        mk = ak + alpha*(bk - ak);
        
        % Update lk, mk solutions
        theta_ak = theta_lk;
        theta_lk = theta_mk;
        problem.ak_SOLUTION = problem.lk_SOLUTION;
        problem.lk_SOLUTION = problem.mk_SOLUTION;
        problem.mk_SOLUTION = GreedySeats(mk, scenario);
        [theta_mk, outputs] = Run_Simulation_Reservation(problem.mk_SOLUTION);
        
        % Store
        theta_mk = -theta_mk;
        OUTPUT.(['arrangement' char(string(ind))]) = outputs;
        Arrangement.(['arrangement' char(string(ind))]) = problem.mk_SOLUTION;
        ind = ind + 1;
        
    else                            % i.e. If profit with lk is higher
        bk = mk;
        mk = lk;
        lk = ak + (1 - alpha)*(bk - ak);
        
        % Update lk, mk solutions
        theta_bk = theta_mk;
        theta_mk = theta_lk;
        problem.bk_SOLUTION = problem.mk_SOLUTION;
        problem.mk_SOLUTION = problem.lk_SOLUTION;
        problem.lk_SOLUTION = GreedySeats(lk, scenario);
        [theta_lk, outputs] = Run_Simulation_Reservation(problem.lk_SOLUTION);
        
        % Store
        theta_lk = -theta_lk;
        OUTPUT.(['arrangement' char(string(ind))]) = outputs;
        Arrangement.(['arrangement' char(string(ind))]) = problem.lk_SOLUTION;
        ind = ind + 1;
    end
    
    % Store progress
    ak_all = [ak_all, ak];
    bk_all = [bk_all, bk];
    lk_all = [lk_all, lk];
    mk_all = [mk_all, mk];
    
end
toc                                    % end time

fprintf('The optimal number of seats lies in interval: [%d %d]\n', ak, bk);
[best_val, indx] = max([-theta_ak -theta_lk -theta_mk -theta_bk]);
fprintf('Best mean profit found: %d\n', best_val);
disp('Corresponding table arrangement: ')
if indx==1
    disp(problem.ak_SOLUTION');
    fprintf('Number of seats: %d', problem.ak_SOLUTION'*[1;2;3;4;5]);
elseif indx==2
    disp(problem.lk_SOLUTION');
    fprintf('Number of seats: %d', problem.lk_SOLUTION'*[1;2;3;4;5]);
elseif indx==3
    disp(problem.mk_SOLUTION');
    fprintf('Number of seats: %d', problem.mk_SOLUTION'*[1;2;3;4;5]);
else
    disp(problem.bk_SOLUTION');
    fprintf('Number of seats: %d', problem.bk_SOLUTION'*[1;2;3;4;5]);
end
disp(newline)

%% VNS (Hybrid with Greedy Method)
problem.RANDOMIZE1 = @table_neighborSM1;     
problem.RANDOMIZE2 = @table_neighborSM2; 
problem.OBJECTIVE_FUNCTION = @Run_Simulation_Reservation;

counter = 1;
tic                                 % start time
while bk - ak >= l
    if theta_lk > theta_mk          % i.e. If profit with mk is higher
        ak = lk;
        lk = mk;
        mk = ak + alpha*(bk - ak);
        
        % Update lk, mk solutions
        theta_ak = theta_lk;
        theta_lk = theta_mk;
        problem.ak_SOLUTION = problem.lk_SOLUTION;
        problem.lk_SOLUTION = problem.mk_SOLUTION;
        [vns_solutions, vns_values, outputs] = VNS(problem, GreedySeats(mk, scenario));
        theta_mk = -vns_values(end);
        problem.mk_SOLUTION = vns_solutions(:,end);
        all_values.('run'+string(counter)) = vns_values; counter = counter + 1;
        
        % Store
        OUTPUT.(['arrangement' char(string(ind))]) = outputs;
        Arrangement.(['arrangement' char(string(ind))]) = problem.mk_SOLUTION;
        ind = ind + 1;
        
    else                            % i.e. If profit with lk is higher
        bk = mk;
        mk = lk;
        lk = ak + (1 - alpha)*(bk - ak);
        
        % Update lk, mk solutions
        theta_bk = theta_mk;
        theta_mk = theta_lk;
        problem.bk_SOLUTION = problem.mk_SOLUTION;
        problem.mk_SOLUTION = problem.lk_SOLUTION;
        [vns_solutions, vns_values, outputs] = VNS(problem, GreedySeats(lk, scenario));
        theta_lk = -vns_values(end);
        problem.lk_SOLUTION = vns_solutions(:,end);
        all_values.('run'+string(counter)) = vns_values; counter = counter + 1;
        
        % Store
        OUTPUT.(['arrangement' char(string(ind))]) = outputs;
        Arrangement.(['arrangement' char(string(ind))]) = problem.lk_SOLUTION;
        ind = ind + 1;
    end
    
    % Store progress (continuing from Greedy)
    ak_all = [ak_all, ak];
    bk_all = [bk_all, bk];
    lk_all = [lk_all, lk];
    mk_all = [mk_all, mk];
    
end
toc                                    % end time

fprintf('The optimal number of seats lies in interval: [%d %d]\n', ak, bk);
[best_val, indx] = max([-theta_ak -theta_lk -theta_mk -theta_bk]);
fprintf('Best mean profit found: %d\n', best_val);
disp('Corresponding table arrangement: ')
if indx==1
    disp(problem.ak_SOLUTION');
    fprintf('Number of seats: %d', problem.ak_SOLUTION'*[1;2;3;4;5]);
elseif indx==2
    disp(problem.lk_SOLUTION');
    fprintf('Number of seats: %d', problem.lk_SOLUTION'*[1;2;3;4;5]);
elseif indx==3
    disp(problem.mk_SOLUTION');
    fprintf('Number of seats: %d', problem.mk_SOLUTION'*[1;2;3;4;5]);
else
    disp(problem.bk_SOLUTION');
    fprintf('Number of seats: %d', problem.bk_SOLUTION'*[1;2;3;4;5]);
end
disp(newline)
disp(ak_all)
disp(bk_all)

%% Plot objective values over iterations
% plot the values for each iteration
vns_values = all_values.run3;
plot(vns_values,'-ko');title('Objective function values over iterations');
xlabel('Iteration');legend('iteration value');

figure();
vns_values = all_values.run4;
plot(vns_values,'-ko');title('Objective function values over iterations');
xlabel('Iteration');legend('iteration value');

figure();
vns_values = all_values.run5;
plot(vns_values,'-ko');title('Objective function values over iterations');
xlabel('Iteration');legend('iteration value');

save('OUTPUT_goldenVNS_reservation.mat','OUTPUT')
save('Arrangement_goldenVNS_reservation.mat','Arrangement')