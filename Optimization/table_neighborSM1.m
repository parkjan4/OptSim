function new_table_ar = table_neighborSM1(old_table_ar,split_merge)

% =========================================================================
% DESCRIPTION
% 
% usage: new_table_ar = table_neighbor(old_table_ar,split_merge)
% Generates a list of table arrangements that are neighbors to a given
% table arrengement. Neighbors will have the same number of seats as the
% original one. New table arrengements are formend by spliting or merging
% tables of different sizes from the original arrangement. Mergers 2 tables
% into 1 table, or splits 1 tables into 2 tables.
% 
% -------------------------------------------------------------------------
% PARAMETERS
% 
% old_table_ar      Current table arrangement.
% split_merge       Binary number (Switch between split and merge.
%                   0: Split.
%                   Otherwise: Merge.
% 
% -------------------------------------------------------------------------
% RETURN VALUES
% 
% new_table_ar      List of neighbors to old_table_ar.
% 
% =========================================================================

new_table_ar=repmat(old_table_ar,1,2);
if split_merge==0   % Split tables.
    for k=4:5
        if old_table_ar(k)>0   % Checks whether there tables of size k, or not.
            % Remove one table of size k:
            new_table_ar(k,k-3)=new_table_ar(k,k-3)-1;
            option=table_options1(k);
            for l=1:size(option,2)
                new_table_ar(option(l),k-3)=new_table_ar(option(l),k-3)+1;
            end
        else
            new_table_ar(:,k-3)=[-1;-1;-1;-1;-1];   % Infeasible solution (Make simulation return profit = 0).
        end
    end
else    % Merge tables.
    for k=4:5
        option=table_options1(k);
        aux1=zeros(size(old_table_ar));
        aux2=zeros(size(option));
        for i=1:length(option)
            if aux2(i)==0
                aux1(option(i))=aux1(option(i))+sum(option==option(i));
                aux2(option==option(i))=1;
            end
        end
        if any(old_table_ar<aux1)
            new_table_ar(:,k-3)=[-1;-1;-1;-1;-1];   % Infeasible solution (Make simulation return profit = 0).
        else
            new_table_ar(:,k-3)=new_table_ar(:,k-3)-aux1;
            new_table_ar(k,k-3)=new_table_ar(k,k-3)+1;
        end
    end
end


end

