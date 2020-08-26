%%Calculate similarity angles given a word and probe tensor

function angle=calc_similarities(word_tensor,probe_tensor)
    %% Norms for each probe vector in tensor
    probe_norm=cell(1,size(probe_tensor,3));
    for i=1:size(probe_tensor,3)
        temp_tensor=probe_tensor(:,:,i); %one vec from tensor -> num elecs x 1 probe activation values
        new_tensor=[];
        for j=1:size(temp_tensor,1) %Remove nan values from vec before calculation
            if ~isnan(temp_tensor(j,:))
                new_tensor=cat(1,new_tensor,temp_tensor(j,:));
            end
        end   
        new_norm=sqrt(transpose(new_tensor)*new_tensor); %Calc norm of vec & add to probe norm cell
        probe_norm{1,i}=new_norm;
    end
    
    %% Norms for each word vec in tensor
    words_norm=cell(1,size(word_tensor,3));
    for i=1:size(word_tensor,3)
        temp_tensor=word_tensor(:,:,i); %one page from tensor -> num elecs x 8 word activation values
        new_tensor=[];
        for j=1:size(temp_tensor,1) %Remove NaN before calculating
            if ~isnan(temp_tensor(j,:))
                new_tensor=cat(1,new_tensor,temp_tensor(j,:));
            end
        end   
        new_norm=diag(sqrt(transpose(new_tensor)*new_tensor)); %Diag -> only compare same word vecs (8x1)
        words_norm{1,i}=new_norm;
    end
    
    %% Product of corresponding word and probe norms
    norm_product=cellfun(@(x,y) transpose(x.*y) ,probe_norm,words_norm,'uni',false);  
    
    %% Dot products of corresponding word & probe vecs
    w_probe_dot=cell(1,size(word_tensor,3));
    for i=1:size(word_tensor,3)
        temp_word=word_tensor(:,:,i); %Word page num elecs x 8
        temp_probe=probe_tensor(:,:,i); %Probe vec num elecs x 1
        new_word=[];
        new_probe=[];
        for j=1:size(word_tensor,1) %Remove NaN from word page & probe vec
            if ~isnan(temp_word(j,:))
                new_word=cat(1,new_word,temp_word(j,:));
                new_probe=cat(1,new_probe,temp_probe(j,:));
            end
        end
        new_dot=transpose(new_probe)*new_word;
        w_probe_dot{1,i}=new_dot; %Each dim 3 tensor index has 8x1 dot prods
    end
    
    %% Cosine angle -> Dot prod / corresponding norm prod
    w_probe_angle=cellfun(@(x,y) x./y,w_probe_dot,norm_product,'uni',false);
    angle=w_probe_angle;
end