classdef Tables < handle
    
    properties
        tableID             % integer
        tablesize           % integer
        busyseats           % integer
        availableseats      % integer
        assigned_customer   % list of integers
        shared              % {true, false} boolean binary
    end
    
    methods
        function [] = assign_customer(obj, customerID, groupsize)
            % Assign customerID to the table
            vec = [obj.assigned_customer, customerID];
            obj.assigned_customer = vec;
            
            % Check if the table is shared
            if length(obj.assigned_customer) >= 2
                obj.shared = true;
            end
            
            % Increase number of busy seats by "groupsize"
            n = obj.busyseats + groupsize;
            if n > obj.tablesize
                error('Total assigned group exceeds table occupancy');
            end
            u = obj.availableseats - groupsize;
            
            obj.busyseats = n;
            obj.availableseats = u;
        end
        
        function [] = remove_customer(obj,tableNumber, customerID, groupsize)
            
            % Removes customerID from the table
            index = obj(tableNumber).assigned_customer == customerID;
            
            if sum(index) == 0
                error('Cannot find customerID');
            end
            
            obj(tableNumber).assigned_customer(index) = [];
            
            % Check if the table is still shared
            if length(obj(tableNumber).assigned_customer) <= 1
                obj(tableNumber).shared = false;
            end
            
            % Decrease number of busy seats by "groupsize"
            obj(tableNumber).busyseats = obj(tableNumber).busyseats - groupsize;
            obj(tableNumber).availableseats = obj(tableNumber).availableseats + groupsize;
            
        end
    end
end

