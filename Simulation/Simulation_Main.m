%% Test the implementation of DiscreteEventSimulation.m

%% clean the workspace
clear all; %Removes all variables, functions, and MEX-files from memory, leaving the workspace empty
close all; % delete all figures whose handles are not hidden.
clc; % clear command window

%% Program
% Set the scenario 
table_arrangement1 = [0;0;0;0;40];      % Default
table_arrangement2 = [0;50;0;0;20];     % Second default
table_arrangement3 = [19;28;15;10;8];   % Table allocated according to arrival rate
table_arrangement4 = [1;28;15;12;10];   % Redistributed tables of size 1
scenario = NewDay(table_arrangement4);

runs = 100;
groupsize_abandoned = [];
groupsize_admitted = [];
for r=1:runs                
    % Run the simulation
    [customers, tables, times, queues, ...
        num_busyseats, num_busytables] = DiscreteEventSimulation(scenario);

    %% Compute indicators
    % Abandonment/Arrival ratio
    num_admitted = sum([customers.time_seated] ~= inf);
    num_abandon = sum([customers.time_seated] == inf);
    odds_abandon = num_abandon / num_admitted;
    
    % Group size distribution among customers who abandoned
    groupsize_abandoned = [groupsize_abandoned, ...
                          [customers([customers.time_seated] == inf).groupsize]];
    groupsize_admitted = [groupsize_admitted, ...
                         [customers([customers.time_seated] ~= inf).groupsize]];

    % Profit
    revenue = sum([customers.revenue]);
    cost = 0.10 * times(end) * 60 * ([1 2 3 4 5]*scenario.arrangement); % cost = 0.10 * closing time in minutes * total number of seats
    profit = revenue - cost;

    % Waiting times (vector)
    waiting_times = [customers.time_seated] - [customers.time_arrival];

    % Utilization measures (vectors)
    total_seats = [1,2,3,4,5]'.*scenario.arrangement;
    total_tables = ones(1,5)*scenario.arrangement;

    if total_seats(1) ~= 0
        util_seats.one = num_busyseats.one / total_seats(1);   
    end
    if total_seats(2) ~= 0
        util_seats.two = num_busyseats.two / total_seats(2);
    end
    if total_seats(3) ~= 0
        util_seats.three = num_busyseats.three / total_seats(3);
    end
    if total_seats(4) ~= 0
        util_seats.four = num_busyseats.four / total_seats(4);
    end
    if total_seats(5) ~= 0
        util_seats.five = num_busyseats.five / total_seats(5);
    end
    util_tables = num_busytables / total_tables;
    
    
    %% Collect statistics
    if r == 1
        num_admitted_avg = num_admitted;
        num_admitted_var = 0;
        num_abandon_avg = num_abandon;
        num_abandon_var = 0;
        odds_abandon_avg = odds_abandon;
        odds_abandon_var = 0;
        max_waiting_times_avg = max(waiting_times(waiting_times~=Inf));
        max_waiting_times_var = 0;
        min_util_tables_avg = min(util_tables);
        min_util_tables_var = 0;
        profit_avg = profit;
        profit_var = 0;
        overtime_avg = max(times) - scenario.Tmax;
        overtime_var = 0;
        revenue_avg = revenue;
        revenue_var = 0;
        cost_avg = cost;
        cost_var = 0;
        profit_avg = profit;
        profit_var = 0;
    else
        [num_admitted_avg, num_admitted_var] = UpdatedStatistics(num_admitted_avg, num_admitted_var, num_admitted, r);
        [num_abandon_avg, num_abandon_var] = UpdatedStatistics(num_abandon_avg, num_abandon_var, num_abandon, r);
        [odds_abandon_avg, odds_abandon_var] = UpdatedStatistics(odds_abandon_avg, odds_abandon_var, odds_abandon, r);
        [max_waiting_times_avg, max_waiting_times_var] = UpdatedStatistics(max_waiting_times_avg, max_waiting_times_var, max(waiting_times(waiting_times~=Inf)), r);
        [min_util_tables_avg, min_util_tables_var] = UpdatedStatistics(min_util_tables_avg, min_util_tables_var, min(util_tables), r);
        [profit_avg, profit_var] = UpdatedStatistics(profit_avg, profit_var, profit, r);
        [overtime_avg, overtime_var] = UpdatedStatistics(overtime_avg, overtime_var, max(times)-scenario.Tmax, r);
        [revenue_avg, revenue_var] = UpdatedStatistics(revenue_avg, revenue_var, revenue, r);
        [cost_avg, cost_var] = UpdatedStatistics(cost_avg, cost_var, cost, r);
        [profit_avg, profit_var] = UpdatedStatistics(profit_avg, profit_var, profit, r);
    end
    
    revenue_all(r) = revenue;
    revenue_avg_all(r) = revenue_avg;
    revenue_var_all(r) = revenue_var;
    
    cost_all(r) = cost;
    cost_avg_all(r) = cost_avg;
    cost_var_all(r) = cost_var;
    
    profit_all(r) = profit;
    profit_avg_all(r) = profit_avg;
    profit_var_all(r) = profit_var;
    
    num_admitted_all(r) = num_admitted;
    num_admitted_avg_all(r) = num_admitted_avg;
    num_admitted_var_all(r) = num_admitted_var;
    
    num_abandon_all(r) = num_abandon;
    num_abandon_avg_all(r) = num_abandon_avg;
    num_abandon_var_all(r) = num_abandon_var;
    
    odds_abandon_all(r) = odds_abandon;
    odds_abandon_avg_all(r) = odds_abandon_avg;
    odds_abandon_var_all(r) = odds_abandon_var;
    
    max_waiting_times_all(r) = max(waiting_times(waiting_times~=Inf));
    max_waiting_times_avg_all(r) = max_waiting_times_avg;
    max_waiting_times_var_all(r) = max_waiting_times_var;
    
    min_util_tables_all(r) = min(util_tables);
    min_util_tables_avg_all(r) = min_util_tables_avg;
    min_util_tables_var_all(r) = min_util_tables_var;
    
    overtime_all(r) = max(times) - scenario.Tmax;
    overtime_avg_all(r) = overtime_avg;
    overtime_var_all(r) = overtime_var;
    
end

%% Bootstrapping MSE
clc;
data_vector = profit_all;
Mean = mean(profit_all);

draws = 100;                     % Default (do not change)
sqrt_BootstrapMSE_Mean = sqrt(BootstrapMSE(data_vector, @mean, Mean, draws));

% Outputs
sqrt_MSE_mean = std(data_vector)/sqrt(runs);
display(Mean);                   % Empirical mean
display(sqrt_MSE_mean);          % Empirical MSE
display(sqrt_BootstrapMSE_Mean); % Should be cloes to MSE_mean

%% Visualization
close all;
clc;

%% Revenue, Cost & Profit visualization
% Running average (line plot) + variance + empirical MSE of revenue, cost &
% profit
% Revenue
figure;
plot(revenue_avg_all); hold on;
plot(sqrt(revenue_var_all),'LineStyle','--');
legend('Avg. Revenue','Std. Revenue');
xlabel('Number of Simulations');
ylabel('US Dollars');
title('Avg. and Std. Revenue');

% Cost
figure;
plot(cost_avg_all); hold on;
plot(sqrt(cost_var_all),'LineStyle','--');
legend('Avg. Cost','Std. Cost');
xlabel('Number of Simulations');
ylabel('US Dollars');
title('Avg. and Std. Cost');

% Profit
figure;
plot(profit_avg_all); hold on;
plot(sqrt(profit_var_all),'LineStyle','--');
legend('Avg. Profit','Std. Profit');
xlabel('Number of Simulations');
ylabel('US Dollars');
title('Avg. and Std. Profit');

%% Comparison
% Average
figure;
plot(revenue_avg_all);
hold on;
plot(cost_avg_all);
plot(profit_avg_all);
hold off;
title('Average Revenue, Cost & Profit');
xlabel('Number of Simulations');
ylabel('US Dollars');
legend('Average Revenue', 'Average Cost', 'Average Profit');
% All Values
figure;
title('Revenue, Cost & Profit');
xlabel('Number of Simulations');
ylabel('US Dollars');
plot(revenue_all);
hold on;
plot(cost_all);
plot(profit_all);
hold off;
title('Revenue, Cost & Profit');
xlabel('Number of Simulations');
ylabel('US Dollars');
legend('Revenue', 'Cost', 'Profit');

% Histogram of profits (worst case, 5th, mean, 95th)

plotHistogram(revenue_avg_all, false);
title('Distribution of Revenue');

plotHistogram(profit_avg_all, false);
title('Distribution of Profit');

plotHistogram(cost_avg_all, true);
title('Distribution of Cost');

%% Group size distribution among customers who abandoned
figure;
count_admitted = histcounts(groupsize_admitted,5);
count_abandoned = histcounts(groupsize_abandoned,5);

b1 = bar(count_admitted); b1.FaceAlpha=0.1; hold on;
b2 = bar(count_abandoned); b2.FaceAlpha=1;

xlabel('Group Size');
ylabel('Frequency [-] number of customers');
title('Customers who stayed vs. abandoned');
legend('Admitted','Abandoned')

%% Odds of customers abandoning our restaurant
figure;
plot(odds_abandon_avg_all); hold on;
plot(sqrt(odds_abandon_var_all),'LineStyle','--');
legend('avg odds','std odds');
xlabel('Number of simulations');
ylabel('Odds of customer abandonment');
title('Odds of customer abandonment');

% Max. waiting time distribution
plotHistogram(odds_abandon_all, true);
xlabel('Odds of customer abandonment');
title('Distribution of odds of customer abandonment');

%% Queue length over time visualization
DrawNetwork(scenario, times, queues);
figure;DrawQueues(times, queues);

%% Max. waiting time visualization (restricted only to customers who didn't leave)
figure;
plot(max_waiting_times_avg_all); hold on;
plot(sqrt(max_waiting_times_var_all),'LineStyle','--');
legend('avg max waiting time','std max waiting time');
xlabel('Number of simulations');
ylabel('Waiting time [hours]');
title('Average maximum waiting time in hours');

% Max. waiting time distribution
plotHistogram(max_waiting_times_all, true);
title('Distribution of max waiting time in hours');

%% Overtime distribution
figure;
plot(overtime_avg_all); hold on;
plot(sqrt(overtime_var_all),'LineStyle','--');
legend('avg overtime','std overtime');
xlabel('Number of simulations');
ylabel('Overtime [hours]');
title('Average overtime in hours');

% Max. waiting time distribution
plotHistogram(overtime_all, true);
title('Distribution of overtime in hours');
xlabel('Overtime [hours]');