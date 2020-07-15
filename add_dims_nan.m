function output=add_dims_nan(tensor)
    if size(tensor,3)<9
        dims_needed=9-size(tensor,3);
        filler=NaN(size(tensor,1),size(tensor,2),dims_needed);
        new_tensor=cat(3,tensor,filler);
        output=new_tensor;
    else
        output=tensor;
    end
end