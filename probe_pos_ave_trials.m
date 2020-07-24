%%Separate tensor at change indices, take averages, put back together
function output=probe_pos_ave_trials(change, tensor)
    if isempty(change)
        new_tensor=mean(tensor,3);
        dims_needed=8;
        filler=NaN(size(tensor,1),size(tensor,2),dims_needed);
        new_tensor=cat(3,new_tensor,filler);
        output=new_tensor;
    elseif length(change)==1
        temp_tensor=tensor(:,:,1:change(1)-1);
        new_tensor=mean(temp_tensor,3);
        temp_tensor=tensor(:,:,change(1):end);
        new_tensor=cat(3,new_tensor,mean(temp_tensor,3));
        dims_needed=9-size(new_tensor,3);
        filler=NaN(size(tensor,1),size(tensor,2),dims_needed);
        new_tensor=cat(3,new_tensor,filler);
        output=new_tensor;
    else
        temp_tensor=tensor(:,:,1:change(1)-1);
        new_tensor=mean(temp_tensor,3);
        for i=2:length(change)
            temp_tensor=tensor(:,:,change(i-1):change(i)-1);
            new_tensor=cat(3,new_tensor,mean(temp_tensor,3));
        end
        temp_tensor=tensor(:,:,change(i):end);
        new_tensor=cat(3,new_tensor, mean(temp_tensor,3));
        dims_needed=9-size(new_tensor,3);
        filler=NaN(size(tensor,1),size(tensor,2),dims_needed);
        new_tensor=cat(3,new_tensor,filler);
        output=new_tensor;
    end
end
        