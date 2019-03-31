
function DrawQueues(times, queues)

% ============================================================================
% DESCRIPTION
%
% usage: DrawQueues(times, queues)
%
% Draws the queue sizes in "queues" over the time points in "times"
%
% ----------------------------------------------------------------------------
% PARAMETERS
%
% times     a row vector of real-valued time points in increasing order
% queues	a matrix of queue sizes; each row of "queues" contains one
%           sequence of queue sizes to be plotted over "times"
%
% ---------------------------------------------------------------------------
% RETURN VALUES
%
% ============================================================================

times = times';
queues = queues';

newplot();

hold on;
plotlinks = 1:size(queues,2);

for (link = plotlinks)
    queue_id(link) = strcat(cellstr('Link no.') , int2str(link));
end

%plot(times,queues(:,:));
stairs(times,queues(:,:));
legend(queue_id(:),'Location','northwest')

title('utilization of seats over time');

drawnow();

hold off;
end
