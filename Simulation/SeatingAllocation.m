function allocated_tables = SeatingAllocation(customers, tables, customerID, queue)

% ============================================================================
% DESCRIPTION
%
% usage: allocated_tables = SeatingAllocation(customers, tables, customerID, queue)
%
% Allocating a seat to a group with a unique ID
%
% ----------------------------------------------------------------------------
% PARAMETERS
% customers       matrix of "Customer" class objects
%
% tables     1x40 matrix of "Tables" class objects 
%
% customerID
%
% queue
% ---------------------------------------------------------------------------
% RETURN VALUES
%
% allocated_tables   
%
% ============================================================================

%queue.queues = [ ], a list for the number of customers in queue. Last element is always the current number of customers waiting in line.
%queue.ID = [ ], list of customer ID's who are currently in the queue. First element is the first customer in line 
allocated_tables = [];
queue_size = queue(end).queues;
if queue(end).queues == 0 
    group_size = customers(end).groupsize;
    customer_ID = customers(end).customerID;
    for i = 1 :length(tables)
        if tables(i).availableseats < group_size
            i = i+1;
        else tables(i).availableseats >= group_size
            customers(end).timeseated = 0;
            tables(i).busyseats = group_size;
            tables(i).availableseats = tables(i).availableseats - tables(i).busyseats;
            tables(i).assigned_customer = [tables(i).assigned_customer customer_ID];
            if length(tables(i).assigned_customer) > 1
                tables(i).shared = true;
            end    
        end       
    end
    queue_size = queue_size + 1;
    queue.queues = [queue.queues queue_size];
    queue.ID = [queue.ID customers(end).customerID];
else
    for i= 1:length(
    group_size = customers(end).groupsize;
    customer_ID = customers(end).customerID;
end

allocated_tables = [allocated_tables tables];

end
