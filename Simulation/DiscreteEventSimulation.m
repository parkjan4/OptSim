function [customers, tables, times, queues, num_busyseats, num_busytables] = DiscreteEventSimulation(scenario)

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
% num_busyseats     Row vector of number of busy seats at the event times
% num_busytables    Row vector of number of busy tables at the event times
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
event = NewEvent(t_a, 1, ID);           % create an event
EventList = UpdatedEventList([], event);% update (and sort) EventList

if event.time > scenario.Tmax           % extremely rare case
    return 
end     

% Initialize an array for "Customers" class objects
customers = [];
customer = Customers;                   % initialize "Customers" object
customer = register_customer(customer, ID, event.time, groupsize);
customers = [customers, customer];

% Initialize variables for measuring indicators
times = [];
queues = [];     % waiting line (number of customers)
num_busyseats = [];     % number of busy seats
num_busytables = [];    % number of busytables
abandonment_list = [];  

while ~isempty(EventList)
    NextEvent = EventList(1);
    times = [times, NextEvent.time];
    queues = [queues, size(abandonment_list,1)];
    num_busyseats = [num_busyseats, sum([tables.busyseats])];
    num_busytables = [num_busytables, sum([tables.busyseats]~=0)];
    
    switch NextEvent.type
        case 1 
            % Type: Arrival
            % Triggered events: Arrival, Duration or Abandonment (conditional)
            
            %% ===== Trigger next Arrival ===== 
            [t_a, groupsize] = CustomerArrival(NextEvent.time, scenario.arrival);
            if t_a > scenario.Tmax
                EventList = EventList(2:end);
                continue; 
            end
            
            % Register the new customer
            customer = Customers;
            ID = customer(end).customerID + 1;
            customer = register_customer(customer,ID,NextEvent.time,groupsize);
            customers = [customers, customer];
            
            % Update EventList
            event_a = NewEvent(t_a, 1);
            EventList = UpdatedEventList(EventList, event_a);
            
            %% ===== Trigger Duration OR Abandonment ===== 
            [assignedIDs, customers, tables] = SeatingAllocation(customers,...
                                                             tables,...
                                                             NextEvent.ID,...
                                                             abandonment_list);
            
            if isempty(assignedIDs)     % customer did not find a table
                % Put the customer in the queue
                abandonment_list = abandonments(NextEvent.time,...
                                                abandonment_list,...
                                                NextEvent.ID);
                
                % Create an abandonment event & update EventList
                t_aban = abandonment_list(abandonment_list(:,2)==NextEvent.ID,1);
                event_aban = NewEvent(t_aban,3,NextEvent.ID);
                EventList = UpdatedEventList(EventList, event_aban);
            else                        % customers who found a table
                for k = 1:length(assignedIDs)
                    % Remove their corresponding abandoment events from EventList
                    EventList([EventList.ID]==assignedIDs(:,k))=[];
                    % Remove their corresponding rows in abandonment_list
                    abandonment_list(abandonment_list(:,2)==assignedIDs(:,k),:)=[];
                    
                    % Generate dinner duration time
                    r = rand();
                    t_d = min(scenario.dmax, scenario.dmin - log(1 - r)*scenario.dmean);
                    
                    % Actual dinner end time (depends on whether table is shared)
                    is_shared = tables([tables.assigned_customer]==assignedIDs(:,k)).shared;
                    t_d = NextEvent.time + (1 - 0.5*is_shared)*t_d;    
                    
                    % Update "Customers" object (time seated, dinner end time)
                    seating(customers([customers.customerID]==assignedIDs(:,k)),NextEvent.time);
                    duration(customers([customers.customerID]==assignedIDs(:,k)),t_d);
                    
                    % Update EventList
                    EventList(UpdatedEventList(EventList, NewEvent(t_d, 2)));
                end
            end

            EventList = EventList(2:end);
            
        case 2 
            % Type: Duration
            % Triggered event: Duration (conditional)
            
            %% ===== Compute revenue =====
            % Check if the table was shared {true, false}
            was_shared = tables([tables.assigned_customer]==NextEvent.ID).shared;
            % Extract dinner duration time
            dinner_length = customers([customers.customerID]==NextEvent.ID).dinner_duration;
            % Draw customer consumption rate from uniform
            r = (scenario.consum_max - scenario.consum_min)*rand() + scenario.consum_min;
            % calculate bill
            revenue = (1 - 0.6*was_shared)*r*dinner_length;
            
            % Update customers object field "revenue"
            bill(customers([customers.customerID]==NextEvent.ID),revenue);
            
            % Update tables object by removing this customer now
            remove_customer(tables([tables.assigned_customer]==NextEvent.ID),...
                            NextEvent.ID,...
                            customers([customers.customerID]==NextEvent.ID).groupsize);
            
            %% ===== Trigger Duration =====
            if isempty(abandonment_list)
                EventList = EventList(2:end);
                continue;
            else
                % Get as many customers in the queue to sit down
                [assignedIDs, customers, tables] = SeatingAllocation(customers,...
                                                             tables,...
                                                             abandonment_list(:,2),...
                                                             abandonment_list);
                if isempty(assignedIDs)     % Could not find any table
                    EventList = EventList(2:end);
                    continue;
                else
                    for k = 1:length(assignedIDs)
                        % Remove their corresponding abandoment events from EventList
                        EventList([EventList.ID]==assignedIDs(:,k))=[];
                        % Remove their corresponding rows in abandonment_list
                        abandonment_list(abandonment_list(:,2)==assignedIDs(:,k),:)=[];

                        % Generate dinner duration time
                        r = rand();
                        t_d = min(scenario.dmax, scenario.dmin - log(1 - r)*scenario.dmean);

                        % Actual dinner end time (depends on whether table is shared)
                        is_shared = tables([tables.assigned_customer]==assignedIDs(:,k)).shared;
                        t_d = NextEvent.time + (1 - 0.5*is_shared)*t_d;    

                        % Update "Customers" object (time seated, dinner end time)
                        seating(customers([customers.customerID]==assignedIDs(:,k)),NextEvent.time);
                        duration(customers([customers.customerID]==assignedIDs(:,k)),t_d);

                        % Update EventList
                        EventList(UpdatedEventList(EventList, NewEvent(t_d, 2)));
                    end
                end
            end
            
            EventList = EventList(2:end);
            
        otherwise
            % Type: Abandonment
            % Triggered event: nothing
            
            % Update abandonment_list (queue decreases by 1)
            abandonment_list = abandonment_list(2:end,:);
            EventList = EventList(2:end);
    end
end

end
