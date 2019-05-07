function [arrangement] = GreedySeats(num_seats, scenario)

% DESCRIPTION:
% Takes "num_seats" and outputs a table arrangement in accordance with
% arrival rate (greedy solution)

denominator = sum(sum(scenario.arrival(2:end,:)));
probs = sum(scenario.arrival(2:end,:),2) / denominator;
arrangement = round([0;probs.*num_seats] ./ [1;2;3;4;5]);

end

