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

    %% Find word norms
    word_norm=cell(1,size(word,3));
    for i=1:size(word,3)
        temp_norms=cell(8,1); %Init cell to dump norms for each word stim in i sheet
        for j=1:8 %for each sheet, take each word stim chunk (num elecs x num windows)
            temp_tensor=word(:,1+(size(word,2)/8)*(j-1):(size(word,2)/8)*j,i);
            new_tensor=[]; %remove NaN values before calculating
            for h=1:size(temp_tensor,1)
                if ~isnan(temp_tensor(h,:))
                    new_tensor=cat(1,new_tensor,temp_tensor(h,:));
                end 
            end
            new_norm_word=diag(sqrt(transpose(new_tensor)*new_tensor));
            temp_norms{j,1}=new_norm_word; %8x1 -> Each cell has num_word_wins norms for one word stim
        end
        word_norm{1,i}=temp_norms; %9x1 -> Each cell has 8x1 cell of num_word_wins norms for one position
    end

    %% Calculate product of corresponding word & probe norms
    %Word & probe might not have same window size -> For each position &
    %word stim you will get array of probe_wins x word_wins norm
    %products
    
    norm_prods=cell(1,size(word,3));
    for i=1:size(word,3) %For each position
        temp_prods=cell(8,1);
        for j=1:8 %For each word stim
            temp=probe_norm{1,i}*transpose(word_norm{1,i}{j,1}); %probe_wins x 1 * 1 x word_wins
            temp_prods{j,1}=temp; 
        end
        norm_prods{1,i}=temp_prods;
    end
    
    %% Calculate dot prods of corresponding word & probe window tensors
    % For each position take num_probe_wins x num_elec & num_elec x
    % num_word_wins, then calculate dot prod of these for each word stim
    % Left with num_probe_wins x num_word_wins for each position & word
    % stim (same as norm products)
    
    dot_prods=cell(1,size(word,3));
    for i=1:size(word,3) %for each position
        temp_dots=cell(8,1);
        for j=1:8 %for each word stim -> num_elec x num_word_stim
            temp_word=word(:,1+(size(word,2)/8)*(j-1):(size(word,2)/8)*j,i);
            new_word=[];
            for h=1:size(temp_word,1) %remove NaN from each row
                if ~isnan(temp_word(h,:))
                    new_word=cat(1,new_word,temp_word(h,:));
                end 
            end
            temp_probe=probe(:,:,i); %Same probe page to each word stim page -> num_elec x num_probe_stim
            new_probe=[];
            for h=1:size(temp_probe,1)
                if ~isnan(temp_probe(h,:))
                    new_probe=cat(1,new_probe,temp_probe(h,:));
                end 
            end
            temp=transpose(new_probe)*new_word; %num_probe x num_elec * num_elec x num_word
            temp_dots{j,1}=temp;
        end
        dot_prods{1,i}=temp_dots; %num_probe x num_word dot prod mats for each stim for each position
    end
    
    %% Divide dot prods by corresponding norm prods for angles
    angles=cell(1,size(word,3));
    for i=1:size(word,3) %for each position
        temp_angs=cell(8,1); %for each stim
        for j=1:8
            temp=dot_prods{1,i}{j,1}./norm_prods{1,i}{j,1};
            temp_angs{j,1}=temp;
        end
        angles{1,i}=temp_angs;
    end
%% Part 2 -> Use along with part 1 to create num_probe x num_word fig, each part is all the angles corresponding to that position in part 1
%Comment out this section if you want figure specified in part 1
    
    %% Make angle matrices with same word vs probe combo from each condition
    if length(angles{1,i}{1,1})==2
        first_probe_first_word=cell(1,length(angles));
        first_probe_last_word=cell(1,length(angles));
        last_probe_first_word=cell(1,length(angles));
        last_probe_last_word=cell(1,length(angles));

        for i=1:length(angles)
            temp_f_f=zeros(length(angles{1,i}),1);
            temp_f_l=zeros(length(angles{1,i}),1);
            temp_l_f=zeros(length(angles{1,i}),1);
            temp_l_l=zeros(length(angles{1,i}),1);
            for j=1:length(angles{1,i})
                temp_f_f(j,1)=angles{1,i}{j,1}(1,1);
                temp_f_l(j,1)=angles{1,i}{j,1}(1,2);
                temp_l_f(j,1)=angles{1,i}{j,1}(2,1);
                temp_l_l(j,1)=angles{1,i}{j,1}(2,2);
            end
            first_probe_first_word{1,i}=temp_f_f;
            first_probe_last_word{1,i}=temp_f_l;
            last_probe_first_word{1,i}=temp_l_f;
            last_probe_last_word{1,i}=temp_l_l;
        end
    end
        
    if length(angles{1,i}{1,1})==2
        output=cell(1,4);
        output{1,1}=first_probe_first_word;
        output{1,2}=first_probe_last_word;
        output{1,3}=last_probe_first_word;
        output{1,4}=last_probe_last_word;
    else
        output=angles;
    end
end