function angle=calc_similarities(word_tensor,probe_tensor)
    probe_norm=cell(1,size(probe_tensor,3));
    for i=1:size(probe_tensor,3)
        temp_tensor=probe_tensor(:,:,i);
        new_tensor=[];
        for j=1:size(temp_tensor,1)
            if ~isnan(temp_tensor(j,:))
                new_tensor=cat(1,new_tensor,temp_tensor(j,:));
            end
        end   
        new_norm=sqrt(transpose(new_tensor)*new_tensor);
        probe_norm{1,i}=new_norm;
    end
    words_norm=cell(1,size(word_tensor,3));
    for i=1:size(word_tensor,3)
        temp_tensor=word_tensor(:,:,i);
        new_tensor=[];
        for j=1:size(temp_tensor,1)
            if ~isnan(temp_tensor(j,:))
                new_tensor=cat(1,new_tensor,temp_tensor(j,:));
            end
        end   
        new_norm=diag(sqrt(transpose(new_tensor)*new_tensor));
        words_norm{1,i}=new_norm;
    end
    norm_product=cellfun(@(x,y) transpose(x.*y) ,probe_norm,words_norm,'uni',false);    
    w_probe_dot=cell(1,size(word_tensor,3));
    for i=1:size(word_tensor,3)
        temp_word=word_tensor(:,:,i);
        temp_probe=probe_tensor(:,:,i);
        new_word=[];
        new_probe=[];
        for j=1:size(word_tensor,1)
            if ~isnan(temp_word(j,:))
                new_word=cat(1,new_word,temp_word(j,:));
                new_probe=cat(1,new_probe,temp_probe(j,:));
            end
        end
        new_dot=transpose(new_probe)*new_word;
        w_probe_dot{1,i}=new_dot;
    end
    w_probe_angle=cellfun(@(x,y) x./y,w_probe_dot,norm_product,'uni',false);
    angle=w_probe_angle;
end