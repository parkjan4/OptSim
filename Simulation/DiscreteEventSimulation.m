function [customers, tables, times, queues] = DiscreteEventSimulation(scenario)

% ============================================================================
% DESCRIPTION
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
% customers         Array of "Customers" objects
% tables            Array of "Tables" objects
% times             Row vector of event times
% queues            Row vector of queue sizes at the event times
%
% ---------------------------------------------------------------------------

% Create an array of "Tables" class objects
tables = [];
ID = 1;                                 % default starting ID
for i = 1:length(scenario.arrangement)
    for t = 1:scenario.arrangement(i)
        table = Tables;                 % initialize
        table.tableID = ID;
        table.tablesize = i;
        table.busyseats = 0;
        table.availableseats = i;
        table.assigned_customer = [];
        table.shared = false;
        tables = [tables, table];       % Update tables array
        ID = ID + 1;
    end
end

% First event is always "Arrival"
[t_a, groupsize] = CustomerArrival(0, scenario.arrival);
ID = 1;                                 % default for first customer
event = NewEvent(t_a, 1, ID);
EventList = UpdatedEventList([], event);

if event.time > scenario.Tmax           % Extremely rare case
    return 
end     

% Initialize an array for "Customers" class objects
customers = [];
customer = Customers;
register_customer(customer, ID, event.time, groupsize);

% Abandonment times
abandonment_list = Abandonments(event.time,[],ID);
event = NewEvent(abandonment_list(1,1), 3, ID);
EventList = UpdatedEventList(EventList, event);

% Initialize variables for measuring indicators
times = [];
queues = [];            % waiting line
num_busyseats = [];     % number of busy seats
num_busytables = [];    % number of busytables

while ~isempty(EventList)
    NextEvent = EventList(1);
    times = [times, NextEvent.time];
    
    switch NextEvent.type
        case 1 
            % Type: Arrival
            % Triggered events: Arrival, Duration (conditional)
            
            %% ===== Trigger next Arrival ===== 
            [t_a, groupsize] = CustomerArrival(NextEvent.time, scenario.arrival);
            if t_a > T                          
                EventList = EventList(2:end);
                continue; 
            end
            
            % Register the new customer
            customer = Customers;
            ID = customers(end).customerID + 1;
            register_customer(customer,ID,NextEvent.time,groupsize);
            
            %% ===== Trigger Duration ===== 
            [tables, assigned] = SeatingPolicy(customers, tables);
            
            if assigned == true
                r = rand();
                t_d = min(scenario.dmax, scenario.dmin - log(1 - r)*scenario.dmean);
                is_shared = tables([tables.assigned_customer]]==event.ID).shared;
                t_d = (1 - 0.5*is_shared)*t_d;    
                
            end
            
            % ===== BELOW DOES NOT NEED TO BE EDITED ===== 
            event_a = NewEvent(t_a, 1);
            event_d = NewEvent(t_d, 2);
            EventList = UpdatedEventList(EventList, event_a);
            EventList = UpdatedEventList(EventList, event_d);
            EventList = EventList(2:end);
            
        case 2 % Type: Duration
               % Triggered event: nothing
            
            
            
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
