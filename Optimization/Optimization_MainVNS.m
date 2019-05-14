clear all
close all
clc

%% Optimization by Golden Section Method (minimize negative mean profit)

% Initialization
scenario = NewDay([]);

%% Greedy Search Method - Construction heuristic
InSeats=200;
problem.i_SOLUTION = GreedySeats(InSeats, scenario);  % candidate arrangement
Profit = Run_Simulation(problem.i_SOLUTION);  % profit

% Used to collect number of seats investigated
ak_all = [];

%% VNS 
%initialization
dummy=1;
new_sol=problem.i_SOLUTION; 
new_val=Profit;
current_val=0;
tic                                 % start time
while new_val>current_val
    %if a neighbor improves the solution, then we store and we keep searching    
    current_sol=new_sol;
    current_val=new_val;
    solutions(:,dummy)=current_sol; %each column is a new column
    values(:,dummy)=current_val;
    aux_break=0;
    
        %1st local search: Merge Tables (2,3,4...)
         %1.1
        if aux_break==0
            new_table_ar = table_neighborSM1(current_sol,1);
            for i=1:size(new_table_ar,2)
                new_sol=new_table_ar(:,i);
                new_val = Run_Simulation(new_sol);
                if new_val>current_val
                    aux_break=1;
                    break
                end
            end
        end
        %1.2
        if aux_break==0
             new_table_ar = table_neighborSM2(current_sol,1);
            for i=1:size(new_table_ar,2)
                new_sol=new_table_ar(:,i);
                new_val = Run_Simulation(new_sol);
                if new_val>current_val
                    aux_break=1;
                    break
                end
            end
        end
        
        
        %2nd local search: Split Tables (1,2,3...)
        %2.1
        if aux_break==0
            new_table_ar = table_neighborSM1(current_sol,0);
            for i=1:size(new_table_ar,2)
                new_sol=new_table_ar(:,i);
                new_val = Run_Simulation(new_sol);
                if new_val>current_val
                    aux_break=1;
                    break
                end
            end
        end
        %2.2
        if aux_break==0
             new_table_ar = table_neighborSM2(current_sol,0);
            for i=1:size(new_table_ar,2)
                new_sol=new_table_ar(:,i);
                new_val = Run_Simulation(new_sol);
                if new_val>current_val
                    aux_break=1;
                    break
                end
            end
        end
    
        
        %3rd local search: Add Tables (1,2,3,...)
        n=1;
        while aux_break==0 && n<6
            new_table_ar=table_neighborARN(current_sol,0,n);
                for i=1:size(new_table_ar,2)
                    new_sol=new_table_ar(:,i);
                    new_val = Run_Simulation(new_sol);
                    if new_val>current_val
                        aux_break=1;
                        break
                    end
                end
           n=n+1;
        end
               
        %4th local search: Remove Tables (1,2,3...)
        n=1;
        while aux_break==0 && n<6
            new_table_ar=table_neighborARN(current_sol,1,n);
                for i=1:size(new_table_ar,2)
                    new_sol=new_table_ar(:,i);
                    new_val = Run_Simulation(new_sol);
                    if new_val>current_val
                        aux_break=1;
                        break
                    end
                end
           n=n+1;
        end
    dummy=dummy+1;
end
    
toc                                    % end time



%% Plot objective values over iterations
% plot the values for each iteration
plot(values,'-ko');title('Objective function values over iterations');
xlabel('Iteration');legend('iteration value');