%% Calculate angles with new window tensors. Use with new_time_windows function.

function output=angle_new_windows(word,probe)
%% Part 1 -> Use to create 9x8 figure, each part is a subplot of probe_win x word_win angles

    %% Find probe norms
    probe_norm=cell(1,size(probe,3));
    for i=1:size(probe,3)
        temp_tensor=probe(:,:,i); %each probe sheet -> num_elecs x num_probe_wins
        new_tensor=[]; %remove any NaN values before calculation
        for j=1:size(temp_tensor,1)
            if ~isnan(temp_tensor(j,:))
                new_tensor=cat(1,new_tensor,temp_tensor(j,:));
            end
        end
        new_norm_probe=diag(sqrt(transpose(new_tensor)*new_tensor)); % num_probe_wins x1 array of probe norms
        probe_norm{1,i}=new_norm_probe; % Each cell contains array of probe norms for one probe position
    end

    %% Word Norms
    word_norm=cell(1,size(word,3));
    for i=1:size(word,3)
        temp_tensor=word(:,:,i); %each probe sheet -> num_elecs x num_probe_wins
        new_tensor=[]; %remove any NaN values before calculation
        for j=1:size(temp_tensor,1)
            if ~isnan(temp_tensor(j,:))
                new_tensor=cat(1,new_tensor,temp_tensor(j,:));
            end
        end
        new_norm_word=diag(sqrt(transpose(new_tensor)*new_tensor)); % num_probe_wins x1 array of probe norms
        word_norm{1,i}=new_norm_word; % Each cell contains array of probe norms for one probe position
    end
    
    %% Calculate product of corresponding word & probe norms
    %Word & probe might not have same window size -> For each position &
    %word stim you will get array of probe_wins x word_wins norm
    %products
    
    norm_prods=cell(1,size(word,3));
    for i=1:size(word,3) %For each position
        temp=probe_norm{1,i}*transpose(word_norm{1,i}); %probe_wins x 1 * 1 x word_wins
        norm_prods{1,i}=temp;
    end
    
    %% Calculate dot prods of corresponding word & probe window tensors
    % For each position take num_probe_wins x num_elec & num_elec x
    % num_word_wins, then calculate dot prod of these for each word stim
    % Left with num_probe_wins x num_word_wins for each position & word
    % stim (same as norm products)
    
    dot_prods=cell(1,size(word,3));
    for i=1:size(word,3) %for each position
        temp_word=word(:,:,i);
        new_word=[];
        for j=1:size(temp_word,1) %remove NaN from each row
            if ~isnan(temp_word(j,:))
                new_word=cat(1,new_word,temp_word(j,:));
            end 
        end
        temp_probe=probe(:,:,i); %Same probe page to each word stim page -> num_elec x num_probe_stim
        new_probe=[];
        for j=1:size(temp_probe,1)
            if ~isnan(temp_probe(j,:))
                new_probe=cat(1,new_probe,temp_probe(j,:));
            end 
        end
        temp=transpose(new_probe)*new_word; %num_probe x num_elec * num_elec x num_word
        dot_prods{1,i}=temp; %num_probe x num_word dot prod mats for each stim for each position
    end
    
    %% Divide dot prods by corresponding norm prods for angles
    angles=cell(1,size(word,3));
    for i=1:size(word,3) %for each position
        angs=dot_prods{1,i}./norm_prods{1,i};
        angles{1,i}=angs;
    end
    
    output=angles;
end