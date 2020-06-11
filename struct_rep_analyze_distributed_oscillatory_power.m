clear all
close all
home 
%% specify where the data is
%data_path='C:\Users\kirsi\Documents\Git\UROP\struct_rep\data'; %change depending on user
data_path='~/MyData/struct_rep/crunched/';
%analysis_path=strcat(data_path,'analysis\distributed_oscilatory_power\');
analysis_path=strcat(data_path,'analysis/distributed_oscilatory_power/');
subject_id='AMC026';
d_data= dir(strcat(data_path,'/',subject_id,'*_crunched_v2.mat'));
fprintf(' %d .mat files were found \n', length(d_data));
d_data=arrayfun(@(x) strcat(d_data(x).folder,'/',d_data(x).name),[1:length(d_data)]','uni',false);
%% combine responses from all sessions for a given condition. (S= sentence,....)
sent_word_hilb_ave_tensor_all=[];
wlist_word_hilb_ave_tensor_all=[];
sent_probe_hilb_ave_tensor_all=[];
wlist_probe_hilb_ave_tensor_all=[];
for k=1:length(d_data)
    subj=load(d_data{k});
    subj_id=fieldnames(subj);
    subj=subj.(subj_id{1});
    data=subj.data;
    info=subj.info;
    % sentences 

    cond='S';
    stim='word';
    data_out=extract_condition_response(data,info,cond,stim);
    sent_word_hilb_ave_tensor_all=cat(3,sent_word_hilb_ave_tensor_all,data_out);
    fprintf('added %s\n', strcat(d_data{k},'sent word'))
    % sentence, probe condition 
    cond='S';
    stim='probe';
    data_out=extract_condition_response(data,info,cond,stim);
    sent_probe_hilb_ave_tensor_all=cat(3,sent_probe_hilb_ave_tensor_all,data_out);
    fprintf('added %s\n', strcat(d_data{k},'sent probe'))
    %wordlists
    cond='W';
    stim='word';
    data_out=extract_condition_response(data,info,cond,stim);
    wlist_word_hilb_ave_tensor_all=cat(3,wlist_word_hilb_ave_tensor_all,data_out);
    fprintf('added %s\n', strcat(d_data{k},'wlist word'))
    % wordlist, probe condition 
    cond='W';
    stim='probe';
    data_out=extract_condition_response(data,info,cond,stim);
    wlist_probe_hilb_ave_tensor_all=cat(3,wlist_probe_hilb_ave_tensor_all,data_out);
    fprintf('added %s\n', strcat(d_data{k},'wlist probe'))
end 
%% compute a cosine distance between word representation over all electrodes during sentence and during probe
% sentence condition 
sent_probe_norm=arrayfun(@(x)  sqrt(transpose(sent_probe_hilb_ave_tensor_all(:,:,x))*sent_probe_hilb_ave_tensor_all(:,:,x)),[1:size(sent_probe_hilb_ave_tensor_all,3)],'uni',false);
sent_words_norm=arrayfun(@(x)  diag(sqrt(transpose(sent_word_hilb_ave_tensor_all(:,:,x))*sent_word_hilb_ave_tensor_all(:,:,x))),[1:size(sent_probe_hilb_ave_tensor_all,3)],'uni',false);
sent_norms=cellfun(@(x,y) transpose(x.*y) ,sent_probe_norm,sent_words_norm,'uni',false);
sent_w_vs_probe_dot=arrayfun(@(x)  transpose(sent_probe_hilb_ave_tensor_all(:,:,x))*sent_word_hilb_ave_tensor_all(:,:,x),[1:size(sent_word_hilb_ave_tensor_all,3)],'uni',false);
sent_w_vs_probe_angle=cellfun(@(x,y) x./y,sent_w_vs_probe_dot,sent_norms,'uni',false);

% wordlist condition 
wlist_probe_norm=arrayfun(@(x)  sqrt(transpose(wlist_probe_hilb_ave_tensor_all(:,:,x))*wlist_probe_hilb_ave_tensor_all(:,:,x)),[1:size(wlist_probe_hilb_ave_tensor_all,3)],'uni',false);
wlist_words_norm=arrayfun(@(x)  diag(sqrt(transpose(wlist_word_hilb_ave_tensor_all(:,:,x))*wlist_word_hilb_ave_tensor_all(:,:,x))),[1:size(wlist_probe_hilb_ave_tensor_all,3)],'uni',false);
wlist_norms=cellfun(@(x,y) transpose(x.*y) ,wlist_probe_norm,wlist_words_norm,'uni',false);
wlist_w_vs_probe_dot=arrayfun(@(x)  transpose(wlist_probe_hilb_ave_tensor_all(:,:,x))*wlist_word_hilb_ave_tensor_all(:,:,x),[1:size(wlist_word_hilb_ave_tensor_all,3)],'uni',false);
wlist_w_vs_probe_angle=cellfun(@(x,y) x./y,wlist_w_vs_probe_dot,wlist_norms,'uni',false);
%% 
figure;
subplot(1,2,1)
imagesc(cell2mat(sent_w_vs_probe_angle'));
colorbar()
title('cosine angle between sentence and probe');
subplot(1,2,2)
imagesc(cell2mat(wlist_w_vs_probe_angle'));
colorbar()
title('cosine angle between wordlist and probe');
