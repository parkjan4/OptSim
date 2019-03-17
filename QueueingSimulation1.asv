function [times, queues] = QueueingSimulation1(scenario)

% ============================================================================
% DESCRIPTION
%
% usage: [times, queues] = QueueingSimulation1_mod(scenario)
%
% Runs a simulation of "scenario".
%
% ----------------------------------------------------------------------------
% PARAMETERS
%
% scenario
% .DEMAND_DURATION  length of the demand interval (how long vehicles enter)
% .T0               1 x 1 matrix that contains the free flow travel time
% .LAMBDA           1 x 1 matrix that contains the external entry rate
% .MU               1 x 1 matrix that contains the road service rate
% .JOBLENGTH        length of a single vehicle
%
% ---------------------------------------------------------------------------
% RETURN VALUES
%
% times             row vector of event times
% queues            row vector of queue sizes at the event times
%
% ---------------------------------------------------------------------------

% Step 1: First event (generation)
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
