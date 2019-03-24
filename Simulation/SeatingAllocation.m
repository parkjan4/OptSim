function [assignedIDs, customers, tables] = SeatingAllocation(customers, tables, NextEvent.ID, abandonment_list)

% ============================================================================
% DESCRIPTION
%
% usage: [assignedIDs, customers, tables] = SeatingAllocation(customers, tables, NextEvent.ID, abandonment_list)
% Allocating a seat to a group with a unique ID
%
% ----------------------------------------------------------------------------
% PARAMETERS
% customers         matrix of "Customer" class objects
%
% tables            1x40 matrix of "Tables" class objects 
%
% NextEvent.ID      attempt to find a seat to a customer if a new arrival is triggered
%
% abandonment_list  used to determine the customer group who is first in the queue
% ---------------------------------------------------------------------------
% RETURN VALUES
%
% assignedIDs       updated list of Tables.assigned_customer
%
% customers         updating the customer information 
%
% tables            updating the table information
% ============================================================================

%queue.queues = [ ], a list for the number of customers in queue. Last element is always the current number of customers waiting in line.
%queue.ID = [ ], list of customer ID's who are currently in the queue. First element is the first customer in line 
assignedIDs = [];
%queue_size = queue(end).queues;

% Scenario 1: There is no queue (abandonment list is empty), assigning incoming group to a table
if isempty(abandonment_list)
    group_size = customers(end).groupsize; % store size of the group
    customer_ID = customers(end).customerID; % store ID of the group
    for i = 1 :length(tables) % search all tables
        if tables(i).availableseats < group_size
            i = i+1; % in case of no availability, proceed to the next table
        else tables(i).availableseats >= group_size % case of availability 
            % customers(end).timeseated = NextEvent.time; --> no longer necessary
            assign_customer(tables(i), customers(end).customerID, customers(end).groupsize); 
            assignedIDs = [assignedIDs; tables(i).tableID customers(end).customerID];
            %tables(i).busyseats = group_size;
            %tables(i).availableseats = tables(i).availableseats - tables(i).busyseats;
            %tables(i).assigned_customer = [tables(i).assigned_customer customer_ID];
            %if length(tables(i).assigned_customer) > 1
                %tables(i).shared = true;
            %end    
        end       
    end
    %queue_size = queue_size + 1;
    %queue.queues = [queue.queues queue_size];
    %queue.ID = [queue.ID customers(end).customerID];

% Scenario 2: There is a queue, sorting the abandonment list to find tables
else
    for i = 1 : length(abandonment_list)
        customer_ID = abandonment_list(:,i); % store ID of the group
        index = find(customers.customerID == abandonment_list(:,i));
        group_size = customers(index).groupsize; % store size of the group
        for i = 1 : length(tables) % search all tables
            if tables(i).availableseats < group_size
                i = i+1; % in case of no availability, proceed to the next table
            else
                tables(i).availableseats >= group_size
                assign_customer(tables(i), customers(index).customerID, customers(index).groupsize); 
                assignedIDs = [assignedIDs; tables(i).tableID customers(index).customerID];
            end       
        end
    end
end
customers = customers;
tables = tables;
end
