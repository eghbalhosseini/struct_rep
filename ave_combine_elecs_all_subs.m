close all
home 
data_path='C:\Users\kirsi\Documents\data\ave_window_time'; 
subject_id={'AMC026','AMC029','AMC031','AMC037','AMC038','AMC044'};
combine_elecs_all_sent_word=[];
combine_elecs_all_wlist_word=[];
combine_elecs_all_jab_word=[];
combine_elecs_all_non_word=[];

combine_elecs_all_sent_probe=[];
combine_elecs_all_wlist_probe=[];
combine_elecs_all_jab_probe=[];
combine_elecs_all_non_probe=[];

for m=1:length(subject_id)
    d_data= dir(strcat(data_path,'\',subject_id{1,m},'*_crunched_v3_compressed.mat')); 
    d_data=arrayfun(@(x) strcat(d_data(x).folder,'\',d_data(x).name),[1:length(d_data)]','uni',false);
    fprintf('%d .mat files found',length(d_data))
    sent_word_combined_elecs=[];
    sent_probe_combined_elecs=[];
    wlist_word_combined_elecs=[];
    wlist_probe_combined_elecs=[];
    jab_word_combined_elecs=[];
    jab_probe_combined_elecs=[];
    non_word_combined_elecs=[];
    non_probe_combined_elecs=[];

    for k=1:length(d_data)
        subj=load(d_data{k});
        subj_id=fieldnames(subj);
        subj=subj.(subj_id{1});
        data=subj.data;
        info=subj.info;

        data_out_all=extract_condition_response(data,info,'S','word',false,false);
        sent_word_combined_elecs=cat(3,sent_word_combined_elecs,data_out_all);

        data_out_all=extract_condition_response(data,info,'S','pretrial',false,false);
        sent_probe_combined_elecs=cat(3,sent_probe_combined_elecs,data_out_all);

        data_out_all=extract_condition_response(data,info,'W','word',false,false);
        wlist_word_combined_elecs=cat(3,wlist_word_combined_elecs,data_out_all);

        data_out_all=extract_condition_response(data,info,'W','pretrial',false,false);
        wlist_probe_combined_elecs=cat(3,wlist_probe_combined_elecs,data_out_all);

        data_out_all=extract_condition_response(data,info,'J','word',false,false);
        jab_word_combined_elecs=cat(3,jab_word_combined_elecs,data_out_all);

        data_out_all=extract_condition_response(data,info,'J','pretrial',false,false);
        jab_probe_combined_elecs=cat(3,jab_probe_combined_elecs,data_out_all);

        data_out_all=extract_condition_response(data,info,'N','word',false,false);
        non_word_combined_elecs=cat(3,non_word_combined_elecs,data_out_all);

        data_out_all=extract_condition_response(data,info,'N','pretrial',false,false);
        non_probe_combined_elecs=cat(3,non_probe_combined_elecs,data_out_all);
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

        temp_sent_pos=get_positions(info,data,'S',false);
        sent_positions=cat(1, sent_positions, temp_sent_pos);

        temp_wlist_pos=get_positions(info,data,'W',false);
        wlist_positions=cat(1, wlist_positions, temp_wlist_pos);

        temp_jab_pos=get_positions(info,data,'J',false);
        jab_positions=cat(1, jab_positions, temp_jab_pos);

        temp_non_pos=get_positions(info,data,'N',false);
        non_positions=cat(1, non_positions, temp_non_pos);
    end

    %Sort pos vecs ascending order, sort tensors the same way
    [sent_positions, index]=sort(sent_positions);
    sent_word_combined_elecs=sent_word_combined_elecs(:,:,index);
    sent_probe_combined_elecs=sent_probe_combined_elecs(:,:,index);

    [wlist_positions, index]=sort(wlist_positions);
    wlist_word_combined_elecs=wlist_word_combined_elecs(:,:,index);
    wlist_probe_combined_elecs=wlist_probe_combined_elecs(:,:,index);

    [jab_positions, index]=sort(jab_positions);
    jab_word_combined_elecs=jab_word_combined_elecs(:,:,index);
    jab_probe_combined_elecs=jab_probe_combined_elecs(:,:,index);

    [non_positions, index]=sort(non_positions);
    non_word_combined_elecs=non_word_combined_elecs(:,:,index);
    non_probe_combined_elecs=non_probe_combined_elecs(:,:,index);
    
    %% Average trials at each probe position
    % Find indices where probe position changes
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
    sent_word_combined_elecs=probe_pos_ave_trials(sent_change_indices, sent_word_combined_elecs);
    sent_probe_combined_elecs=probe_pos_ave_trials(sent_change_indices, sent_probe_combined_elecs); 

    wlist_word_combined_elecs=probe_pos_ave_trials(wlist_change_indices, wlist_word_combined_elecs);
    wlist_probe_combined_elecs=probe_pos_ave_trials(wlist_change_indices, wlist_probe_combined_elecs);    

    jab_word_combined_elecs=probe_pos_ave_trials(jab_change_indices, jab_word_combined_elecs);
    jab_probe_combined_elecs=probe_pos_ave_trials(jab_change_indices, jab_probe_combined_elecs); 

    non_word_combined_elecs=probe_pos_ave_trials(non_change_indices, non_word_combined_elecs);
    non_probe_combined_elecs=probe_pos_ave_trials(non_change_indices, non_probe_combined_elecs);
    
    %% Only use valid channels
    sent_word_combined_elecs=sent_word_combined_elecs.*repmat(info.valid_channels,1,8);
    wlist_word_combined_elecs=wlist_word_combined_elecs.*repmat(info.valid_channels,1,8);
    jab_word_combined_elecs=jab_word_combined_elecs.*repmat(info.valid_channels,1,8);
    non_word_combined_elecs=non_word_combined_elecs.*repmat(info.valid_channels,1,8);

    sent_probe_combined_elecs=sent_probe_combined_elecs.*info.valid_channels;
    wlist_probe_combined_elecs=wlist_probe_combined_elecs.*info.valid_channels;
    jab_probe_combined_elecs=jab_probe_combined_elecs.*info.valid_channels;
    non_probe_combined_elecs=non_probe_combined_elecs.*info.valid_channels;
    
%     %% Only use lang responsive channels
%     sent_word_combined_elecs=sent_word_combined_elecs.*repmat(info.sig_and_pos_chans_combine_elecs,1,8);
%     wlist_word_combined_elecs=wlist_word_combined_elecs.*repmat(info.sig_and_pos_chans_combine_elecs,1,8);
%     jab_word_combined_elecs=jab_word_combined_elecs.*repmat(info.sig_and_pos_chans_combine_elecs,1,8);
%     non_word_combined_elecs=non_word_combined_elecs.*repmat(info.sig_and_pos_chans_combine_elecs,1,8);
%     
%     sent_probe_combined_elecs=sent_probe_combined_elecs.*info.sig_and_pos_chans_combine_elecs;
%     wlist_probe_combined_elecs=wlist_probe_combined_elecs.*info.sig_and_pos_chans_combine_elecs;
%     jab_probe_combined_elecs=jab_probe_combined_elecs.*info.sig_and_pos_chans_combine_elecs;
%     non_probe_combined_elecs=non_probe_combined_elecs.*info.sig_and_pos_chans_combine_elecs;

    %% Make sure tensors are proper dimension
    sent_word_combined_elecs=add_dims_nan(sent_word_combined_elecs);
    wlist_word_combined_elecs=add_dims_nan(wlist_word_combined_elecs);
    jab_word_combined_elecs=add_dims_nan(jab_word_combined_elecs);
    non_word_combined_elecs=add_dims_nan(non_word_combined_elecs);
    
    sent_probe_combined_elecs=add_dims_nan(sent_probe_combined_elecs);
    wlist_probe_combined_elecs=add_dims_nan(wlist_probe_combined_elecs);
    jab_probe_combined_elecs=add_dims_nan(jab_probe_combined_elecs);
    non_probe_combined_elecs=add_dims_nan(non_probe_combined_elecs);
    
    %% Combine averaged tensors from all subjects along dim1
    combine_elecs_all_sent_word=cat(1,combine_elecs_all_sent_word, sent_word_combined_elecs);
    combine_elecs_all_wlist_word=cat(1,combine_elecs_all_wlist_word, wlist_word_combined_elecs);
    combine_elecs_all_jab_word=cat(1,combine_elecs_all_jab_word, jab_word_combined_elecs);
    combine_elecs_all_non_word=cat(1,combine_elecs_all_non_word, non_word_combined_elecs);
    
    combine_elecs_all_sent_probe=cat(1,combine_elecs_all_sent_probe, sent_probe_combined_elecs);
    combine_elecs_all_wlist_probe=cat(1,combine_elecs_all_wlist_probe, wlist_probe_combined_elecs);
    combine_elecs_all_jab_probe=cat(1,combine_elecs_all_jab_probe, jab_probe_combined_elecs);
    combine_elecs_all_non_probe=cat(1,combine_elecs_all_non_probe, non_probe_combined_elecs);
end

%% Compute cosine distance
%sentence
word_tensor=combine_elecs_all_sent_word;
probe_tensor=combine_elecs_all_sent_probe;
sent_angles=calc_similarities(word_tensor,probe_tensor);

%wordlist
word_tensor=combine_elecs_all_wlist_word;
probe_tensor=combine_elecs_all_wlist_probe;
wlist_angles=calc_similarities(word_tensor,probe_tensor);

%jabber
word_tensor=combine_elecs_all_jab_word;
probe_tensor=combine_elecs_all_jab_probe;
jab_angles=calc_similarities(word_tensor,probe_tensor);

%nonword
word_tensor=combine_elecs_all_non_word;
probe_tensor=combine_elecs_all_non_probe;
non_angles=calc_similarities(word_tensor,probe_tensor);

%% Generate figure
strings={'S','W','J','N'};
angs={sent_angles, wlist_angles, jab_angles, non_angles};
figure;
for i=1:length(strings)
    subplot(2,2,i);
    imagesc(cell2mat(transpose(angs{1,i})));
    colorbar();
    title(strcat('angle b/w ',strings{1,i},' & probe'));
    ylabel('trials');
end
    
    
