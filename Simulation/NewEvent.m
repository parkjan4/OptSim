function event = NewEvent(time, type, customerID)

% =========================================================================
%
% DESCRIPTION
%
% usage: event = NewEvent(time, type)
%
% Generates a "type" event that occurred at "time"
%
% -------------------------------------------------------------------------
%
% PARAMETERS
%
% time   the time at which the event occurred; a real number
% type   the type of the event; an integer where
%          1 = ARRIVAL event
%          2 = DURATION event
%          3 = ABANDONMENT event
%          4 = SIMULATION END
%
% -------------------------------------------------------------------------
%
% RETURN VALUES
%
% event  a data structure with the two fields "time" and "type"
%        that represent the respective event
%
% =========================================================================

event.ID = customerID;
event.time = time;
event.type = type;

end
