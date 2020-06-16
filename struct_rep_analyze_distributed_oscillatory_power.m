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

%% compute a cosine distance between word representation over all electrodes during sentence and during probe
% sentence condition all
word_tensor=sent_word_hilb_ave_tensor_all;
probe_tensor=sent_probe_hilb_ave_tensor_all;
sentence_angle=calc_similarities(word_tensor,probe_tensor);

%sentence condition lang responsive
word_tensor=sent_word_hilb_ave_tensor_lang;
probe_tensor=sent_probe_hilb_ave_tensor_lang;
sentence_angle_lang=calc_similarities(word_tensor,probe_tensor);

% wordlist condition all
word_tensor=wlist_word_hilb_ave_tensor_all;
probe_tensor=wlist_probe_hilb_ave_tensor_all;
wlist_angle=calc_similarities(word_tensor,probe_tensor);

%wordlist condition lang responsive
word_tensor=wlist_word_hilb_ave_tensor_lang;
probe_tensor=wlist_probe_hilb_ave_tensor_lang;
wlist_angle_lang=calc_similarities(word_tensor,probe_tensor);

% jabber condition all
word_tensor=jab_word_hilb_ave_tensor_all;
probe_tensor=jab_probe_hilb_ave_tensor_all;
jab_angle=calc_similarities(word_tensor,probe_tensor);

%jabber condition lang responsive
word_tensor=jab_word_hilb_ave_tensor_lang;
probe_tensor=jab_probe_hilb_ave_tensor_lang;
jab_angle_lang=calc_similarities(word_tensor,probe_tensor);

% nonword condition all
word_tensor=non_word_hilb_ave_tensor_all;
probe_tensor=non_probe_hilb_ave_tensor_all;
non_angle=calc_similarities(word_tensor,probe_tensor);

% nonword condition lang responsive
word_tensor=non_word_hilb_ave_tensor_lang;
probe_tensor=non_probe_hilb_ave_tensor_lang;
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

%% create_figure function: create figures with any combo of 2 conditions
%sentence to wlist comparison
angle1=sentence_angle;
angle2=wlist_angle;
s_w_image=create_figure(angle1,'sentence',angle2,'wordlist');

