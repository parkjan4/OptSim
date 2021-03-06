function [customers, tables, times, queues, num_busyseats,...
          num_busytables,num_cust_who_share] = DiscreteEventSimulation_Reservation(scenario)

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
% num_busyseats     Struct of 5 vectors with number of busy seats for each table size
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
customers = register_customer(Customers, ID, event.time, groupsize);
customers(1)=[];

% Initialize variables for measuring indicators
times = [];
queues = [];                % waiting line (number of customers)
num_busyseats.one = [];     % number of busy seats for table size 1
num_busyseats.two = [];     % number of busy seats for table size 2
num_busyseats.three = [];   % number of busy seats for table size 3
num_busyseats.four = [];    % number of busy seats for table size 4
num_busyseats.five = [];    % number of busy seats for table size 5
num_busytables = [];        % number of busytables
abandonment_list = [];
num_cust_who_share = [];     % number of shared tables

while ~isempty(EventList)
    NextEvent = EventList(1);
    times = [times, NextEvent.time];
    queues = [queues, size(abandonment_list,1)];
    num_busyseats.one = [num_busyseats.one, sum([tables([tables.tablesize]==1).busyseats])];
    num_busyseats.two = [num_busyseats.two, sum([tables([tables.tablesize]==2).busyseats])];
    num_busyseats.three = [num_busyseats.three, sum([tables([tables.tablesize]==3).busyseats])];
    num_busyseats.four = [num_busyseats.four, sum([tables([tables.tablesize]==4).busyseats])];
    num_busyseats.five = [num_busyseats.five, sum([tables([tables.tablesize]==5).busyseats])];
    num_busytables = [num_busytables, sum([tables.busyseats]~=0)];
    
    % Count number of customers who are sharing a table
    summand = 0;
    indices = find([tables.shared]); % returns indices for which shared==true
    for i=1:length(indices)
        summand = summand + length(tables(indices(i)).assigned_customer);
    end
    num_cust_who_share = [num_cust_who_share, summand];
    
    switch NextEvent.type
        case 1 
            % Type: Arrival
            % Triggered events: Arrival, Departure or Abandonment (conditional)
            
            %% ===== Trigger next Arrival ===== 
            [t_a, groupsize] = CustomerArrival(NextEvent.time, scenario.arrival);
            if t_a > scenario.Tmax
                EventList = EventList(2:end);
                continue; 
            end
            
            % Register the new customer
            ID = customers(end).customerID + 1;
            customers = register_customer(customers,ID,t_a,groupsize);
            
            % Update EventList
            event_a = NewEvent(t_a, 1, ID);
            EventList = UpdatedEventList(EventList, event_a);
            
            %% ===== Trigger Departure OR Abandonment ===== 
            [assignedIDs, customers, tables] = SeatingAllocation_Reservation(customers,...
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
%                 % Remove their corresponding abandoment events from EventList
%                 EventList([EventList.ID]==assignedIDs(1,2))=[];
%                 % Remove their corresponding rows in abandonment_list
%                 abandonment_list(abandonment_list(:,2)==assignedIDs(1,2),:)=[];

                % Generate dinner duration time
                r = rand();
                t_d = min(scenario.dmax, scenario.dmin - log(1 - r)*scenario.dmean);

                % Actual dinner end time (depends on whether table is shared)
                is_shared = tables(assignedIDs(1,1)).shared;
                t_d = NextEvent.time + (1 - 0.5*is_shared)*t_d;

                % Update "Customers" object (time seated, dinner end time)
                seating(customers,assignedIDs(1,2),NextEvent.time);
                departure(customers,assignedIDs(1,2),t_d);

                % Update EventList with the group which just get seated
                EventList=UpdatedEventList(EventList, NewEvent(t_d, 2, assignedIDs(1,2)));
                
                % Update dinner end time for customers that were
                % already seated in the same table
                if is_shared==1
                    for l=1:length([tables(assignedIDs(1,1)).assigned_customer])-1
                        newID=tables(assignedIDs(1,1)).assigned_customer(l);
                        t_dOld=customers(newID).dinner_departure;
                        t_dUpdated=NextEvent.time+(t_dOld-NextEvent.time)/2;
                        departure(customers,newID,t_dUpdated);
                        % Update EventList with the groups already
                        % seated in the shared table
                        eventrows=[EventList.time]==t_dOld;
                        EventList(eventrows).time=t_dUpdated;
                        updatedEvent=EventList(eventrows);
                        EventList(eventrows)=[];
                        EventList=UpdatedEventList(EventList,updatedEvent);
                    end
                end
            end

            EventList = EventList(2:end);
            
        case 2 
            % Type: Departure
            % Triggered event: Departure (conditional)
            
            %% ===== Compute revenue =====
            % Check if the table was shared {true, false}
            % Identify the tableNumber
            for i=1:length(tables)
                if ismember(NextEvent.ID,tables(i).assigned_customer)
                    tableNumber=i;
                    break
                end
            end
            % was_shared = tables([tables.assigned_customer]==NextEvent.ID).shared;
            was_shared = tables(tableNumber).shared;
            % Extract dinner duration time
            % dinner_length = customers([customers.customerID]==NextEvent.ID).dinner_duration;
            dinner_length = (customers(NextEvent.ID).dinner_departure-customers(NextEvent.ID).time_arrival);
            % calculate bill
            revenue=0;
            for i=1:customers(NextEvent.ID).groupsize
                % Draw customer consumption rate from uniform
                r = (scenario.consum_max - scenario.consum_min)*rand() + scenario.consum_min;
                revenue = revenue + (1 - 0.2*was_shared)*(r*60)*dinner_length;
            end
            
            % Update customers object field "revenue"
            bill(customers,NextEvent.ID,revenue);
            
            % Update tables object by removing this customer now
            remove_customer(tables, tableNumber, NextEvent.ID, customers(NextEvent.ID).groupsize);
            
            %% ===== Trigger Departure =====
            if isempty(abandonment_list)
                EventList = EventList(2:end);
                continue;
            else
                % Assign queued customers to a table (if possible)
                [assignedIDs, customers, tables] = SeatingAllocation_Reservation(customers,...
                                                             tables,...
                                                             abandonment_list(:,2),...
                                                             abandonment_list);
                if isempty(assignedIDs)     % Could not find any table
                    EventList = EventList(2:end);
                    continue;
                else
                    for k = 1:size(assignedIDs,1)
                        % Remove their corresponding abandoment events from EventList
                        EventList([EventList.ID]==assignedIDs(k,2))=[];
                        % Remove their corresponding rows in abandonment_list
                        abandonment_list(abandonment_list(:,2)==assignedIDs(k,2),:)=[];

                        % Generate dinner duration time
                        r = rand();
                        t_d = min(scenario.dmax, scenario.dmin - log(1 - r)*scenario.dmean);

                        % Actual dinner end time (depends on whether table is shared)
                        is_shared = tables(assignedIDs(k,1)).shared;
                        t_d = NextEvent.time + (1 - 0.5*is_shared)*t_d;

                        % Update "Customers" object (time seated, dinner end time)
                        seating(customers,assignedIDs(k,2),NextEvent.time);
                        departure(customers,assignedIDs(k,2),t_d);

                        % Update EventList with the group which just get seated
                        EventList=UpdatedEventList(EventList, NewEvent(t_d, 2, assignedIDs(k,2)));
                    end
                    % Update dinner end time for customers that were
                    % already seated in the same table
                    updatedTable = assignedIDs(1,1);
                    if tables(updatedTable).shared==1
                        for l=1:length([tables(updatedTable).assigned_customer])-1
                            newID=tables(updatedTable).assigned_customer(l);
                            t_dOld=customers(newID).dinner_departure;
                            t_dUpdated=NextEvent.time+(t_dOld-NextEvent.time)/2;
                            departure(customers,newID,t_dUpdated);
                            % Update EventList with the groups already
                            % seated in the shared table
                            eventrows=[EventList.time]==t_dOld;
                            EventList(eventrows).time=t_dUpdated;
                            updatedEvent=EventList(eventrows);
                            EventList(eventrows)=[];
                            EventList=UpdatedEventList(EventList,updatedEvent);
                        end
                    end
                end
            end
            
            EventList = EventList(2:end);
            
        otherwise
            % Type: Abandonment
            % Triggered event: nothing
            
            %% ==== Compute Abandonment (queue decreases by 1) ====
            abandonment_list = abandonment_list(2:end,:);
            EventList = EventList(2:end);
    end
end

end
