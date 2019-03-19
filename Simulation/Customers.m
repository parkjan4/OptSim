classdef Customers < handle
    
    properties
        customerID
        time_arrival
        groupsize
        dinner_duration
        time_seated
        revenue
    end
    
    methods
        function [] = register_customer(obj,ID,time,size)
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
            % Updates customer info when they are seated
            obj.time_seated = time;
        end
        
        function [] = duration(obj,time)
            % Updates customer dinner duration time
            obj.dinner_duration = time;
        end
        
        function [] = bill(obj,amount)
            obj.revenue = amount;
        end
    end
end

