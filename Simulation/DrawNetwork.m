function DrawNetwork(scenario, times, queues)

% ============================================================================
% DESCRIPTION
%
% usage: DrawNetwork(scenario, times, queues)
%
% Animates the congestion status of the network
%
% ----------------------------------------------------------------------------
% PARAMETERS
%
% scenario    the definition of the simulation scenario as returned by [[ref]]
% times       row vector of time points for which queue lengths are avail.
% queues      matrix(link, time) of all queue lengths in the network
%
% ---------------------------------------------------------------------------
% RETURN VALUES
%
% ============================================================================

times = times';
queues = queues';

%
% IDENTIFY NETWORK DIMENSION
%

xMin =  9999999.99;
xMax = -9999999.99;
yMin =  9999999.99;
yMax = -9999999.99;

for i=1:size(scenario.X1,2)
	xMin = min(xMin, min(scenario.X1(i), scenario.X2(i)));
	xMax = max(xMax, max(scenario.X1(i), scenario.X2(i)));
	yMin = min(yMin, min(scenario.Y1(i), scenario.Y2(i)));
	yMax = max(yMax, max(scenario.Y1(i), scenario.Y2(i)));
end

dX = max(1.0, xMax - xMin);
dY = max(1.0, yMax - yMin);

xMin = xMin - 0.1 * dX;
xMax = xMax + 0.1 * dX;
yMin = yMin - 0.1 * dY;
yMax = yMax + 0.1 * dY;


%
% IDENTIFY LINK VISIBILITY
%

if isfield(scenario, 'INVISIBLE')
	INVISIBLE = scenario.INVISIBLE;
else
	INVISIBLE = zeros(1, size(scenario.X1,2));
end

%
% EXTRACT RELEVANT DATA ROWS
%

k = 1;
lasttime = -scenario.STEPSIZE;

newqueues = [];
newtimes  = [];

for k=1:size(times,1)

    if (times(k) >= lasttime + scenario.STEPSIZE)
        if(size(newqueues,1) == 0)
			newtimes  = times(k);
			newqueues = queues(k,:);
		else
			newtimes  = [newtimes; times(k,:)];
			newqueues = [newqueues; queues(k,:)];
        end
		lasttime = lasttime + scenario.STEPSIZE;
    end

end

queues = newqueues;
times  = newtimes;


%
% LOOP OVER DATA AND DISPLAY
%

for k=1:size(queues,1)

	tic();

	newplot();
    hold on;

    axis([xMin xMax yMin yMax]);
    axis off;
    axis square;

	title(strcat('time = ', num2str(times(k))));

    for i=1:size(scenario.X1,2)

		x1 = scenario.X1(i);
		x2 = scenario.X2(i);
		y1 = scenario.Y1(i);
		y2 = scenario.Y2(i);

		dX = x2 - x1;
		dY = y2 - y1;

        if isfield(scenario, 'JOBWIDTH')

			scale = 2.0 * scenario.JOBWIDTH / sqrt(dX * dX + dY * dY);

			x1 = x1 + scale * dX;
			x2 = x2 - scale * dX;
			y1 = y1 + scale * dY;
			y2 = y2 - scale * dY;

			dX = x2 - x1;
			dY = y2 - y1;

            if abs(dX) < abs(dY)
				xShift = scenario.JOBWIDTH / sqrt(1.0 + (dX/dY)^2);
				yShift = - xShift * dX / dY;
			else
				yShift = scenario.JOBWIDTH / sqrt(1.0 + (dY/dX)^2);
				xShift = - yShift * dY / dX;
            end

            if (dY >= 0)
				x1 = x1 + xShift;
				x2 = x2 + xShift;
			else
				x1 = x1 - xShift;
				x2 = x2 - xShift;
            end

            if (dX >= 0)
				y1 = y1 - yShift;
				y2 = y2 - yShift;
			else
				y1 = y1 + yShift;
				y2 = y2 + yShift;
            end

        end

		cong  = (queues(k, i) * scenario.JOBLENGTH) / sqrt(dX * dX + dY * dY);

        if INVISIBLE(i)
			LINK_COLOR = [0.9 0.9 0.9];
		else
			LINK_COLOR = [0.7 0.7 0.7];
        end
		plot([x1; x2], [y1; y2], 'linewidth', 10, 'color', LINK_COLOR);
		plot([x2 - cong * dX; x2], [y2 - cong * dY; y2], 'linewidth', 10, 'color', [1 0.25 0.25]);

		x = (1.0 - scenario.TEXTPOS) * x1 + scenario.TEXTPOS * x2 + 0.25*scenario.TEXTPOS;
		y = (1.0 - scenario.TEXTPOS) * y1 + scenario.TEXTPOS * y2 + 0.25*scenario.TEXTPOS;
		text(x, y, strcat(num2str(i), ':', num2str(queues(k, i))));

    end

    drawnow;

	hold off;



	pause(max(0, scenario.MINDELAY - toc()));
end
end
