data=AMC037_ECOGS001R09.data;
info=AMC037_ECOGS001R09.info;

sent_window_word_tens=[];
wlist_window_word_tens=[];

sent_window_probe_tens=[];
wlist_window_probe_tens=[];

for j=1:length(data)
    pretrial_data=data{j,1}.signal_pre_trial_gaus_band_hilb_dec_zs;
    new_pret=cellfun(@(y) cell2mat(cellfun(@(x) mean(x,2), mat2cell(y,[size(y,1)],ones(1,5)*size(y,2)/5), 'uni', false)),pretrial_data,'uni',false);
    data{j,1}.new_window_pretrial_comb=new_pret;

    stim_data=data{j,1}.signal_gaus_band_hilb_dec_zs_parsed;
    new_stim=cellfun(@(y) cell2mat(cellfun(@(x) mean(x,2), mat2cell(y,[size(y,1)],ones(1,5)*size(y,2)/5), 'uni', false)),stim_data,'uni',false);
    new_combined=cell(size(new_stim,1),1);
    for i=1:size(new_stim,1)
        temp=new_stim(i,:);
        temp=cell2mat(transpose(temp));
        new_combined{i,1}=temp;
    end
    data{j,1}.new_window_comb=new_combined;   
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

for i=1:length(angles)
    blah=figure;
    for j=1:length(angles{1,i})
        subplot(2,4,j);
        imagesc(angles{1,i}{j,1});
        colorbar();
    end
end
    
    