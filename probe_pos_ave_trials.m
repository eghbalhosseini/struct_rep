%%Separate tensor at change indices, take averages, put back together
function output=probe_pos_ave_trials(change, tensor)
    if isempty(change)
        output=mean(tensor,3);
    elseif length(change)==1
        temp_tensor=tensor(:,:,1:change(1)-1);
        ave=mean(temp_tensor,3);
        tensor_averaged=ave;
        temp_tensor=tensor(:,:,change(1):end);
        ave=mean(temp_tensor,3);
        tensor_averaged=cat(3,tensor_averaged,ave);
        output=tensor_averaged;
    else
        temp_tensor=tensor(:,:,1:change(1)-1);
        ave=mean(temp_tensor,3);
        tensor_averaged=ave;
        for i=2:length(change)
            temp_tensor=tensor(:,:,change(i-1):change(i)-1);
            ave=mean(temp_tensor,3);
            tensor_averaged=cat(3, tensor_averaged, ave);
        end
        temp_tensor=tensor(:,:,change(i):end);
        ave=mean(temp_tensor,3);
        tensor_averaged=cat(3,tensor_averaged, ave);
        output=tensor_averaged;
    end
end
        