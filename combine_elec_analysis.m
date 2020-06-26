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
    
    data_out_all=extract_condition_response(data,info,'S','word');
    sent_word_combined_elecs=cat(3,sent_word_combined_elecs,data_out_all);
    
    data_out_all=extract_condition_response(data,info,'S','probe');
    sent_probe_combined_elecs=cat(3,sent_probe_combined_elecs,data_out_all);

    data_out_all=extract_condition_response(data,info,'W','word');
    wlist_word_combined_elecs=cat(3,wlist_word_combined_elecs,data_out_all);
    
    data_out_all=extract_condition_response(data,info,'W','probe');
    wlist_probe_combined_elecs=cat(3,wlist_probe_combined_elecs,data_out_all);

    data_out_all=extract_condition_response(data,info,'J','word');
    jab_word_combined_elecs=cat(3,jab_word_combined_elecs,data_out_all);

    data_out_all=extract_condition_response(data,info,'J','probe');
    jab_probe_combined_elecs=cat(3,jab_probe_combined_elecs,data_out_all);

    data_out_all=extract_condition_response(data,info,'N','word');
    non_word_combined_elecs=cat(3,non_word_combined_elecs,data_out_all);
    
    data_out_all=extract_condition_response(data,info,'N','probe');
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
sent_word_combined_elecs=probe_pos_ave_trials(sent_change_indices, sent_word_combined_elecs);
sent_probe_combined_elecs=probe_pos_ave_trials(sent_change_indices, sent_probe_combined_elecs); 

wlist_word_combined_elecs=probe_pos_ave_trials(wlist_change_indices, wlist_word_combined_elecs);
wlist_probe_combined_elecs=probe_pos_ave_trials(wlist_change_indices, wlist_probe_combined_elecs);    

jab_word_combined_elecs=probe_pos_ave_trials(jab_change_indices, jab_word_combined_elecs);
jab_probe_combined_elecs=probe_pos_ave_trials(jab_change_indices, jab_probe_combined_elecs); 

non_word_combined_elecs=probe_pos_ave_trials(non_change_indices, non_word_combined_elecs);
non_probe_combined_elecs=probe_pos_ave_trials(non_change_indices, non_probe_combined_elecs);

%% Only use valid channels
scale_matrix=zeros(640,1);
for i=1:length(info.valid_channels)
    temp=repmat(info.valid_channels(i),5,1);
    scale_matrix(i+4*(i-1):5*i)=temp;
end

sent_word_combined_elecs=sent_word_combined_elecs.*repmat(scale_matrix,1,8);
wlist_word_combined_elecs=wlist_word_combined_elecs.*repmat(scale_matrix,1,8);
jab_word_combined_elecs=jab_word_combined_elecs.*repmat(scale_matrix,1,8);
non_word_combined_elecs=non_word_combined_elecs.*repmat(scale_matrix,1,8);

sent_probe_combined_elecs=sent_probe_combined_elecs.*scale_matrix;
wlist_probe_combined_elecs=wlist_probe_combined_elecs.*scale_matrix;
jab_probe_combined_elecs=jab_probe_combined_elecs.*scale_matrix;
non_probe_combined_elecs=non_probe_combined_elecs.*scale_matrix;

%% Compute cosine distance
%sentence
word_tensor=sent_word_combined_elecs;
probe_tensor=sent_probe_combined_elecs;
sent_angles=calc_similarities(word_tensor,probe_tensor);

%wordlist
word_tensor=wlist_word_combined_elecs;
probe_tensor=wlist_probe_combined_elecs;
wlist_angles=calc_similarities(word_tensor,probe_tensor);

%jabber
word_tensor=jab_word_combined_elecs;
probe_tensor=jab_probe_combined_elecs;
jab_angles=calc_similarities(word_tensor,probe_tensor);

%nonword
word_tensor=non_word_combined_elecs;
probe_tensor=non_probe_combined_elecs;
non_angles=calc_similarities(word_tensor,probe_tensor);

%% Generate figure
strings=['S','W','J','N'];
angs={sent_angles, wlist_angles, jab_angles, non_angles};
figure;
for i=1:4
    subplot(2,2,i);
    imagesc(cell2mat(transpose(angs{1,i})));
    colorbar();
    title(strcat('angle b/w ',strings(i),' & probe'));
    ylabel('trials');
end



    
    
    