function [times, queues] = DiscreteEventSimulation(scenario)

% ============================================================================
% DESCRIPTION
%
% usage: [times, queues] = DiscreteEventSimulation(scenario)
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
% times             row vector of event times
% queues            row vector of queue sizes at the event times
%
% ---------------------------------------------------------------------------

% Step 1: Generate the first event (Customer Arrival)
event = NewEvent(Exponential(scenario.LAMBDA), 1);
EventList = UpdatedEventList([], event);
T = scenario.DEMAND_DURATION;
q = 0;
times = [];
queues = [];

if event.time > T % extremely rare case
    return
end

while ~isempty(EventList)
    NextEvent = EventList(1);
    times = [times, NextEvent.time];
    queues = [queues, q];
    
    switch NextEvent.type
        case 1 % Triggers generation, arrival
            
            % Simulate next event
            t_g = Exponential(scenario.LAMBDA);
            t_a = scenario.T0 * rand(1);
            if NextEvent.time + min(t_g,t_a) > T
                EventList = EventList(2:end);
                continue
            end
            event_g = NewEvent(NextEvent.time + t_g, 1);
            event_a = NewEvent(NextEvent.time + t_a, 2);
            EventList = UpdatedEventList(EventList, event_g);
            EventList = UpdatedEventList(EventList, event_a);
            EventList = EventList(2:end);
            
        case 2 % Triggers departure (if q = 1)
            q = q + 1;

            % Simulate next event
            if q > 1
                EventList = EventList(2:end);
                continue
            end
            t_d = Exponential(scenario.MU);
            event_d = NewEvent(NextEvent.time + t_d, 3);
            EventList = UpdatedEventList(EventList, event_d);
            EventList = EventList(2:end);
            
        otherwise % case 3
            q = q - 1;
            
            % Simulate next event
            if q == 0
                EventList = EventList(2:end);
                continue
            end
            t_d = Exponential(scenario.MU);
            event_d = NewEvent(NextEvent.time + t_d, 3);
            EventList = UpdatedEventList(EventList, event_d);
            EventList = EventList(2:end);
    end
end

end
