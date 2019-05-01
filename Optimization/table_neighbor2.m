function new_table_ar = table_neighbor2(old_table_ar,split_merge)

% =========================================================================
% DESCRIPTION
% 
% usage: new_table_ar = table_neighbor(old_table_ar,randomize)
% Generates a new table arrangement by spliting or merging tables. The
% total number of seats remaings the same. Mergers 3 tables into 2 tables,
% or splits 2 tables into 3.
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
    % Identify the size of tables to split:
    split=[2 4; 3 3; 2 5; 3 4; 3 5; 4 4; 4 5; 5 5];
    r2=randi(size(split,1));
    while (true)
        test_table=old_table_ar;
        for i=1:2
            test_table(split(r2,i))=test_table(split(r2,i))-1;
        end
        if any(test_table<0)
            r2=randi(size(split,1));
        else
            break
        end
    end
    for i=1:2
        new_table_ar(split(r2,i))=new_table_ar(split(r2,i))-1;
    end
    % Choose a set of tables with equivalent number of seats:
    options=table_options2(sum(split(r2,:)));
    r3=randi(size(options,1));
    for l=1:size(options,2)
        new_table_ar(options(r3,l))=new_table_ar(options(r3,l))+1;
    end
else    % Merge tables.
    % Identify the size of merged new table:
    merge=[2 4; 3 3; 2 5; 3 4; 3 5; 4 4; 4 5; 5 5];
    r2=randi(size(merge,1));
    while (true)
        options=table_options2(sum(merge(r2,:)));
        r3=randi(size(options,1));
        test_table=old_table_ar;
        for i=1:3
            test_table(options(r3,i))=test_table(options(r3,i))-1;
        end
        if any(test_table<0)
            r2=randi(size(merge,1));
        else
            for i=1:3
                new_table_ar(options(r3,i))=new_table_ar(options(r3,i))-1;
            end
            for i=1:2
                new_table_ar(merge(r2,i))=new_table_ar(merge(r2,i))+1;
            end
            break
        end
    end
end


end

