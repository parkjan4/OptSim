function new_table_ar = table_neighborSM2(old_table_ar,split_merge)

% =========================================================================
% DESCRIPTION
% 
% usage: new_table_ar = table_neighbor(old_table_ar,split_merge)
% Generates a list of table arrangements that are neighbors to a given
% table arrengement. Neighbors will have the same number of seats as the
% original one. New table arrengements are formend by spliting or merging
% tables of different sizes from the original arrangement. Mergers 3 tables
% into 2 tables, or splits 2 tables into 3.
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

options1=[2 2 2; 2 2 3; 2 2 4; 2 3 3; 2 2 5; 2 3 4; 3 3 3; 2 3 5; 2 4 4; 3 3 4];
options2=[2 4; 3 3; 2 5; 3 4; 3 5; 4 4; 4 5; 5 5];
n1=sum(options1,2);
n2=sum(options2,2);
q1=1:length(n1);
q2=1:length(n2);
adic=0;
for i=1:length(n2)
    adic=adic+sum(n1==n2(i));
end
new_table_ar=repmat(old_table_ar,1,adic);

if split_merge==0   % Split tables.
    l=0;
    for i=q2
        for j=q1(n1==n2(i))
            l=l+1;
            aux1=zeros(size(old_table_ar));
            aux2=zeros(1,size(options2,2));
            for k=1:size(options2,2)
                if aux2(k)==0
                    aux1(options2(i,k))=aux1(options2(i,k))+sum(options2(i,:)==options2(i,k));
                    aux2(options2(i,:)==options2(i,k))=1;
                end
            end
            if any(old_table_ar<aux1)
                new_table_ar(:,l)=[-1;-1;-1;-1;-1]; % Infeasible solution (Make simulation return profit = 0).
            else
                new_table_ar(:,l)=new_table_ar(:,l)-aux1;
                for k=1:size(options1,2)
                    new_table_ar(options1(j,k),l)=new_table_ar(options1(j,k),l)+1;
                end
            end
        end
    end
else    % Merge tables.
    l=0;
    for i=q1
        for j=q2(n2==n1(i))
            l=l+1;
            aux1=zeros(size(old_table_ar));
            aux2=zeros(1,size(options1,2));
            for k=1:size(options1,2)
                if aux2(k)==0
                    aux1(options1(i,k))=aux1(options1(i,k))+sum(options1(i,:)==options1(i,k));
                    aux2(options1(i,:)==options1(i,k))=1;
                end
            end
            if any(old_table_ar<aux1)
                new_table_ar(:,l)=[-1;-1;-1;-1;-1]; % Infeasible solution (Make simulation return profit = 0).
            else
                new_table_ar(:,l)=new_table_ar(:,l)-aux1;
                for k=1:size(options2,2)
                    new_table_ar(options2(j,k),l)=new_table_ar(options2(j,k),l)+1;
                end
            end
        end
    end
end
new_table_ar=unique(new_table_ar','rows')';

end

