%%Calculate angles of all sorted trials for each subject separately (like
%%combine_elecs_ave_angles). Store all angles from each subject. Take
%%angles of same position from each subject & average them, then combine
%%each position for new figures

%% specify where the data is, store angles for each subject & position vecs for each subject
data_path='C:\Users\kirsi\Dropbox\struct_rep_data'; 
subject_id={'AMC026','AMC029','AMC031','AMC037','AMC038','AMC044'};

store_sent_angles=cell(length(subject_id),1);
store_wlist_angles=cell(length(subject_id),1);

all_sent_positions=cell(length(subject_id), 1);
all_wlist_positions=cell(length(subject_id), 1);

for m=1:length(subject_id)
    d_data= dir(strcat(data_path,'\',subject_id{1,m},'*_crunched_v4_compressed.mat')); 
    d_data=arrayfun(@(x) strcat(d_data(x).folder,'\',d_data(x).name),[1:length(d_data)]','uni',false);
    fprintf('%d .mat files found\n',length(d_data));

    sent_word_tensor_all=[];
    sent_probe_tensor_all=[];
    wlist_word_tensor_all=[];
    wlist_probe_tensor_all=[];

    sent_positions=[];
    wlist_positions=[];

    %Create S & W tensors, position vec for the sub

    for k=1:length(d_data)
        subj=load(d_data{k});
        subj_id=fieldnames(subj);
        subj=subj.(subj_id{1});
        data=subj.data;
        info=subj.info;

        data_out_all=extract_condition_response(data,info,'S','word',true,false,true);
        sent_word_tensor_all=cat(3,sent_word_tensor_all,data_out_all);

        data_out_all=extract_condition_response(data,info,'S','probe',true,false,true);
        sent_probe_tensor_all=cat(3,sent_probe_tensor_all,data_out_all);

        data_out_all=extract_condition_response(data,info,'W','word',true,false,true);
        wlist_word_tensor_all=cat(3,wlist_word_tensor_all,data_out_all);

        data_out_all=extract_condition_response(data,info,'W','probe',true,false,true);
        wlist_probe_tensor_all=cat(3,wlist_probe_tensor_all,data_out_all);

        temp_sent_pos=get_positions(info,data,'S',true);
        sent_positions=cat(1, sent_positions, temp_sent_pos);

        temp_wlist_pos=get_positions(info,data,'W',true);
        wlist_positions=cat(1, wlist_positions, temp_wlist_pos);       
    end
    
    %% Sort pos vecs ascending order, sort tensors the same way
    [sent_positions, index]=sort(sent_positions);
    sent_word_tensor_all=sent_word_tensor_all(:,:,index);
    sent_probe_tensor_all=sent_probe_tensor_all(:,:,index);

    [wlist_positions, index]=sort(wlist_positions);
    wlist_word_tensor_all=wlist_word_tensor_all(:,:,index);
    wlist_probe_tensor_all=wlist_probe_tensor_all(:,:,index);

    %% Remove condition where probe not present
    sent_word_tensor_all=sent_word_tensor_all(:,:,sum(sent_positions==0)+1:end);
    sent_probe_tensor_all=sent_probe_tensor_all(:,:,sum(sent_positions==0)+1:end);

    wlist_word_tensor_all=wlist_word_tensor_all(:,:,sum(wlist_positions==0)+1:end);
    wlist_probe_tensor_all=wlist_probe_tensor_all(:,:,sum(wlist_positions==0)+1:end);

    sent_positions=sent_positions(sum(sent_positions==0)+1:end);
    wlist_positions=wlist_positions(sum(wlist_positions==0)+1:end);
    
    all_sent_positions{m,1}=sent_positions;
    all_wlist_positions{m,1}=wlist_positions;

    
    %% Lang Responsive electrodes
    
    sent_word_tensor_all=sent_word_tensor_all.*repmat(info.sig_and_pos_chans_combine_elecs,1,8);
    wlist_word_tensor_all=wlist_word_tensor_all.*repmat(info.sig_and_pos_chans_combine_elecs,1,8);

    sent_probe_tensor_all=sent_probe_tensor_all.*info.sig_and_pos_chans_combine_elecs;
    wlist_probe_tensor_all=wlist_probe_tensor_all.*info.sig_and_pos_chans_combine_elecs;
    
%     %Not Lang Responsive
%     scale_matrix=zeros(5*length(info.valid_channels),1);
%     for i=1:length(info.valid_channels)
%         temp=repmat(info.valid_channels(i),5,1);
%         scale_matrix(1+5*(i-1):5*i)=temp;
%     end
%     sent_word_tensor_all=sent_word_tensor_all.*repmat(scale_matrix,1,8);
%     wlist_word_tensor_all=wlist_word_tensor_all.*repmat(scale_matrix,1,8);
% 
%     sent_probe_tensor_all=sent_probe_tensor_all.*scale_matrix;
%     wlist_probe_tensor_all=wlist_probe_tensor_all.*scale_matrix;
  
    %% Calculate Angle matrix for subject, store in store_angles
    sent_angle=calc_similarities(sent_word_tensor_all, sent_probe_tensor_all);
    sent_angle=cell2mat(transpose(sent_angle));
    store_sent_angles{m,1}=sent_angle;
    
    wlist_angle=calc_similarities(wlist_word_tensor_all, wlist_probe_tensor_all);
    wlist_angle=cell2mat(transpose(wlist_angle));
    store_wlist_angles{m,1}=wlist_angle;
end

%% New cell array -> Angles of each position from each subject averaged to one row
angles_each_position_sent=cell(1,8);
angles_each_position_wlist=cell(1,8);
store_sent_angles_copy=store_sent_angles(:);
store_wlist_angles_copy=store_wlist_angles(:);
for j=1:8 %each position
    position_mat_sent=[];
    position_mat_wlist=[];
    for i=1:length(subject_id) %each subject
        position_mat_sent=cat(1,position_mat_sent,store_sent_angles_copy{i,1}(1:sum(all_sent_positions{i,1}==j),:));
        store_sent_angles_copy{i,1}=store_sent_angles_copy{i,1}(sum(all_sent_positions{i,1}==j)+1:end,:);
        position_mat_wlist=cat(1,position_mat_wlist,store_wlist_angles{i,1}(1:sum(all_wlist_positions{i,1}==j),:));
        store_wlist_angles_copy{i,1}=store_wlist_angles_copy{i,1}(sum(all_wlist_positions{i,1}==j)+1:end,:);
    end
    angles_each_position_sent{1,j}=mean(position_mat_sent,1);
    angles_each_position_wlist{1,j}=mean(position_mat_wlist,1);
end
    
sent_to_fig=cell2mat(transpose(angles_each_position_sent));
wlist_to_fig=cell2mat(transpose(angles_each_position_wlist));

%% Figure

max_sent=max(sent_to_fig,[],'all');
min_sent=min(sent_to_fig,[],'all');
max_wlist=max(wlist_to_fig,[],'all');
min_wlist=min(wlist_to_fig,[],'all');

total_max=max([max_sent,max_wlist],[],'all');
total_min=min([min_sent,min_wlist],[],'all');

strings=['S','W'];
angs={sent_to_fig, wlist_to_fig};
figure;

plot1=axes('position',[0.1 0.6 0.3 0.3]);
imagesc(plot1, angs{1,1});
colorbar(plot1);
caxis([total_min total_max]);
title(strcat('angle b/w ',strings(1,1),' & probe'));
xlabel('word position');
ylabel('probe position');

plot2=axes('position',[0.5 0.6 0.3 0.3]);
imagesc(plot2, angs{1,2});
colorbar(plot2);
caxis([total_min total_max]);
title(strcat('angle b/w ',strings(1,2),' & probe'));
xlabel('word position');
ylabel('probe position');





