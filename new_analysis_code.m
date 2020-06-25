close all
home 
%% specify where the data is
if ispc
    % kirsi's computer 
    data_path='C:\Users\kirsi\Documents\Git\UROP\struct_rep\data'; 
    analysis_path=strcat(data_path,'analysis\distributed_oscilatory_power\');
    subject_id='AMC026';
    d_data= dir(strcat(data_path,'\',subject_id,'*_crunched_v3_compressed.mat')); 
    d_data=arrayfun(@(x) strcat(d_data(x).folder,'\',d_data(x).name),[1:length(d_data)]','uni',false); %change '/'
else 
    % eghbal's computer 
    data_path='~/MyData/struct_rep/crunched/';
    analysis_path=strcat(data_path,'analysis/distributed_oscilatory_power/');
    subject_id='AMC026';
    d_data= dir(strcat(data_path,'/',subject_id,'*_crunched_v3_compressed.mat')); 
    d_data=arrayfun(@(x) strcat(d_data(x).folder,'/',d_data(x).name),[1:length(d_data)]','uni',false); %change '/'
end 
%% combine responses from all sessions for a given condition. (S= sentence,....)

sent_word_tensor_all=[];
sent_probe_tensor_all=[];
wlist_word_tensor_all=[];
wlist_probe_tensor_all=[];
jab_word_tensor_all=[];
jab_probe_tensor_all=[];
non_word_tensor_all=[];
non_probe_tensor_all=[];

for k=1:length(d_data)
    subj=load(d_data{k});
    subj_id=fieldnames(subj);
    subj=subj.(subj_id{1});
    data=subj.data;
    info=subj.info;
    
    data_out_all=extract_condition_response(data,info,'S','word');
    sent_word_tensor_all=cat(3,sent_word_tensor_all,data_out_all);
    
    data_out_all=extract_condition_response(data,info,'S','probe');
    sent_probe_tensor_all=cat(3,sent_probe_tensor_all,data_out_all);

    data_out_all=extract_condition_response(data,info,'W','word');
    wlist_word_tensor_all=cat(3,wlist_word_tensor_all,data_out_all);
    
    data_out_all=extract_condition_response(data,info,'W','probe');
    wlist_probe_tensor_all=cat(3,wlist_probe_tensor_all,data_out_all);

    data_out_all=extract_condition_response(data,info,'J','word');
    jab_word_tensor_all=cat(3,jab_word_tensor_all,data_out_all);

    data_out_all=extract_condition_response(data,info,'J','probe');
    jab_probe_tensor_all=cat(3,jab_probe_tensor_all,data_out_all);

    data_out_all=extract_condition_response(data,info,'N','word');
    non_word_tensor_all=cat(3,non_word_tensor_all,data_out_all);
    
    data_out_all=extract_condition_response(data,info,'N','probe');
    non_probe_tensor_all=cat(3,non_probe_tensor_all,data_out_all);
end 
%% Sort tensors according to probe positions
%Create vector with all positions across participants for each condition
sent_positions=[];
wlist_positions=[];
jab_positions=[];
non_positions=[];

for k=1:length(d_data)
    subj=load(d_data{k});
    subj_id=fieldnames(subj);
    subj=subj.(subj_id{1});
    data=subj.data;
    info=subj.info;
    
    temp_sent_pos=get_positions(info,'S');
    sent_positions=cat(1, sent_positions, temp_sent_pos);
    
    temp_wlist_pos=get_positions(info,'W');
    wlist_positions=cat(1, wlist_positions, temp_wlist_pos);
    
    temp_jab_pos=get_positions(info,'J');
    jab_positions=cat(1, jab_positions, temp_jab_pos);
    
    temp_non_pos=get_positions(info,'N');
    non_positions=cat(1, non_positions, temp_non_pos);
end

%Sort pos vecs ascending order, sort tensors the same way
[sent_positions, index]=sort(sent_positions);
sent_word_tensor_all=sent_word_tensor_all(:,:,index);
sent_probe_tensor_all=sent_probe_tensor_all(:,:,index);

[wlist_positions, index]=sort(wlist_positions);
wlist_word_tensor_all=wlist_word_tensor_all(:,:,index);
wlist_probe_tensor_all=wlist_probe_tensor_all(:,:,index);

[jab_positions, index]=sort(jab_positions);
jab_word_tensor_all=jab_word_tensor_all(:,:,index);
jab_probe_tensor_all=jab_probe_tensor_all(:,:,index);

[non_positions, index]=sort(non_positions);
non_word_tensor_all=non_word_tensor_all(:,:,index);
non_probe_tensor_all=non_probe_tensor_all(:,:,index);

%% Take average of trials with same probe position
%find indices of sorted pos vec where pos changes
sent_changes=diff(sent_positions);
sent_change_indices=find(ismember(sent_changes,1));
sent_change_indices=sent_change_indices+1;

wlist_changes=diff(wlist_positions);
wlist_change_indices=find(ismember(wlist_changes,1));
wlist_change_indices=wlist_change_indices+1;

jab_changes=diff(jab_positions);
jab_change_indices=find(ismember(jab_changes,1));
jab_change_indices=jab_change_indices+1;

non_changes=diff(non_positions);
non_change_indices=find(ismember(non_changes,1));
non_change_indices=non_change_indices+1;

%Take average of trials at each probe position
sent_word_tensor_all=probe_pos_ave_trials(sent_change_indices, sent_word_tensor_all);
sent_probe_tensor_all=probe_pos_ave_trials(sent_change_indices, sent_probe_tensor_all); 

wlist_word_tensor_all=probe_pos_ave_trials(wlist_change_indices, wlist_word_tensor_all);
wlist_probe_tensor_all=probe_pos_ave_trials(wlist_change_indices, wlist_probe_tensor_all);    

jab_word_tensor_all=probe_pos_ave_trials(jab_change_indices, jab_word_tensor_all);
jab_probe_tensor_all=probe_pos_ave_trials(jab_change_indices, jab_probe_tensor_all); 

non_word_tensor_all=probe_pos_ave_trials(non_change_indices, non_word_tensor_all);
non_probe_tensor_all=probe_pos_ave_trials(non_change_indices, non_probe_tensor_all);
averaged=true;
% averaged=false

%% Only use valid channels
scale_matrix=repmat(info.valid_channels,1,40);
sent_word_tensor_all=sent_word_tensor_all.*scale_matrix;
scale_matrix=repmat(info.valid_channels,1,5);
sent_probe_tensor_all=sent_probe_tensor_all.*scale_matrix;

scale_matrix=repmat(info.valid_channels,1,40);
wlist_word_tensor_all=wlist_word_tensor_all.*scale_matrix;
scale_matrix=repmat(info.valid_channels,1,5);
wlist_probe_tensor_all=wlist_probe_tensor_all.*scale_matrix;

scale_matrix=repmat(info.valid_channels,1,40);
jab_word_tensor_all=jab_word_tensor_all.*scale_matrix;
scale_matrix=repmat(info.valid_channels,1,5);
jab_probe_tensor_all=jab_probe_tensor_all.*scale_matrix;

scale_matrix=repmat(info.valid_channels,1,40);
non_word_tensor_all=non_word_tensor_all.*scale_matrix;
scale_matrix=repmat(info.valid_channels,1,5);
non_probe_tensor_all=non_probe_tensor_all.*scale_matrix;

%% Rearrange tensors so all frequencies are next to each other
%Not necessary if extract_condition_response works as expected
new_order=[];
for i=1:5
    temp=i:5:35+i;
    new_order=[new_order,temp];
end

sent_word_tensor_all=sent_word_tensor_all(:,new_order,:);
wlist_word_tensor_all=wlist_word_tensor_all(:,new_order,:);
jab_word_tensor_all=jab_word_tensor_all(:,new_order,:);
non_word_tensor_all=non_word_tensor_all(:,new_order,:);


%% Separate tensors by frequency
sent_word_freq_tensors_all=separate_frequencies(sent_word_tensor_all, 'word');
sent_probe_freq_tensors_all=separate_frequencies(sent_probe_tensor_all, 'prob');

wlist_word_freq_tensors_all=separate_frequencies(wlist_word_tensor_all, 'word');
wlist_probe_freq_tensors_all=separate_frequencies(wlist_probe_tensor_all, 'prob');

jab_word_freq_tensors_all=separate_frequencies(jab_word_tensor_all, 'word');
jab_probe_freq_tensors_all=separate_frequencies(jab_probe_tensor_all, 'prob');

non_word_freq_tensors_all=separate_frequencies(non_word_tensor_all, 'word');
non_probe_freq_tensors_all=separate_frequencies(non_probe_tensor_all, 'prob');

%% compute a cosine distance over all electrodes to compare word & probe conditions
%sentence condition
sentence_angles_all={};
for i=1:length(sent_word_freq_tensors_all)
    word_tensor=sent_word_freq_tensors_all{i,1};
    probe_tensor=sent_probe_freq_tensors_all{i,1};
    sentence_angles_all{i,1}=calc_similarities(word_tensor,probe_tensor);
end

sentence_angles_mat=[];
for j=1:length(sentence_angles_all)
    temp=cell2mat(transpose(sentence_angles_all{j,1}));
    sentence_angles_mat=cat(1,sentence_angles_mat,temp);
end

%wordlist condition
wlist_angles_all={};
for i=1:length(wlist_word_freq_tensors_all)
    word_tensor=wlist_word_freq_tensors_all{i,1};
    probe_tensor=wlist_probe_freq_tensors_all{i,1};
    wlist_angles_all{i,1}=calc_similarities(word_tensor,probe_tensor);
end

wlist_angles_mat=[];
for j=1:length(wlist_angles_all)
    temp=cell2mat(transpose(wlist_angles_all{j,1}));
    wlist_angles_mat=cat(1,wlist_angles_mat,temp);
end

%jabber condition
jab_angles_all={};
for i=1:length(jab_word_freq_tensors_all)
    word_tensor=jab_word_freq_tensors_all{i,1};
    probe_tensor=jab_probe_freq_tensors_all{i,1};
    jab_angles_all{i,1}=calc_similarities(word_tensor,probe_tensor);
end

jab_angles_mat=[];
for j=1:length(jab_angles_all)
    temp=cell2mat(transpose(jab_angles_all{j,1}));
    jab_angles_mat=cat(1,jab_angles_mat,temp);
end

%nonword condition
non_angles_all={};
for i=1:length(non_word_freq_tensors_all)
    word_tensor=non_word_freq_tensors_all{i,1};
    probe_tensor=non_probe_freq_tensors_all{i,1};
    non_angles_all{i,1}=calc_similarities(word_tensor,probe_tensor);
end

non_angles_mat=[];
for j=1:length(non_angles_all)
    temp=cell2mat(transpose(non_angles_all{j,1}));
    non_angles_mat=cat(1,non_angles_mat,temp);
end

%% Rearrange angle matrices so same probe pos for all freqs are together 
%sentence
len=length(sentence_angles_mat);
new_order=[];
for i=1:len/5
    temp=i:len/5:len-(len/5)+i;
    new_order=[new_order,temp];
end
sentence_angles_mat=sentence_angles_mat(new_order,:);

%worlist
len=length(wlist_angles_mat);
new_order=[];
for i=1:len/5
    temp=i:len/5:len-(len/5)+i;
    new_order=[new_order,temp];
end
wlist_angles_mat=wlist_angles_mat(new_order,:);

%jabber
len=length(jab_angles_mat);
new_order=[];
for i=1:len/5
    temp=i:len/5:len-(len/5)+i;
    new_order=[new_order,temp];
end
jab_angles_mat=jab_angles_mat(new_order,:);

%nonword
len=length(non_angles_mat);
new_order=[];
for i=1:len/5
    temp=i:len/5:len-(len/5)+i;
    new_order=[new_order,temp];
end
non_angles_mat=non_angles_mat(new_order,:);
sorted_freqs=true;
% sorted_freqs=false;

%% figure with 4 condtions on it
strings=['S','W','J','N'];
mats={sentence_angles_mat, wlist_angles_mat, jab_angles_mat, non_angles_mat};
figure;
for i=1:4
    subplot(2,2,i);
    imagesc(mats{1,i});
    colorbar();
    title(strcat('angle b/w ',strings(i),' & probe'));
    if ~sorted_freqs
        ylabel('trials-lines at new freqs')
        len=length(mats{1,i});
        for y=1:len/5:len
            yline(y);
        end
    elseif sorted_freqs & averaged
        ylabel('trials-line at new probe pos')
        for y=1:5:length(mats{1,i})
            yline(y);
        end
    end
end


%% Generate figures for separate frequencies
% for i=1:5
%     figure;
%     subplot(2,2,1);
%     imagesc(cell2mat(transpose(sentence_angles_all{i,1})));
%     colorbar();
%     title('angle b/w S & probe');
%     subplot(2,2,2);
%     imagesc(cell2mat(transpose(wlist_angles_all{i,1})));
%     colorbar();
%     title('angle b/w W and probe');
%     subplot(2,2,3);
%     imagesc(cell2mat(transpose(jab_angles_all{i,1})));
%     colorbar();
%     title('angle b/w J and probe');
%     subplot(2,2,4);
%     imagesc(cell2mat(transpose(non_angles_all{i,1})));
%     colorbar();
%     title('angle b/w N and probe');
% end
