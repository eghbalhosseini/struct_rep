data=AMC037_ECOGS001R09.data;
info=AMC037_ECOGS001R09.info;

sent_window_word_tens=[];
wlist_window_word_tens=[];

sent_window_probe_tens=[];
wlist_window_probe_tens=[];

for j=1:length(data);

    stim_data=data{j,1}.signal_gaus_band_hilb_dec_zs_parsed_win;
    new_combined=cell(size(new_stim,1),1);
    for i=1:size(stim_data,1)
        temp=stim_data(i,:);
        temp=cell2mat(transpose(temp));
        new_combined{i,1}=temp;
    end
    data{j,1}.combined_win=new_combined;   
end

data_sent_word=extract_condition_response(data,info,'S','word',true,true);
sent_window_word_tens=cat(3,sent_window_word_tens,data_sent_word);

data_wlist_word=extract_condition_response(data,info,'W','word',true,true);
wlist_window_word_tens=cat(3,wlist_window_word_tens,data_wlist_word);

data_sent_probe=extract_condition_response(data,info,'S','probe',true,true);
sent_window_probe_tens=cat(3,sent_window_probe_tens,data_sent_probe);

data_wlist_probe=extract_condition_response(data,info,'W','probe',true,true);
wlist_window_probe_tens=cat(3,wlist_window_probe_tens,data_wlist_probe);

%% Next section
probe_norm=cell(1,size(sent_window_probe_tens,3));
for i=1:size(sent_window_probe_tens,3)
    new_norm_probe=diag(sqrt(transpose(sent_window_probe_tens(:,:,i))*sent_window_probe_tens(:,:,i)));
    probe_norm{1,i}=new_norm_probe;
end

word_norm=cell(1,size(sent_window_word_tens,3));
for i=1:size(sent_window_word_tens,3)
    temp_norms=cell(8,1);
    for j=1:8
        temp=sent_window_word_tens(:,1+5*(j-1):5*j,i);
        new_norm_word=diag(sqrt(transpose(temp)*temp));
        temp_norms{j,1}=new_norm_word;
    end
    word_norm{1,i}=temp_norms;
end

norm_prods=cell(1,size(sent_window_word_tens,3));
for i=1:size(sent_window_word_tens,3)
    temp_prods=cell(8,1);
    for j=1:8
        temp=probe_norm{1,i}*transpose(word_norm{1,i}{j,1});
        temp_prods{j,1}=temp;
    end
    norm_prods{1,i}=temp_prods;
end

dot_prods=cell(1,size(sent_window_word_tens,3));
for i=1:size(sent_window_word_tens,3)
    temp_dots=cell(8,1);
    for j=1:8
        word_tens=sent_window_word_tens(:,1+5*(j-1):5*j,i);
        probe_tens=sent_window_probe_tens(:,:,i);
        temp=transpose(probe_tens)*word_tens;
        temp_dots{j,1}=temp;
    end
    dot_prods{1,i}=temp_dots;
end

angles=cell(1,size(sent_window_word_tens,3));
for i=1:size(sent_window_word_tens,3)
    temp_angs=cell(8,1);
    for j=1:8
        temp=dot_prods{1,i}{j,1}./norm_prods{1,i}{j,1};
        temp_angs{j,1}=temp;
    end
    angles{1,i}=temp_angs;
end

%% Next section
figure;
for i=1:length(angles)
    for j=1:length(angles{1,i})
        subplot(length(angles),length(angles{1,i}),j*i+(7-(j-1))*(i-1));
        imagesc(angles{1,i}{j,1});
    end
end

    
    