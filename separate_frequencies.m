function output=separate_frequencies(tensor, trial_type)
    if trial_type=='word'
        indices=[8,16,24,32,40];
    else
        indices=[1,2,3,4,5];
    end
    new_tensors={};
    new_tensors{1,1}=tensor(:,1:indices(1),:);
    for i=2:length(indices)
        temp_tensor=tensor(:,indices(i-1)+1:indices(i),:);
        new_tensors{i,1}=temp_tensor;
    end
    output=new_tensors;
end
            
        