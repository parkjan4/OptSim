function [solutions,values,best_outputs] = VNS(problem, init_soln)
% Description:
% ------------
% PARAMETERS
%                    
% problem.RANDOMIZE1           table_neighborSM1.m
% problem.RANDOMIZE2           table_neighborSM2.m
% problem.OBJECTIVE_FUNCTION   Run_Simulation.m
% init_soln                    Greedy solution (GreedySeats.m)
%
% ----------------------------------------------------------------------------
% RETURN VALUES
%
% solutions                    Matrix of (progressively better) table arrangements
% values                       Vector of (progressively better) mean profits
%
% ============================================================================

dummy = 0;
current_val = 0;
new_sol = init_soln;
[new_val,~] = problem.OBJECTIVE_FUNCTION(new_sol);
f = waitbar(dummy/10);
while new_val>current_val
    waitbar(dummy/10,f,'Running VNS...');
    dummy = dummy + 1;
    
    %if a neighbor improves the solution, then we store and we keep searching    
    current_sol=new_sol;
    current_val=new_val;
    solutions(:,dummy)=current_sol; %each column is a new column
    values(:,dummy)=current_val;
    aux_break=0;
    
    %1st local search: Merge Tables (2,3,4...)
    %1.1
    if aux_break==0
        new_table_ar = problem.RANDOMIZE1(current_sol,1);
        for i=1:size(new_table_ar,2)
            new_sol=new_table_ar(:,i);
            [new_val,outputs] = problem.OBJECTIVE_FUNCTION(new_sol);
            if new_val>current_val
                aux_break=1;
                best_outputs = outputs;
                break
            end
        end
    end
    %1.2
    if aux_break==0
         new_table_ar = problem.RANDOMIZE2(current_sol,1);
        for i=1:size(new_table_ar,2)
            new_sol=new_table_ar(:,i);
            [new_val,outputs] = problem.OBJECTIVE_FUNCTION(new_sol);
            if new_val>current_val
                aux_break=1;
                best_outputs = outputs;
                break
            end
        end
    end


    %2nd local search: Split Tables (1,2,3...)
    %2.1
    if aux_break==0
        new_table_ar = problem.RANDOMIZE1(current_sol,0);
        for i=1:size(new_table_ar,2)
            new_sol=new_table_ar(:,i);
            [new_val,outputs] = problem.OBJECTIVE_FUNCTION(new_sol);
            if new_val>current_val
                aux_break=1;
                best_outputs = outputs;
                break
            end
        end
    end
    %2.2
    if aux_break==0
         new_table_ar = problem.RANDOMIZE2(current_sol,0);
        for i=1:size(new_table_ar,2)
            new_sol=new_table_ar(:,i);
            [new_val,outputs] = problem.OBJECTIVE_FUNCTION(new_sol);
            if new_val>current_val
                aux_break=1;
                best_outputs = outputs;
                break
            end
        end
    end
end


end

