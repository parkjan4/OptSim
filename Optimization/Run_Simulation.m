function [final_avg_profit, outputs] = Run_Simulation(table_arrangement)

if isequal(table_arrangement,[-1;-1;-1;-1;-1])
    final_avg_profit=0;
    outputs=[];
    return
end

%% Program
scenario = NewDay(table_arrangement);

groupsize_abandoned = [];
groupsize_admitted = [];
rMSE = inf; % initial value
r = 0;
while rMSE >= 100 || r < 100
    r = r + 1;
    % Run the simulation
    [customers, tables, times, queues, ...
        num_busyseats, num_busytables, cust_share] = DiscreteEventSimulation(scenario);

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
    
    % Max queue length throughout the day
    max_queue = max(queues);
    
    % Mean number of groups who share tables
    mean_share = mean(cust_share);

    if total_seats(1) ~= 0
        mean_util_seats.one(r) = mean(num_busyseats.one / total_seats(1));  
    end
    if total_seats(2) ~= 0
        mean_util_seats.two(r) = mean(num_busyseats.two / total_seats(2));
    end
    if total_seats(3) ~= 0
        mean_util_seats.three(r) = mean(num_busyseats.three / total_seats(3));
    end
    if total_seats(4) ~= 0
        mean_util_seats.four(r) = mean(num_busyseats.four / total_seats(4));
    end
    if total_seats(5) ~= 0
        mean_util_seats.five(r) = mean(num_busyseats.five / total_seats(5));
    end
    util_tables = num_busytables / total_tables;
    
    %% Control Variate (Number of group arrivals):
    tot_arrivals=length(customers);
    
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
        tot_arrivals_avg=tot_arrivals;
        tot_arrivals_var=0;
        max_queue_avg = max_queue;
        max_queue_var = 0;
        mean_share_avg = mean_share;
        mean_share_var = 0;
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
        [tot_arrivals_avg, tot_arrivals_var] = UpdatedStatistics(tot_arrivals_avg, tot_arrivals_var, tot_arrivals, r);
        [max_queue_avg, max_queue_var] = UpdatedStatistics(max_queue_avg, max_queue_var, max_queue, r);
        [mean_share_avg, mean_share_var] = UpdatedStatistics(mean_share_avg, mean_share_var, mean_share, r);
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
    
    tot_arrivals_all(r) = tot_arrivals;
    tot_arrivals_avg_all(r) = tot_arrivals_avg;
    tot_arrivals_var_all(r) = tot_arrivals_var;
    
    max_queue_all(r) = max_queue;
    max_queue_avg_all(r) = max_queue_avg;
    max_queue_var_all(r) = max_queue_var;
    
    mean_share_all(r) = mean_share;
    mean_share_avg_all(r) = mean_share_avg;
    mean_share_var_all(r) = mean_share_var;
    
    %% Update Controlled variate:
    [z_avg, z_var, z_all] = ControlledMean(profit_all,tot_arrivals_all,sum(sum(scenario.arrival)));
    z_avg_all(r) = z_avg;
    z_var_all(r) = z_var;
    
    %% Compute root MSE
    if r<=10
        continue
    end
    rMSE = sqrt(z_var / r);
    rMSEs(r-10) = rMSE;
    
end
final_avg_profit = z_avg_all(end);

% A struct to store all indicators
outputs.profit_all = z_all;
outputs.num_admitted_all = num_admitted_all;
outputs.num_admitted_avg_all = num_admitted_avg_all;
outputs.num_admitted_var_all = num_admitted_var_all;
outputs.num_abandon_all = num_abandon_all;
outputs.num_abandon_avg_all = num_abandon_avg_all;
outputs.num_abandon_var_all = num_abandon_var_all;
outputs.odds_abandon_all = odds_abandon_all;
outputs.odds_abandon_avg_all = odds_abandon_avg_all;
outputs.odds_abandon_var_all = odds_abandon_var_all;
outputs.max_waiting_times_all = max_waiting_times_all;
outputs.max_waiting_times_avg_all = max_waiting_times_avg_all;
outputs.max_waiting_times_var_all = max_waiting_times_var_all;
outputs.min_util_tables_all = min_util_tables_all;
outputs.min_util_tables_avg_all = min_util_tables_avg_all;
outputs.min_util_tables_var_all = min_util_tables_var_all;
outputs.max_queue_all = max_queue_all;
outputs.max_queue_avg_all = max_queue_avg_all;
outputs.max_queue_var_all = max_queue_var_all;
outputs.mean_share_all = mean_share_all;
outputs.mean_share_avg_all = mean_share_avg_all;
outputs.mean_share_var_all = mean_share_var_all;
