clear all;
close all;
home ;
num_of_permutation=1000; 
p_threshold=0.01;
%% specify where the data is
subject_id='AMC026';
if ispc
    % kirsi's computer 
    data_path='C:\Users\kirsi\Documents\Git\UROP\struct_rep\data'; 
    analysis_path=strcat(data_path,'analysis\distributed_oscilatory_power\');
    d_data= dir(strcat(data_path,'\',subject_id,'*_crunched_v2.mat')); 
    d_data=arrayfun(@(x) strcat(d_data(x).folder,'\',d_data(x).name),[1:length(d_data)]','uni',false); %change '/'
else 
    % eghbal's computer 
    data_path='~/MyData/struct_rep/crunched/';
    analysis_path=strcat(data_path,'analysis/distributed_oscilatory_power/');
    d_data= dir(strcat(data_path,'/',subject_id,'*_crunched_v2.mat')); 
    d_data=arrayfun(@(x) strcat(d_data(x).folder,'/',d_data(x).name),[1:length(d_data)]','uni',false); %change '/'
end 
fprintf(' %d .mat files were found \n', length(d_data));
%% 
sent_word_hilb_ave_tensor_all=[];
non_word_hilb_ave_tensor_all=[];
hilb_ave_cond_contrast_vec=[];
cond_contrast_vec=[];
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
    % take the mean across the words 
    hilb_ave_cond_contrast_vec=[hilb_ave_cond_contrast_vec,squeeze(nanmean(data_out,2))];
    cond_contrast_vec=[cond_contrast_vec,1+0*squeeze(nanmean(data_out,2))];
    %nonword
    cond='N';
    stim='word';
    data_out=extract_condition_response(data,info,cond,stim);
    hilb_ave_cond_contrast_vec=[hilb_ave_cond_contrast_vec,squeeze(nanmean(data_out,2))];
    cond_contrast_vec=[cond_contrast_vec,-1+0*squeeze(nanmean(data_out,2))];
    
    fprintf('added %s \n', d_data{k});
end 
%% step 2: compute a correlation between trial means and vector of condition labels )
% sentences = 1, nonword-lists =-1 
[RHO_hilbert,~] = corr(double(transpose(hilb_ave_cond_contrast_vec)),double(transpose(cond_contrast_vec)),'Type','Spearman','rows','complete');
rho_hilbert_original=diag(RHO_hilbert);
rho_hilbert_positive=rho_hilbert_original>0;
%% step 3: random permutation of conditions labels, repeat 1000 times 
rho_hilbert_permuted=nan*zeros(size(rho_hilbert_original,1),num_of_permutation);
fprintf('permutation :');
for k=1:num_of_permutation
    if ~mod(k,100), fprintf(' %d ',k ); end
    random_index=randperm(size(cond_contrast_vec,2));
    [RHO_hilbert_rand,~] = corr(double(transpose(hilb_ave_cond_contrast_vec)),double(transpose(cond_contrast_vec(:,random_index))),'Type','Spearman','rows','complete'); 
    rho_hilbert_permuted(:,k)=diag(RHO_hilbert_rand);
end 
%%  step 4 : compute fraction of correlations in step 3 that produce higher correlation that step 2. 
if size(info.valid_channels,1)<size(info.valid_channels,2)
    info.valid_channels=transpose(info.valid_channels);
end 
p_fraction=sum(rho_hilbert_permuted>repmat(rho_hilbert_original,[1,num_of_permutation]),2)./size(rho_hilbert_permuted,2);
p_significant=p_fraction<p_threshold;
ch_significant_and_positive=p_significant.*rho_hilbert_positive.*info.valid_channels;
ch_significant=p_significant.*info.valid_channels;

fprintf('\n hilbert language electrodes:[');
fprintf('%d, ',find(ch_significant_and_positive)' );
fprintf(']\n');
%%  step 5: add the language electrode to back to the data 
for k=1:length(d_data)
    subj=load(d_data{k});
    subj_id=fieldnames(subj);
    subj=subj.(subj_id{1});
    data=subj.data;
    info=subj.info;
    info.significant_channels=ch_significant;
    info.significant_and_positive_channels=ch_significant_and_positive;
    if size(info.valid_channels,1)<size(info.valid_channels,2)
        info.valid_channels=transpose(info.valid_channels);
    end 
    subject_name=info.subject;
    session_name=info.session_name;
    eval(strcat(subject_name,'_',session_name,'.data=data;'));
    eval(strcat(subject_name,'_',session_name,'.info=info;'));
    save(d_data{k},strcat(subject_name,'_',session_name),'-v7.3');
    fprintf('added back language electrodes to %s \n', d_data{k});
end 
fprintf('Done.\n');



