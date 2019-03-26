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
            obj(end+1).customerID = ID;
            obj(end).time_arrival = time;
            obj(end).groupsize = size;
            
            % Initialize missing values for now
            obj(end).dinner_duration = 0;
            obj(end).time_seated = inf;
            obj(end).revenue = 0;
        end
        
        function [] = seating(obj,ID,time)
            % Update customer seating time
            obj(ID).time_seated = time;
        end
        
        function [] = duration(obj,ID,time)
            % Update customer dinner ending time
            obj(ID).dinner_duration = time;
        end
        
        function [] = bill(obj,ID,amount)
            obj(ID).revenue = amount;
        end
    end
end

