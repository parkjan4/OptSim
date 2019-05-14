
function [opt_val, opt_sol, values] = SimulatedAnnealing(problem, initial_solution)

% ============================================================================
% DESCRIPTION
%
% usage: [solutions, values, temperatures] = SimulatedAnnealing(problem)
%
% Solves the optimization problem "problem" using simulated annealing.
% "problem" is a MATLAB data structure. Using a data structure allows to
% pass problem specific information between the different function handles
% specified further below.
%
% ----------------------------------------------------------------------------
% PARAMETERS
%
% problem.M                   Number of temperature changes
% problem.K                   Number of iterations per level of temperature
% problem.D                   Average increase of the objective function
% problem.P0                  Initial acceptance probability
% problem.Pf                  Final acceptance probability                       
% problem.RANDOMIZE           table_neighbor.m
% problem.OBJECTIVE_FUNCTION  Run_Simulation.m
% initial_solution            By default, a greedy solution
% 
% ----------------------------------------------------------------------------
% RETURN VALUES
%
% opt_val                     Best mean profit value
% opt_sol                     Best table arrangement
%
% ============================================================================

accept_prob=[];
xc=initial_solution;
solutions=xc;
values=-problem.OBJECTIVE_FUNCTION(xc);
temperatures=zeros(problem.M*problem.K,1);
counter = 0;
f = waitbar(counter/(problem.M * problem.K));
for m=1:problem.M
    T=-problem.D/log(problem.P0+(problem.Pf-problem.P0)/problem.M*m);
    for k=1:problem.K
		counter = counter + 1;
		waitbar(counter/(problem.M * problem.K),f,'Running Simulated Annealing...') 
        temperatures((m-1)*problem.K+k)=T;
        % Select solution from a random neighbor:
        s = rand();
        if s <= 0.5
            y=problem.RANDOMIZE1(xc,0.5);
        else
            y=problem.RANDOMIZE2(xc,0.5);
        end
        fy=-problem.OBJECTIVE_FUNCTION(y);
        delta=fy-values(end);
        if delta<0
            xc=y;
            solutions=[solutions,y];
            values=[values,fy];
        else
            r2=rand();
            accept_prob(end+1)=exp(-delta/T);
            if r2<exp(-delta/T)
                xc=y;
                solutions=[solutions,y];
                values=[values,fy];
            else
                solutions=[solutions, solutions(:,end)];
                values=[values, values(end)];
            end
        end
    end
end
close(f);
% Find optimal solution
[opt_val, v] = min(values);
opt_sol = solutions(:,v);

end