function [assignedIDs, newCustomers, newTables] = ...
    SeatingAllocation_Reservation(oldCustomers, oldTables, customerIDs, abandonment_list)

% ============================================================================
% DESCRIPTION
%
% usage: [assignedIDs, customers, tables] = SeatingAllocation(customers, tables, NextEvent.ID, abandonment_list)
% Allocates a seat to a refered groups, if possible. Queued users are
% assigned according to the reservation policy and their arrival time.
%
% 4 Possible scenarios and resulting actions for groups with a reserved table:
%
%   1.1)  There is no waiting line and there is an empty table. Group is assigned to the table
%   1.2)  There is no waiting line, but there are no empty tables. Group added to the abandonments list.
%   1.3)  There is a waiting line and enough available seats in any reserved table. Group is assigned to the table
%   1.4)  There is a waiting line and no enough available seats to fit the refered group. Group added to the abandonments list.
%
% 5 Possible scenarios for assignment:
%   2.1)  There is no waiting line and there is an empty table.
%   2.2)  There is no waiting line, but there are no empty tables. There are
%       enough seats in a table to fit the refered group in a busy table.
%   2.3)  There is no waiting line and no available seats to fit the group
%       (without overpassing the table capacity).
%   2.4)  There is a waiting line and enough available seats to fit the
%       refered group.
%   2.5)  There is a waiting line and no enough available seats to fit the
%       refered group.
%  
% 5 Actions for groups without a reserved table (one for each scenario):
%
%   2.1)  Assign the refered customer directly to an empty table.
%   2.2)  Assign the refered group to a shared table (best as possible or random).
%   2.3)  Assign the refered group to the queue.
%   2.4)  Assign the refered group to a shared table (best as possible or random).
%   2.5)  Assign the refered group to the queue.
%
% ----------------------------------------------------------------------------
% PARAMETERS
% oldCustomers      Array of "Customer" class objects.
%
% oldTables         Line vector of "Tables" class objects. 
%
% customerID        ID of refered groups.
%
% abandonment_list  List of abandonments.
% ---------------------------------------------------------------------------
% RETURN VALUES
%
% assignedIDs       List of assigned tables' IDs.
%
% newCustomers      Updated "Customers" class object array.
%
% newTables         Updated "Tables" class object array.
% ============================================================================

% Take the input for the group size to reserve the tables

reservedgroup_size = 5;

assignedIDs = [];
newCustomers=oldCustomers;
newTables=oldTables;
arr_grpID = [];

% Verify whether the customer list is the queue:
if ~isempty(abandonment_list)
    if isequal(customerIDs,abandonment_list(:,2))
        % Put customerIDs in arrival order:
        [~,order]=sort(abandonment_list(:,3));
        customerIDs=customerIDs(order,:);
    end
end

for i=1:length(customerIDs)
    customerID=customerIDs(i);
    [~,cID] = find([oldCustomers.customerID]==customerID,1);
    group_size=oldCustomers(cID).groupsize;
    
    % Verify if the group has a reserved table
    if group_size == reservedgroup_size
       % Verify if there is a group, who is eligible for a reserved table,
       % in the queue
        for i = 1:size(abandonment_list,1)
            grpID = abandonment_list(i, 2);
            [~,groupID] = find([oldCustomers.customerID]==grpID,1);
            grpsize = oldCustomers(groupID).groupsize;
            if grpsize == reservedgroup_size
                arr_grpID = [arr_grpID grpID];
            end
        end
        if isempty(arr_grpID)
            % Identify empty tables with size n=reservedgroup_size
            emptyTables = [[oldTables.availableseats] == [oldTables.tablesize]] & [oldTables.tablesize] == reservedgroup_size; 
            if any(emptyTables)
                    % Scenario 1.1:
                    [~,rte] = find(emptyTables==1,1);
                    assign_customer(newTables(rte), customerID, group_size);
                    assignedIDs = [assignedIDs; newTables(rte).tableID, newCustomers(cID).customerID];
            %else 
                %Scenario 1.2
                %Added to the abandonment list
            end
        else 
            availableTables= [[oldTables.availableseats] == [oldTables.tablesize]] & [oldTables.availableseats]==group_size;
            if any(availableTables)
                % Scenario 1.3:
                a_table=0;
                for ta=1:length(availableTables)
                    % Try to assign best table:
                    if availableTables(ta)==1 && newTables(ta).availableseats==group_size
                        a_table=ta;
                        break;
                    end
                end
                if newTables(a_table).availableseats == group_size
                assign_customer(newTables(a_table), customerID, group_size);
                assignedIDs = [assignedIDs; newTables(a_table).tableID, newCustomers(cID).customerID];
                end
            %else
                 %Scenario 1.4
                
            end
        end
    else
        if isempty(abandonment_list)
        % Identify empty tables:
        emptyTables = [[oldTables.availableseats] == [oldTables.tablesize]] & [oldTables.tablesize] ~= reservedgroup_size;
            if any(emptyTables)
                % Scenario 2.1:
                [~,te] = find(emptyTables==1,1);
                if newTables(te).availableseats >= group_size
                    assign_customer(newTables(te), customerID, group_size);
                    assignedIDs = [assignedIDs; newTables(te).tableID, newCustomers(cID).customerID];
                end
            else
                % Identify available tables (have enough seats for the group):
                availableTables= [[oldTables.availableseats]>=group_size] & [oldTables.tablesize] ~= reservedgroup_size;
                if any(availableTables)
                    % Scenario 2.2:
                    a_table=0;
                    for ta=1:length(availableTables)
                        % Try to assign best table:
                        if availableTables(ta)==1 && newTables(ta).availableseats==group_size
                            a_table=ta;
                            break;
                        end
                    end
                    % If there is no best table, assign random table:
                    while a_table==0
                        r=rand();
                        newtab=floor(r*length(availableTables))+1;
                        if availableTables(newtab)==1
                            a_table=newtab;
                        end
                    end
                    if newTables(a_table).availableseats >= group_size
                        assign_customer(newTables(a_table), customerID, group_size);
                        assignedIDs = [assignedIDs; newTables(a_table).tableID, newCustomers(cID).customerID];
                    end
        %       else
                    % Scenario 2.3:
                end
            end
        else
            availableTables=[oldTables.availableseats]>=group_size;
            if any(availableTables)
                % Scenario 2.4:
                a_table=0;
                for ta=1:length(availableTables)
                    % Try to assign best table:
                    if availableTables(ta)==1 && newTables(ta).availableseats==group_size
                        a_table=ta;
                        break;
                    end
                end
                % If there is no best table, assign random table:
                while a_table==0
                    r=rand();
                    newtab=floor(r*length(availableTables))+1;
                    if availableTables(newtab)==1
                        a_table=newtab;
                    end
                end
                if newTables(a_table).availableseats >= group_size
                    assign_customer(newTables(a_table), customerID, group_size);
                    assignedIDs = [assignedIDs; newTables(a_table).tableID, newCustomers(cID).customerID];
                end
            end    
    %   else
            % Scenario 2.5:
        end
    end
end

end
