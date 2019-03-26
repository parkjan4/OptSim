
function newEventList = UpdatedEventList(oldEventList, newEvent)

% ============================================================================
% DESCRIPTION
%
% usage: newEventList = UpdatedEventList(oldEventList, newEvent)
%
% Inserts "newEvent" into "oldEventList" (preserving an ascending time-ordering)
% and returns the updated "newEventList". Note that "oldEventList" stays unchanged!
%
% ----------------------------------------------------------------------------
% PARAMETERS
%
% oldEventList  the event list into which "newEvent" is to be inserted
% newEvent      the new event to be inserted
%
% ---------------------------------------------------------------------------
% RETURN VALUES
%
% newEventList  result of inserting "newEvent" into "newEventList" with ascending time ordering
%
% ============================================================================


%
% trivial insertion in case of an empty queue
%

if (isempty(oldEventList))
	newEventList(1) = newEvent;
	return
end

%
% binary search for position where to update
%

lower = 1;
upper = size(oldEventList,2) + 1;

while (lower < upper)
	pos = floor((lower + upper) / 2);
  curTime = oldEventList(pos).time;
  if (newEvent.time <= curTime)
		upper = pos;
	else
		lower = pos + 1;
  end
end

pos = lower;

%
% insert new element at previously found position
%

if (pos == 1)
	newEventList = [newEvent oldEventList];
else
  if (pos == size(oldEventList,2) + 1)
		newEventList = [oldEventList newEvent];
	else
		newEventList = [oldEventList(1:pos-1), newEvent, oldEventList(pos:size(oldEventList,2))];
  end
end
