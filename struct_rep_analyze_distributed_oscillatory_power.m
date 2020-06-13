clear all
close all
home 
%% specify where the data is
data_path='C:\Users\kirsi\Documents\Git\UROP\struct_rep\data'; %change depending on user
%data_path='~/MyData/struct_rep/crunched/';
analysis_path=strcat(data_path,'analysis\distributed_oscilatory_power\');
%analysis_path=strcat(data_path,'analysis/distributed_oscilatory_power/');
subject_id='AMC026';
d_data= dir(strcat(data_path,'\',subject_id,'*_crunched_v2.mat')); %change '/' depending on user
fprintf(' %d .mat files were found \n', length(d_data));
d_data=arrayfun(@(x) strcat(d_data(x).folder,'\',d_data(x).name),[1:length(d_data)]','uni',false); %change '/'
%% combine responses from all sessions for a given condition. (S= sentence,....)
sent_word_hilb_ave_tensor_all=[];
sent_probe_hilb_ave_tensor_all=[];
wlist_word_hilb_ave_tensor_all=[];
wlist_probe_hilb_ave_tensor_all=[];
jab_word_hilb_ave_tensor_all=[];
jab_probe_hilb_ave_tensor_all=[];
non_word_hilb_ave_tensor_all=[];
non_probe_hilb_ave_tensor_all=[];
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
    %jabber
    cond='J';
    stim='word';
    data_out=extract_condition_response(data,info,cond,stim);
    jab_word_hilb_ave_tensor_all=cat(3,jab_word_hilb_ave_tensor_all,data_out);
    fprintf('added %s\n', strcat(d_data{k},'jabber word'))
    %jabber, probe condition
    cond='J'
    stim='probe'
    data_out=extract_condition_response(data,info,cond,stim);
    jab_probe_hilb_ave_tensor_all=cat(3,jab_probe_hilb_ave_tensor_all,data_out);
    fprintf('added %s\n', strcat(d_data{k},'jabber probe'))
    %nonword
    cond='N';
    stim='word';
    data_out=extract_condition_response(data,info,cond,stim);
    non_word_hilb_ave_tensor_all=cat(3,non_word_hilb_ave_tensor_all,data_out);
    %nonword, probe condition
    cond='N';
    stim='probe';
    data_out=extract_condition_response(data,info,cond,stim);
    non_probe_hilb_ave_tensor_all=cat(3,non_probe_hilb_ave_tensor_all,data_out);
end 
%% compute a cosine distance between word representation over all electrodes during sentence and during probe
% sentence condition 
word_tensor=sent_word_hilb_ave_tensor_all;
probe_tensor=sent_probe_hilb_ave_tensor_all;
sentence_angle=calc_similarities(word_tensor,probe_tensor);

% wordlist condition 
word_tensor=wlist_word_hilb_ave_tensor_all;
probe_tensor=wlist_probe_hilb_ave_tensor_all;
wlist_angle=calc_similarities(word_tensor,probe_tensor);

% jabber condition
word_tensor=jab_word_hilb_ave_tensor_all;
probe_tensor=jab_probe_hilb_ave_tensor_all;
jab_angle=calc_similarities(word_tensor,probe_tensor);

% nonword condition
word_tensor=non_word_hilb_ave_tensor_all;
probe_tensor=non_probe_hilb_ave_tensor_all;
non_angle=calc_similarities(word_tensor,probe_tensor);

figure;
subplot(1,2,1)
imagesc(cell2mat(sentence_angle'));
colorbar()
title('cosine angle between sentence and probe');
subplot(1,2,2)
imagesc(cell2mat(wlist_angle'));
colorbar()
title('cosine angle between wordlist and probe');

figure;
subplot(1,2,1)
imagesc(cell2mat(jab_angle'));
colorbar()
title('cosine angle between jabber and probe');
subplot(1,2,2)
imagesc(cell2mat(non_angle'));
colorbar()
title('cosine angle between nonwords and probe');
