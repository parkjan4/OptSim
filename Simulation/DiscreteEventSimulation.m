function [customers, tables, times, queues] = DiscreteEventSimulation(scenario)

% ============================================================================
% DESCRIPTION
%
% usage: [times, queues] = DiscreteEventSimulation(scenario)
%
% Runs a simulation of "scenario".
%
% ----------------------------------------------------------------------------
% PARAMETERS
%
% scenario
% .arrival          5 x 3 matrix that contains arrival rates 
% .dmin             Minimum dinner duration
% .dmax             Maximum dinner duration
% .dmean            Mean dinner duration
% .consum_min       Minimum consumption rate
% .consum_max       Maximum consumption rate
% .Tmax             Business closing time
% .arrangement      5 x 1 matrix that contains number of tables for each type
% .seating          Seating policy
%
% ---------------------------------------------------------------------------
% RETURN VALUES
%
% times             row vector of event times
% queues            row vector of queue sizes at the event times
%
% ---------------------------------------------------------------------------

% Step 2: Create an array of "Tables" class objects
tables = [];
ID = 1;
for i = 1:length(scenario.arrangement)
    for t = 1:scenario.arrangement(i)
        table = Tables;
        table.tableID = ID;
        table.tablesize = i;
        table.busyseats = 0;
        table.assigned_customer = [];
        tables = [tables, table];
        ID = ID + 1;
    end
end

% Step 3: First event is always "Arrival"
[t_a, groupsize] = CustomerArrival(0, scenario.arrival);
event = NewEvent(t_a, 1);
EventList = UpdatedEventList([], event);

if event.time > scenario.Tmax 
    return 
end % Extremely rare case

% Initialize an array for "Customers" class objects
customers = [];
customer = Customers;
ID = 1; % default for first customer
register_customer(customer, ID, event.time, groupsize);

% Step 4: Initialize variables for measuring indicators
times = [];
queues = []; % waiting line

while ~isempty(EventList)
    NextEvent = EventList(1);
    times = [times, NextEvent.time];
    
    switch NextEvent.type
        case 1 % Type: Arrival
               % Triggered events: Arrival, Duration (conditional)
            
            % ===== TO BE EDITED ===== 
            % Simulate next event
            t_g = Exponential(scenario.LAMBDA);
            t_a = scenario.T0 * rand(1);
            if NextEvent.time + min(t_g,t_a) > T
                EventList = EventList(2:end);
                continue
            end
            
            % ===== BELOW DOES NOT NEED TO BE EDITED ===== 
            event_a = NewEvent(NextEvent.time + t_a, 1);
            event_d = NewEvent(NextEvent.time + t_d, 2);
            EventList = UpdatedEventList(EventList, event_a);
            EventList = UpdatedEventList(EventList, event_d);
            EventList = EventList(2:end);
            
        case 2 % Type: Duration
               % Triggered event: nothing

            % ===== TO BE EDITED ===== 
            % Simulate next event
            if q > 1
                EventList = EventList(2:end);
                continue
            end
            
        otherwise % Type: Abandonment
                  % Triggered event: nothing
            
            % ===== BELOW DOES NOT NEED TO BE EDITED ===== 
            % Simulate next event
            if q == 0
                EventList = EventList(2:end);
                continue
            end
    end
end

end
