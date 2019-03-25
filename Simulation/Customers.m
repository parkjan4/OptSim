classdef Customers < handle
    
    properties
        customerID          % integer
        time_arrival        % double
        groupsize           % integer
        dinner_duration     % double
        time_seated         % double
        revenue             % double
    end
    
    methods
        function [obj] = register_customer(obj,ID,time,size)
            % Create a "Customers" object for a newly arrived group
            obj.customerID = ID;
            obj.time_arrival = time;
            obj.groupsize = size;
            
            % Initialize missing values for now
            obj.dinner_duration = 0;
            obj.time_seated = inf;
            obj.revenue = 0;
        end
        
        function [] = seating(obj,time)
            % Update customer seating time
            obj.time_seated = time;
        end
        
        function [] = duration(obj,time)
            % Update customer dinner ending time
            obj.dinner_duration = time;
        end
        
        function [] = bill(obj,amount)
            obj.revenue = amount;
        end
    end
end

