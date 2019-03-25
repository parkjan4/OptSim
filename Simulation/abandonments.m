function updated_abandonment = abandonments(t, old_abandonment, customer_ID)
% Updates the list of abandonments one a new group joins the queue.
% 
% =========================================================================
% Description:
%   Generates an updated abandonment list once a new group joins the queue.
% 
% -------------------------------------------------------------------------
% Input data:
%   t                   Current time in the simulation.
%   old_abandonment     Old list of abandonments.
%                       Contains: [times, customer_ID]
%   customer_ID         ID of the group that have just joined the queue.
% 
% -------------------------------------------------------------------------
% Output data:
%   updated_abandonment Updated abandonment list sorted by time for
%                       leaving. It contains:
%                       [Time of leaving, Group ID, Time of arrival].
% 
% -------------------------------------------------------------------------
% Intermidiate variables (alphabetical order):
%   elapsed_time        time spent in queue (step).
%   r                   pseudo-random number.
%   prob_ab             probability of leaving at each step.
%   t_abandonment       Actual time of leaving.
% 
% =========================================================================

elapsed_time=0;     % Initialize the time spent in queue.
while (true)
    elapsed_time=elapsed_time+5/60;    % Updates the elapsed time.
    r=rand();   % Generates a new random number at each trial, as customers check for abandonment every 5 minutes.
    % Updates the probability of leaving (abandonm) the queue according to the elapsed time.
    if elapsed_time<=5/60
        prob_ab=0.1;
    elseif elapsed_time<=10/60
        prob_ab=0.3;
    elseif elapsed_time<=20/60
        prob_ab=0.4;
    else
        prob_ab=0.5;
    end
    % Check whether the customer will leave or not the queue.
    if r<=prob_ab
        t_abandonment=t+elapsed_time;   % Sets the time for abandonment.
        break
    end
end

% Generates the updated abandonment list sorted by the time for abandonment.
updated_abandonment=sortrows([old_abandonment; t_abandonment customer_ID t]);

end

