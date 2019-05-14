function new_table_ar = table_neighbor1MergeSample(old_table_ar,split_merge)

% =========================================================================
% DESCRIPTION
% 
% usage: new_table_ar = table_neighbor(old_table_ar,randomize)
% Generates a new table arrangement by spliting or merging tables. The
% total number of seats remaings the same. Merges two tables into one, or
% split one table into two.
% 
% -------------------------------------------------------------------------
% PARAMETERS
% 
% old_table_ar      Current table arrangement.
% split_merge       Real number in the interval [0,1] used as switch
%                   to merge or split tables.
% 
% -------------------------------------------------------------------------
% RETURN VALUES
% 
% new_table_ar      New table arrangement (neighbor of old_table_ar).
% 
% =========================================================================

new_table_ar=old_table_ar;
r1=rand();
if r1<split_merge   % Split tables.
    probs = [0 0 0 0.5 0.5];    % Probability vector to choose tables to split (Tables of size 1, 2 and 3 cannot be splitted).
    % Identify the size of tables to split:
    r2=rand();
    k=1;
    while (true)
        if r2<sum(probs(1:k))
            if old_table_ar(k)>0   % Checks whether there tables of size k, or not.
                % Remove one table of size k:
                new_table_ar(k)=new_table_ar(k)-1;
                break
            else
                r2=rand();
            end
        else
            k=k+1;
        end
    end
    % Choose a set of tables with equivalent number of seats:
    options=table_options1(k);
    r3=randi(size(options,1));
    for l=1:size(options,2)
        new_table_ar(options(r3,l))=new_table_ar(options(r3,l))+1;
    end
else    % Merge tables.
    probs = [0 0 0 0.5 0.5];    % Probability vector to choose the size of the merged new table.
    % Identify the size of merged new table:
    r2=rand();
    k=1;
    while (true)
        if r2<sum(probs(1:k))
            options=table_options1(k);
            r3=randi(size(options,1));
            if any(old_table_ar(options(r3,:))==0)
                r2=rand();
            else
                new_table_ar(k)=new_table_ar(k)+1;
                for l=1:size(options(r3,:),2)
                    new_table_ar(options(r3,l))=new_table_ar(options(r3,l))-1;
                end
                break
            end
        else
            k=k+1;
        end
    end
end


end

