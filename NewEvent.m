function event = NewEvent(time, type)

% =========================================================================
%
% DESCRIPTION
%
% usage: event = NewEvent(time, link, type)
%
% Generates a "type" event that occurred at "time" on "link"
%
% -------------------------------------------------------------------------
%
% PARAMETERS
%
% time   the time at which the event occurred; a real number
% type   the type of the event; an integer number where
%          1 = ARRIVAL event
%          2 = ARRIVAL event
%          3 = DEPARTURE (service) event
%          4 = SIMULATION END
%
% -------------------------------------------------------------------------
%
% RETURN VALUES
%
% event  a data structure with the three fields "time" and "type"
%        that represents the respective event
%
% =========================================================================
%

event.time = time;
event.type = type;

end
