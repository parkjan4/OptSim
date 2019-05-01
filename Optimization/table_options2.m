function options = table_options2(table_size)
% =========================================================================
% DESCRIPTION
% 
% usage: options = table_options2(table_size)
% Generates the set of options to split 2 tables with total size of k (or
% merge tables to 2 tables with total size of k). Options are composed of
% a set of 3 tables.
% 
% -------------------------------------------------------------------------
% PARAMETERS
% 
% table_size    Total size of the tables to split/merge.
% 
% -------------------------------------------------------------------------
% RETURN VALUES
% 
% options       Set of options  to split/merge tables.
% 
% =========================================================================

if table_size==6
    options=[2 2 2];
elseif table_size==7
    options=[2 2 3];
elseif table_size==8
    options=[2 2 4; 2 3 3];
elseif table_size==9
    options=[2 2 5; 2 3 4; 3 3 3];
elseif table_size==10
    options=[2 3 5; 2 4 4; 3 3 4];
end

end

