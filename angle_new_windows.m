function output=angle_new_windows(word,probe)
    probe_norm=cell(1,size(probe,3));
    for i=1:size(probe,3)
        temp_tensor=probe(:,:,i);
        new_tensor=[];
        for j=1:size(temp_tensor,1)
            if ~isnan(temp_tensor(j,:))
                new_tensor=cat(1,new_tensor,temp_tensor(j,:));
            end
        end
        new_norm_probe=diag(sqrt(transpose(new_tensor)*new_tensor));
        probe_norm{1,i}=new_norm_probe;
    end

    word_norm=cell(1,size(word,3));
    for i=1:size(word,3)
        temp_norms=cell(8,1);
        for j=1:8
            temp_tensor=word(:,1+5*(j-1):5*j,i);
            new_tensor=[];
            for h=1:size(temp_tensor,1)
                if ~isnan(temp_tensor(j,:))
                    new_tensor=cat(1,new_tensor,temp_tensor(j,:));
                end 
            end
            new_norm_word=diag(sqrt(transpose(new_tensor)*new_tensor));
            temp_norms{j,1}=new_norm_word;
        end
        word_norm{1,i}=temp_norms;
    end

    norm_prods=cell(1,size(word,3));
    for i=1:size(word,3)
        temp_prods=cell(8,1);
        for j=1:8
            temp=probe_norm{1,i}*transpose(word_norm{1,i}{j,1});
            temp_prods{j,1}=temp;
        end
        norm_prods{1,i}=temp_prods;
    end

    dot_prods=cell(1,size(word,3));
    for i=1:size(word,3)
        temp_dots=cell(8,1);
        for j=1:8
            temp_word=word(:,1+5*(j-1):5*j,i);
            new_word=[];
            for h=1:size(temp_word,1)
                if ~isnan(temp_word(j,:))
                    new_word=cat(1,new_word,temp_word(j,:));
                end 
            end
            temp_probe=probe(:,:,i);
            new_probe=[];
            for h=1:size(temp_probe,1)
                if ~isnan(temp_probe(j,:))
                    new_probe=cat(1,new_probe,temp_probe(j,:));
                end 
            end
            temp=transpose(new_probe)*new_word;
            temp_dots{j,1}=temp;
        end
        dot_prods{1,i}=temp_dots;
    end

    angles=cell(1,size(word,3));
    for i=1:size(word,3)
        temp_angs=cell(8,1);
        for j=1:8
            temp=dot_prods{1,i}{j,1}./norm_prods{1,i}{j,1};
            temp_angs{j,1}=temp;
        end
        angles{1,i}=temp_angs;
    end
    output=angles;
end