%% specify where the data is, initialize cell to store tensors for each probe position
data_path='C:\Users\kirsi\Dropbox\struct_rep_data'; 
subject_id={'AMC026','AMC029','AMC031','AMC037','AMC038','AMC044'};

store_sent_word_tensors=cell(length(subject_id),8);
store_sent_probe_tensors=cell(length(subject_id),8);
store_wlist_word_tensors=cell(length(subject_id),8);
store_wlist_probe_tensors=cell(length(subject_id),8);

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

    %% Separate tensor by probe position, store in appropriate row store_tensor cell array
    sent_word_copy=sent_word_tensor_all(:,:,:);
    sent_probe_copy=sent_probe_tensor_all(:,:,:);
    wlist_word_copy=wlist_word_tensor_all(:,:,:);
    wlist_probe_copy=wlist_probe_tensor_all(:,:,:);
    for i=1:8
        temp_sent_word_pos=sent_word_copy(:,:,1:sum(sent_positions==i));
        store_sent_word_tensors{m,i}=temp_sent_word_pos;
        sent_word_copy=sent_word_copy(:,:,sum(sent_positions==i)+1:end);

        temp_sent_probe_pos=sent_probe_copy(:,:,1:sum(sent_positions==i));
        store_sent_probe_tensors{m,i}=temp_sent_probe_pos;
        sent_probe_copy=sent_probe_copy(:,:,sum(sent_positions==i)+1:end);

        temp_wlist_word_pos=wlist_word_copy(:,:,1:sum(wlist_positions==i));
        store_wlist_word_tensors{m,i}=temp_wlist_word_pos;
        wlist_word_copy=wlist_word_copy(:,:,sum(wlist_positions==i)+1:end);

        temp_wlist_probe_pos=wlist_probe_copy(:,:,1:sum(wlist_positions==i));
        store_wlist_probe_tensors{m,i}=temp_wlist_probe_pos;
        wlist_probe_copy=wlist_probe_copy(:,:,sum(wlist_positions==i)+1:end);
    end

end

%% For each probe pos (collumn) in store_tensors, find largest dim3 size
dim_sizes_sent_all=zeros(length(subject_id),8);
dim_sizes_wlist_all=zeros(length(subject_id),8);
for j=1:size(store_wlist_probe_tensors,2)
    for i=1:size(store_wlist_probe_tensors,1)
        dim_val_sent=size(store_sent_word_tensors{i,j},3);
        dim_sizes_sent_all(i,j)=dim_val_sent;
        dim_val_wlist=size(store_wlist_word_tensors{i,j},3);
        dim_sizes_wlist_all(i,j)=dim_val_wlist;
    end
end

max_dim_sizes_sent=zeros(1,8);
max_dim_sizes_wlist=zeros(1,8);

for j=1:8
    max_dim_val_sent=max(dim_sizes_sent_all(:,j));
    max_dim_sizes_sent(1,j)=max_dim_val_sent;
    
    max_dim_val_wlist=max(dim_sizes_wlist_all(:,j));
    max_dim_sizes_wlist(1,j)=max_dim_val_wlist;
end

%% add NaN to other tensors to match max dim3 in each collumn
for j=1:size(store_sent_word_tensors,2)
    for i=1:size(store_sent_word_tensors,1)
        dims_needed=max_dim_sizes_sent(1,j)-size(store_sent_word_tensors{i,j},3);
        filler=NaN(size(store_sent_word_tensors{i,j},1),size(store_sent_word_tensors{i,j},2),dims_needed);
        store_sent_word_tensors{i,j}=cat(3,store_sent_word_tensors{i,j},filler);
        
        filler=NaN(size(store_sent_probe_tensors{i,j},1),size(store_sent_probe_tensors{i,j},2),dims_needed);
        store_sent_probe_tensors{i,j}=cat(3,store_sent_probe_tensors{i,j},filler);
        
        dims_needed=max_dim_sizes_wlist(1,j)-size(store_wlist_word_tensors{i,j},3);
        filler=NaN(size(store_wlist_word_tensors{i,j},1),size(store_wlist_word_tensors{i,j},2),dims_needed);
        store_wlist_word_tensors{i,j}=cat(3,store_wlist_word_tensors{i,j},filler);
        
        filler=NaN(size(store_wlist_probe_tensors{i,j},1),size(store_wlist_probe_tensors{i,j},2),dims_needed);
        store_wlist_probe_tensors{i,j}=cat(3,store_wlist_probe_tensors{i,j},filler);
    end
end

%% Combine tensors of each position (each store_tensors collumn)

sent_word_combined_tensors=cell(1,size(store_sent_word_tensors,2));
sent_probe_combined_tensors=cell(1,size(store_sent_word_tensors,2));
wlist_word_combined_tensors=cell(1,size(store_sent_word_tensors,2));
wlist_probe_combined_tensors=cell(1,size(store_sent_word_tensors,2));

for j=1:size(store_sent_word_tensors,2)
    sent_word_combined_tensor=[];
    sent_probe_combined_tensor=[];
    wlist_word_combined_tensor=[];
    wlist_probe_combined_tensor=[];
    
    for i=1:size(store_sent_word_tensors,1)
        sent_word_combined_tensor=cat(1,sent_word_combined_tensor,store_sent_word_tensors{i,j});
        sent_probe_combined_tensor=cat(1,sent_probe_combined_tensor,store_sent_probe_tensors{i,j});
        wlist_word_combined_tensor=cat(1,wlist_word_combined_tensor,store_wlist_word_tensors{i,j});
        wlist_probe_combined_tensor=cat(1,wlist_probe_combined_tensor,store_wlist_probe_tensors{i,j});
    end
    sent_word_combined_tensors{1,j}=sent_word_combined_tensor;
    sent_probe_combined_tensors{1,j}=sent_probe_combined_tensor;
    wlist_word_combined_tensors{1,j}=wlist_word_combined_tensor;
    wlist_probe_combined_tensors{1,j}=wlist_probe_combined_tensor;
end

%% Angles for each combined word vs probe tensor

sent_angles=cell(length(sent_word_combined_tensors),1);
wlist_angles=cell(length(sent_word_combined_tensors),1);
for i=1:length(sent_word_combined_tensors)
    sent_angles{i,1}=calc_similarities(sent_word_combined_tensors{1,i}, sent_probe_combined_tensors{1,i});
    sent_angles{i,1}=mean(cell2mat(transpose(sent_angles{i,1})),1);
    
    wlist_angles{i,1}=calc_similarities(wlist_word_combined_tensors{1,i}, wlist_probe_combined_tensors{1,i});
    wlist_angles{i,1}=mean(cell2mat(transpose(wlist_angles{i,1})),1);
end

sent_for_fig=cell2mat(sent_angles);
wlist_for_fig=cell2mat(wlist_angles);

%% Generate Figures

max_sent=max(sent_for_fig,[],'all');
min_sent=min(sent_for_fig,[],'all');
max_wlist=max(wlist_for_fig,[],'all');
min_wlist=min(wlist_for_fig,[],'all');

total_max=max([max_sent,max_wlist],[],'all');
total_min=min([min_sent,min_wlist],[],'all');

strings=['S','W'];
angs={sent_for_fig, wlist_for_fig};
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









