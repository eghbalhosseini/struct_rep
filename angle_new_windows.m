function output=angle_new_windows(word,probe)
    probe_norm=cell(1,size(probe,3)); %Initialize 1x9 cell
    for i=1:size(probe,3)
        temp_tensor=probe(:,:,i); %each probe sheet -> 5*elecs x num_probe_wins
        new_tensor=[]; %remove any NaN values before calculation
        for j=1:size(temp_tensor,1)
            if ~isnan(temp_tensor(j,:))
                new_tensor=cat(1,new_tensor,temp_tensor(j,:));
            end
        end
        new_norm_probe=diag(sqrt(transpose(new_tensor)*new_tensor)); % num_probe_wins x1 array of probe norms for i sheet
        probe_norm{1,i}=new_norm_probe; % 1x9 cell -> each cell contains one array of probe norms
    end

    word_norm=cell(1,size(word,3)); %Initialize 1x9 cell
    for i=1:size(word,3)
        temp_norms=cell(8,1); %Init cell to dump norms for each word stim in i sheet
        for j=1:8 %for each sheet, take each chunk representing one word stim to compare to probe
            temp_tensor=word(:,1+(size(word,2)/8)*(j-1):(size(word,2)/8)*j,i);
            new_tensor=[]; %remove NaN values before calculating
            for h=1:size(temp_tensor,1)
                if ~isnan(temp_tensor(h,:))
                    new_tensor=cat(1,new_tensor,temp_tensor(h,:));
                end 
            end
            new_norm_word=diag(sqrt(transpose(new_tensor)*new_tensor)); %num_word_wins x1 array of word norms
            temp_norms{j,1}=new_norm_word; %8x1 cell, each cell has word norms array
        end
        word_norm{1,i}=temp_norms; %9x1 cell, each cell is 8x1 cell, each cell has word norm arrays
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
            temp_word=word(:,1+(size(word,2)/8)*(j-1):(size(word,2)/8)*j,i);
            new_word=[];
            for h=1:size(temp_word,1)
                if ~isnan(temp_word(h,:))
                    new_word=cat(1,new_word,temp_word(h,:));
                end 
            end
            temp_probe=probe(:,:,i);
            new_probe=[];
            for h=1:size(temp_probe,1)
                if ~isnan(temp_probe(h,:))
                    new_probe=cat(1,new_probe,temp_probe(h,:));
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