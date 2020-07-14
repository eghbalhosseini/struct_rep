function output=add_indices(tensor,change)
    if length(change)>1 & length(change)<8 %between 3 and 8 probe positions present
        diffs=[];
        for i=2:length(change)
            diffs=[diffs;change(i)-change(i-1)];
        end
        [best_diff,index]=max(diffs);
        if best_diff < change(1)-1 %most trials for position one (probe not present)
            new_indices=randsample(change(1),8-length(change));
            new_indices=sort([new_indices;change]);
            output=new_indices;
        elseif best_diff < size(tensor,3)-change(length(change)) %most trials for highest probe pos
            new_indices=randsample(change(length(change)):size(tensor,3),8-length(change));
            new_indices=sort([new_indices;change]);
            output=new_indices
        else %most trials for position b/w one and highest
            best_range=change(index:index+1);
            new_indices=randsample(best_range(1):best_range(2),8-length(change));
            new_indices=sort([new_indices;change]);
            output=new_indices;
        end
    elseif isempty(change) %only one probe pos present
        new_indices=round([size(tensor,3)/9:size(tensor,3)/9:size(tensor,3)-size(tensor,3)/9]);
        output=new_indices;
    elseif length(change)==1 %only two probe pos present
        if change(1)-1 > size(tensor,3)-change(1)
            new_indices=randsample(change(1),8-length(change));
            new_indices=sort([new_indices;change]);
            output=new_indices;
        else
            new_indices=randsample(change(1):size(tensor,3),8-length(change));
            new_indices=sort([new_indices;change]);
            output=new_indices;
        end
    else %num probe positions is 9
        output=change;
    end
end
            
        
            
            
            
            