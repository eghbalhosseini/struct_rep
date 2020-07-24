clear all
close all
home 
%% 
subject_id='AMC026';

%specify where the data is
[ignore,user]=system('whoami');
if contains(user,'eghbalhosseini')
        data_path='~/MyData/struct_rep/crunched/';
        save_path='~/MyData/ecog_nlength/crunched/';
        analysis_path=strcat(data_path,'analysis/sequence_formation/');

elseif contains(user,'kirsi')
        code_path='~/GitHub/evlab_ecog_tools';    
        data_path='C:\Users\kirsi\Documents\Git\UROP\struct_rep\data'; %change depending on user
        analysis_path=strcat(data_path,'analysis\distributed_oscilatory_power\');

end 


d_data= dir(strcat(data_path,filesep,subject_id,'*_crunched_v3.mat')); %change '/' depending on user
fprintf(' %d .mat files were found \n', length(d_data));
d_data=arrayfun(@(x) strcat(d_data(x).folder,filesep,d_data(x).name),[1:length(d_data)]','uni',false); %change '/'

%% combine responses from all sessions for a given condition. (S= sentence,....)
sent_word_hilb_ave_tensor_all=[];
sent_probe_hilb_ave_tensor_all=[];
wlist_word_hilb_ave_tensor_all=[];
wlist_probe_hilb_ave_tensor_all=[];
jab_word_hilb_ave_tensor_all=[];
jab_probe_hilb_ave_tensor_all=[];
non_word_hilb_ave_tensor_all=[];
non_probe_hilb_ave_tensor_all=[];

sent_word_hilb_ave_tensor_lang=[];
sent_probe_hilb_ave_tensor_lang=[];
wlist_word_hilb_ave_tensor_lang=[];
wlist_probe_hilb_ave_tensor_lang=[];
jab_word_hilb_ave_tensor_lang=[];
jab_probe_hilb_ave_tensor_lang=[];
non_word_hilb_ave_tensor_lang=[];
non_probe_hilb_ave_tensor_lang=[];

for k=1:length(d_data)
    subj=load(d_data{k});
    subj_id=fieldnames(subj);
    subj=subj.(subj_id{1});
    data=subj.data;
    info=subj.info;
    
    % sentence word cond all
    cond='S';
    stim='word';
    data_out_all=extract_condition_response(data,info,cond,stim);
    sent_word_hilb_ave_tensor_all=cat(3,sent_word_hilb_ave_tensor_all,data_out_all);
    % sentence word cond lang responsive
    scale_matrix=repmat(info.significant_and_positive_channels, 1, 8);
    data_out_lang=data_out_all.*scale_matrix;
    sent_word_hilb_ave_tensor_lang=cat(3,sent_word_hilb_ave_tensor_lang,data_out_lang);
    
    % sentence probe cond all
    cond='S';
    stim='probe';
    data_out_all=extract_condition_response(data,info,cond,stim);
    sent_probe_hilb_ave_tensor_all=cat(3,sent_probe_hilb_ave_tensor_all,data_out_all);
    % sentence probe cond lang responsive
    data_out_lang=data_out_all.*info.significant_and_positive_channels;
    sent_probe_hilb_ave_tensor_lang=cat(3,sent_probe_hilb_ave_tensor_lang,data_out_lang);

    % wordlist word cond all
    cond='W';
    stim='word';
    data_out_all=extract_condition_response(data,info,cond,stim);
    wlist_word_hilb_ave_tensor_all=cat(3,wlist_word_hilb_ave_tensor_all,data_out_all);
    % wordlist word cond lang responsive
    scale_matrix=repmat(info.significant_and_positive_channels, 1, 8);
    data_out_lang=data_out_all.*scale_matrix;
    wlist_word_hilb_ave_tensor_lang=cat(3,wlist_word_hilb_ave_tensor_lang,data_out_lang);
    
    % wordlist probe cond all
    cond='W';
    stim='probe';
    data_out_all=extract_condition_response(data,info,cond,stim);
    wlist_probe_hilb_ave_tensor_all=cat(3,wlist_probe_hilb_ave_tensor_all,data_out_all);
    % wordlist probe cond lang responsive
    data_out_lang=data_out_all.*info.significant_and_positive_channels;
    wlist_probe_hilb_ave_tensor_lang=cat(3,wlist_probe_hilb_ave_tensor_lang,data_out_lang);

    % jabber word cond all
    cond='J';
    stim='word';
    data_out_all=extract_condition_response(data,info,cond,stim);
    jab_word_hilb_ave_tensor_all=cat(3,jab_word_hilb_ave_tensor_all,data_out_all);
    % jabber word cond lang responsive
    scale_matrix=repmat(info.significant_and_positive_channels, 1, 8);
    data_out_lang=data_out_all.*scale_matrix;
    jab_word_hilb_ave_tensor_lang=cat(3,jab_word_hilb_ave_tensor_lang,data_out_lang);

    % jabber probe cond all
    cond='J'
    stim='probe'
    data_out_all=extract_condition_response(data,info,cond,stim);
    jab_probe_hilb_ave_tensor_all=cat(3,jab_probe_hilb_ave_tensor_all,data_out_all);
    % jabber probe cond lang responsive
    data_out_lang=data_out_all.*info.significant_and_positive_channels;
    jab_probe_hilb_ave_tensor_lang=cat(3,jab_probe_hilb_ave_tensor_lang,data_out_lang);

    % nonword word cond all
    cond='N';
    stim='word';
    data_out_all=extract_condition_response(data,info,cond,stim);
    non_word_hilb_ave_tensor_all=cat(3,non_word_hilb_ave_tensor_all,data_out_all);
    % nonword word cond lang responsive
    scale_matrix=repmat(info.significant_and_positive_channels, 1, 8);
    data_out_lang=data_out_all.*scale_matrix;
    non_word_hilb_ave_tensor_lang=cat(3,non_word_hilb_ave_tensor_lang,data_out_lang);
    
    % nonword probe cond all
    cond='N';
    stim='probe';
    data_out_all=extract_condition_response(data,info,cond,stim);
    non_probe_hilb_ave_tensor_all=cat(3,non_probe_hilb_ave_tensor_all,data_out_all);
    % nonword probe cond lang responsive
    data_out_lang=data_out_all.*info.significant_and_positive_channels;
    non_probe_hilb_ave_tensor_lang=cat(3,non_probe_hilb_ave_tensor_lang,data_out_lang);
end 
%%Sort tensors according to probe positions
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
sent_word_hilb_ave_tensor_all=sent_word_hilb_ave_tensor_all(:,:,index);
sent_probe_hilb_ave_tensor_all=sent_probe_hilb_ave_tensor_all(:,:,index);
sent_word_hilb_ave_tensor_lang=sent_word_hilb_ave_tensor_lang(:,:,index);
sent_probe_hilb_ave_tensor_lang=sent_probe_hilb_ave_tensor_lang(:,:,index);

[wlist_positions, index]=sort(wlist_positions);
wlist_word_hilb_ave_tensor_all=wlist_word_hilb_ave_tensor_all(:,:,index);
wlist_probe_hilb_ave_tensor_all=wlist_probe_hilb_ave_tensor_all(:,:,index);
wlist_word_hilb_ave_tensor_lang=wlist_word_hilb_ave_tensor_lang(:,:,index);
wlist_probe_hilb_ave_tensor_lang=wlist_probe_hilb_ave_tensor_lang(:,:,index);

[jab_positions, index]=sort(jab_positions);
jab_word_hilb_ave_tensor_all=jab_word_hilb_ave_tensor_all(:,:,index);
jab_probe_hilb_ave_tensor_all=jab_probe_hilb_ave_tensor_all(:,:,index);
jab_word_hilb_ave_tensor_lang=jab_word_hilb_ave_tensor_lang(:,:,index);
jab_probe_hilb_ave_tensor_lang=jab_probe_hilb_ave_tensor_lang(:,:,index);

[non_positions, index]=sort(non_positions);
non_word_hilb_ave_tensor_all=non_word_hilb_ave_tensor_all(:,:,index);
non_probe_hilb_ave_tensor_all=non_probe_hilb_ave_tensor_all(:,:,index);
non_word_hilb_ave_tensor_lang=non_word_hilb_ave_tensor_lang(:,:,index);
non_probe_hilb_ave_tensor_lang=non_probe_hilb_ave_tensor_lang(:,:,index);

%%Take average of trials with same probe position
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
sent_word_hilb_ave_ten_all=probe_pos_ave_trials(sent_change_indices, sent_word_hilb_ave_tensor_all);
sent_probe_hilb_ave_ten_all=probe_pos_ave_trials(sent_change_indices, sent_probe_hilb_ave_tensor_all);
sent_word_hilb_ave_ten_lang=probe_pos_ave_trials(sent_change_indices, sent_word_hilb_ave_tensor_lang);
sent_probe_hilb_ave_ten_lang=probe_pos_ave_trials(sent_change_indices, sent_probe_hilb_ave_tensor_lang); 

wlist_word_hilb_ave_ten_all=probe_pos_ave_trials(wlist_change_indices, wlist_word_hilb_ave_tensor_all);
wlist_probe_hilb_ave_ten_all=probe_pos_ave_trials(wlist_change_indices, wlist_probe_hilb_ave_tensor_all);
wlist_word_hilb_ave_ten_lang=probe_pos_ave_trials(wlist_change_indices, wlist_word_hilb_ave_tensor_lang);
wlist_probe_hilb_ave_ten_lang=probe_pos_ave_trials(wlist_change_indices, wlist_probe_hilb_ave_tensor_lang);    

jab_word_hilb_ave_ten_all=probe_pos_ave_trials(jab_change_indices, jab_word_hilb_ave_tensor_all);
jab_probe_hilb_ave_ten_all=probe_pos_ave_trials(jab_change_indices, jab_probe_hilb_ave_tensor_all);
jab_word_hilb_ave_ten_lang=probe_pos_ave_trials(jab_change_indices, jab_word_hilb_ave_tensor_lang);
jab_probe_hilb_ave_ten_lang=probe_pos_ave_trials(jab_change_indices, jab_probe_hilb_ave_tensor_lang); 

non_word_hilb_ave_ten_all=probe_pos_ave_trials(non_change_indices, non_word_hilb_ave_tensor_all);
non_probe_hilb_ave_ten_all=probe_pos_ave_trials(non_change_indices, non_probe_hilb_ave_tensor_all);
non_word_hilb_ave_ten_lang=probe_pos_ave_trials(non_change_indices, non_word_hilb_ave_tensor_lang);
non_probe_hilb_ave_ten_lang=probe_pos_ave_trials(non_change_indices, non_probe_hilb_ave_tensor_lang); 

%% compute a cosine distance over all electrodes to compare word & probe conditions

% sentence condition all
word_tensor=sent_word_hilb_ave_ten_all;
probe_tensor=sent_probe_hilb_ave_ten_all;
sentence_angle=calc_similarities(word_tensor,probe_tensor);

%sentence condition lang responsive
word_tensor=sent_word_hilb_ave_ten_lang;
probe_tensor=sent_probe_hilb_ave_ten_lang;
sentence_angle_lang=calc_similarities(word_tensor,probe_tensor);

% wordlist condition all
word_tensor=wlist_word_hilb_ave_ten_all;
probe_tensor=wlist_probe_hilb_ave_ten_all;
wlist_angle=calc_similarities(word_tensor,probe_tensor);

%wordlist condition lang responsive
word_tensor=wlist_word_hilb_ave_ten_lang;
probe_tensor=wlist_probe_hilb_ave_ten_lang;
wlist_angle_lang=calc_similarities(word_tensor,probe_tensor);

% jabber condition all
word_tensor=jab_word_hilb_ave_ten_all;
probe_tensor=jab_probe_hilb_ave_ten_all;
jab_angle=calc_similarities(word_tensor,probe_tensor);

%jabber condition lang responsive
word_tensor=jab_word_hilb_ave_ten_lang;
probe_tensor=jab_probe_hilb_ave_ten_lang;
jab_angle_lang=calc_similarities(word_tensor,probe_tensor);

% nonword condition all
word_tensor=non_word_hilb_ave_ten_all;
probe_tensor=non_probe_hilb_ave_ten_all;
non_angle=calc_similarities(word_tensor,probe_tensor);

% nonword condition lang responsive
word_tensor=non_word_hilb_ave_ten_lang;
probe_tensor=non_probe_hilb_ave_ten_lang;
non_angle_lang=calc_similarities(word_tensor,probe_tensor);

%%figure with 4 condtions of all electrodes on it
figure;
subplot(2,2,1);
imagesc(cell2mat(transpose(sentence_angle)));
colorbar();
title('angle b/w sentence and probe');
subplot(2,2,2);
imagesc(cell2mat(transpose(wlist_angle)));
colorbar();
title('angle b/w wordlist and probe');
subplot(2,2,3);
imagesc(cell2mat(transpose(jab_angle)));
colorbar();
title('angle b/w jabber and probe');
subplot(2,2,4);
imagesc(cell2mat(transpose(non_angle)));
colorbar();
title('angle b/w nonword and probe');

%%figure with 4 condtions of lang responsive electrodes on it
figure;
subplot(2,2,1);
imagesc(cell2mat(transpose(sentence_angle_lang)));
colorbar();
title('angle b/w S & probe, lang resp');
subplot(2,2,2);
imagesc(cell2mat(transpose(wlist_angle_lang)));
colorbar();
title('angle b/w W and probe, lang resp');
subplot(2,2,3);
imagesc(cell2mat(transpose(jab_angle_lang)));
colorbar();
title('angle b/w J and probe, lang resp');
subplot(2,2,4);
imagesc(cell2mat(transpose(non_angle_lang)));
colorbar();
title('angle b/w N and probe, lang resp');

% %% create_figure function: create figures with any combo of 2 conditions
% %sentence to wlist comparison
% angle1=sentence_angle;
% angle2=wlist_angle;
% s_w_image=create_figure(angle1,'sentence',angle2,'wordlist');

