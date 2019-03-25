function [assignedIDs, newCustomers, newTables] = ...
    SeatingAllocation(oldCustomers, oldTables, customerIDs, abandonment_list)

% ============================================================================
% DESCRIPTION
%
% usage: [assignedIDs, customers, tables] = SeatingAllocation(customers, tables, NextEvent.ID, abandonment_list)
% Allocates a seat to a refered groups, if possible. Queued users are
% assigned according to their arrival time.
% 5 Possible scenarios for assignment:
%   1)  There is no waiting line and there is an empty table.
%   2)  There is no waiting line, but there are no empty tables. There are
%       enough seats in a table to fit the refered group in a busy table.
%   3)  There is no waiting line and no available seats to fit the group
%       (without overpassing the table capacity).
%   4)  There is a waiting line and enough available seats to fit the
%       refered group.
%   5)  There is a waiting line and no enough available seats to fit the
%       refered group.
% 
% 5 Actions (one for each scenario):
%   1)  Assign the refered customer directly to an empty table.
%   2)  Assign the refered group to a shared table (best as possible or random).
%   3)  Assign the refered group to the queue.
%   4)  Assign the refered group to a shared table (best as possible or random).
%   5)  Assign the refered group to the queue.
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

% Verify whether the customer list is the queue:
if isequal(customerIDs,abandonment_list(:,2))
    % Put customerIDs in arrival order:
    [~,order]=sort(abandonment_list(:,3));
    customerIDs=customerIDs(order,:);
end

assignedIDs = [];
newCustomers=oldCustomers;
newTables=oldTables;

for i=1:length(customerIDs)
    customerID=customerIDs(i);
    [~,cID] = find([oldCustomers.customerID]==customerID,1);
    group_size=oldCustomers(cID).groupsize;
    if isempty(abandonment_list)
        % Identify empty tables:
        emptyTables = [oldTables.availableseats]==[oldTables.tablesize];
        if any(emptyTables)
            % Scenario 1:
            [~,te] = find(emptyTables==1,1);
            assign_customer(newTables(te), customerID, group_size);
            assignedIDs = [assignedIDs; newTables(te).tableID, newCustomers(cID).customerID];
        else
            % Identify available tables (have enough seats for the group):
            availableTables=[oldTables.availableseats]>=group_size;
            if any(availableTables)
                % Scenario 2:
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
                assign_customer(newTables(a_table), customerID, group_size);
                assignedIDs = [assignedIDs; newTables(a_table).tableID, newCustomers(cID).customerID];
    %       else
                % Scenario 3:
            end
        end
    else
        availableTables=[oldTables.availableseats]>=group_size;
        if any(availableTables)
            % Scenario 4:
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
            assign_customer(newTables(a_table), customerID, group_size);
            assignedIDs = [assignedIDs; newTables(a_table).tableID, newCustomers(cID).customerID];
    %   else
            % Scenario 5:
        end
    end
end

end
