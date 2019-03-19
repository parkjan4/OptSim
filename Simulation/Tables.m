classdef Tables < handle
    
    properties
        tableID
        tablesize
        busyseats
        assigned_customer
    end
    
    methods
        function [] = assign_customer(obj, customerID, groupsize)
            % Assign customerID to the table
            vec = [obj.assigned_customer, customerID];
            obj.assigned_customer = vec;
            
            % Increase number of busy seats by "groupsize"
            n = obj.busyseats + groupsize;
            if n > obj.tablesize
                error('Total assigned group exceeds table occupancy');
            end
            
            obj.busyseats = n;
        end
        
        function [] = remove_customer(obj, customerID, groupsize)
            % Removes customerID from the table
            index = obj.assigned_customer == customerID;
            
            if sum(index) == 0
                error('Cannot find customerID');
            end
            
            obj.assigned_customer(index) = [];
            
            % Decrease number of busy setas by "groupsize"
            obj.busyseats = obj.busyseats - groupsize;
            
        end
    end
end

