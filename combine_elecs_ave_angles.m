%% specify where the data is
data_path='C:\Users\kirsi\Documents\Git\UROP\struct_rep\data\ave_window_time'; 
subject_id={'AMC026','AMC029','AMC031','AMC037','AMC038'};
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

        data_out_all=extract_condition_response(data,info,'S','word',false,true);
        sent_word_combined_elecs=cat(3,sent_word_combined_elecs,data_out_all);

        data_out_all=extract_condition_response(data,info,'S','probe',false,true);
        sent_probe_combined_elecs=cat(3,sent_probe_combined_elecs,data_out_all);

        data_out_all=extract_condition_response(data,info,'W','word',false,true);
        wlist_word_combined_elecs=cat(3,wlist_word_combined_elecs,data_out_all);

        data_out_all=extract_condition_response(data,info,'W','probe',false,true);
        wlist_probe_combined_elecs=cat(3,wlist_probe_combined_elecs,data_out_all);

        data_out_all=extract_condition_response(data,info,'J','word',false,true);
        jab_word_combined_elecs=cat(3,jab_word_combined_elecs,data_out_all);

        data_out_all=extract_condition_response(data,info,'J','probe',false,true);
        jab_probe_combined_elecs=cat(3,jab_probe_combined_elecs,data_out_all);

        data_out_all=extract_condition_response(data,info,'N','word',false,true);
        non_word_combined_elecs=cat(3,non_word_combined_elecs,data_out_all);

        data_out_all=extract_condition_response(data,info,'N','probe',false,true);
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
    
    %% Only use lang responsive channels
    sent_word_combined_elecs=sent_word_combined_elecs.*repmat(info.sig_and_pos_chans_combine_elecs,1,8);
    wlist_word_combined_elecs=wlist_word_combined_elecs.*repmat(info.sig_and_pos_chans_combine_elecs,1,8);
    jab_word_combined_elecs=jab_word_combined_elecs.*repmat(info.sig_and_pos_chans_combine_elecs,1,8);
    non_word_combined_elecs=non_word_combined_elecs.*repmat(info.sig_and_pos_chans_combine_elecs,1,8);

    sent_probe_combined_elecs=sent_probe_combined_elecs.*info.sig_and_pos_chans_combine_elecs;
    wlist_probe_combined_elecs=wlist_probe_combined_elecs.*info.sig_and_pos_chans_combine_elecs;
    jab_probe_combined_elecs=jab_probe_combined_elecs.*info.sig_and_pos_chans_combine_elecs;
    non_probe_combined_elecs=non_probe_combined_elecs.*info.sig_and_pos_chans_combine_elecs;

%     %% Only use valid channels
%     if size(sent_word_combined_elecs,1)>length(info.valid_channels)
%         scale_matrix=zeros(5*length(info.valid_channels),1);
%         for i=1:length(info.valid_channels)
%             temp=repmat(info.valid_channels(i),5,1);
%             scale_matrix(i+4*(i-1):5*i)=temp;
%         end
%     else
%         scale_matrix=info.valid_channels;
%     end
% 
%     sent_word_combined_elecs=sent_word_combined_elecs.*repmat(scale_matrix,1,8);
%     wlist_word_combined_elecs=wlist_word_combined_elecs.*repmat(scale_matrix,1,8);
%     jab_word_combined_elecs=jab_word_combined_elecs.*repmat(scale_matrix,1,8);
%     non_word_combined_elecs=non_word_combined_elecs.*repmat(scale_matrix,1,8);
% 
%     sent_probe_combined_elecs=sent_probe_combined_elecs.*scale_matrix;
%     wlist_probe_combined_elecs=wlist_probe_combined_elecs.*scale_matrix;
%     jab_probe_combined_elecs=jab_probe_combined_elecs.*scale_matrix;
%     non_probe_combined_elecs=non_probe_combined_elecs.*scale_matrix;

    %% Find where probe position changes in each matrix
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
    
    %% Calculate angles for each probe position & take average
    sent_angles=average_angles(sent_word_combined_elecs,sent_probe_combined_elecs,sent_change_indices);
    sent_angles_mat=cell2mat(sent_angles);
    
    wlist_angles=average_angles(wlist_word_combined_elecs,wlist_probe_combined_elecs,wlist_change_indices);
    wlist_angles_mat=cell2mat(wlist_angles);
    
    jab_angles=average_angles(jab_word_combined_elecs,jab_probe_combined_elecs,jab_change_indices);
    jab_angles_mat=cell2mat(jab_angles);
    
    non_angles=average_angles(non_word_combined_elecs,non_probe_combined_elecs,non_change_indices);
    non_angles_mat=cell2mat(non_angles);
    
    %% Create Figures
    strings={'S','W','J','N'};
    angs={sent_angles_mat, wlist_angles_mat, jab_angles_mat, non_angles_mat};
    figure;
    for i=1:length(strings)
        subplot(2,2,i);
        imagesc(angs{1,i});
        colorbar();
        title(strcat('angle b/w ',strings{1,i},' & probe'));
        ylabel('trials');
    end
    fprintf('one participant done')
end
