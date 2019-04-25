function options = table_options(table_size)
% =========================================================================
% DESCRIPTION
% 
% usage: options = table_options(table_size)
% Generates the set of options to split tables of size k (or merge tables
% to a table of size k). Options are composed of a set of 2 table sizes.
% 
% -------------------------------------------------------------------------
% PARAMETERS
% 
% table_size    Size of the table to split/merge.
% 
% -------------------------------------------------------------------------
% RETURN VALUES
% 
% options       Set of options  to split/merge tables. Matrix of size
%               floor(table_size/2) x 2.
% 
% =========================================================================

options=zeros(floor(table_size/2),2);
for i=1:size(options,1)
    options(i,:)=[table_size-i i];
end

end

