function new_table_ar = table_neighborARN(old_table_ar,add_remove,n)

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

if n<3
    new_table_ar=repmat(old_table_ar,1,nchoosek(n+4-1,n));
    options=unique(sort(nchoosek(repmat(2:5,1,n),n),2),'rows');
else
    options=zeros(5,n);
    for i=1:5
        options(i,:)=sort(datasample(2:5,n));
%         test=sort(datasample(2:5,n));
%         while any(isequal(test,options))
%             test=sort(datasample(2:5,n));
%         end
%         options(i,:)=test;
    end
    options=unique(options,'rows');
    new_table_ar=repmat(old_table_ar,1,size(options,1));
end
if add_remove==0   % Add tables.
    for i=1:size(options,1)
        for j=1:n
            new_table_ar(options(i,j),i)=new_table_ar(options(i,j),i)+1;
        end
    end
else
    for i=1:size(options,1)
        for j=1:n
            new_table_ar(options(i,j),i)=new_table_ar(options(i,j),i)-1;
        end
    end
end
rest=sum((new_table_ar<0),1);
if sum(rest>0)
    new_table_ar(:,rest>0)=[];
    new_table_ar(:,end+1)=[-1;-1;-1;-1;-1];
end

end

