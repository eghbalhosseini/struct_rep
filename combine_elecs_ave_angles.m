%%Calculate angles for each trial and then average angles for each probe
%%position --> Done for each subject separately (not combined)

%% specify where the data is
data_path='C:\Users\kirsi\Dropbox\struct_rep_data'; 
subject_id={'AMC026','AMC029','AMC031','AMC037','AMC038','AMC044'};

for m=1:length(subject_id)
    d_data= dir(strcat(data_path,'\',subject_id{1,m},'*_crunched_v4_compressed.mat')); 
    d_data=arrayfun(@(x) strcat(d_data(x).folder,'\',d_data(x).name),[1:length(d_data)]','uni',false);
    fprintf('%d .mat files found',length(d_data))
    

    sent_word_combined_elecs=[];
    sent_probe_combined_elecs=[];
    wlist_word_combined_elecs=[];
    wlist_probe_combined_elecs=[];
  
    for k=1:length(d_data)
        subj=load(d_data{k});
        subj_id=fieldnames(subj);
        subj=subj.(subj_id{1});
        data=subj.data;
        info=subj.info;

        data_out_all=extract_condition_response(data,info,'S','word',true,talse,true);
        sent_word_combined_elecs=cat(3,sent_word_combined_elecs,data_out_all);

        data_out_all=extract_condition_response(data,info,'S','probe',true,false,true);
        sent_probe_combined_elecs=cat(3,sent_probe_combined_elecs,data_out_all);

        data_out_all=extract_condition_response(data,info,'W','word',true,false,true);
        wlist_word_combined_elecs=cat(3,wlist_word_combined_elecs,data_out_all);

        data_out_all=extract_condition_response(data,info,'W','probe',true,false,true);
        wlist_probe_combined_elecs=cat(3,wlist_probe_combined_elecs,data_out_all);
    end
    %% Sort tensors according to probe positions
    %Create vector with all positions across participants for each condition
    sent_positions=[];
    wlist_positions=[];

    for k=1:length(d_data)
        subj=load(d_data{k});
        subj_id=fieldnames(subj);
        subj=subj.(subj_id{1});
        data=subj.data;
        info=subj.info;

        temp_sent_pos=get_positions(info,data,'S',true);
        sent_positions=cat(1, sent_positions, temp_sent_pos);

        temp_wlist_pos=get_positions(info,data,'W',true);
        wlist_positions=cat(1, wlist_positions, temp_wlist_pos);

        temp_jab_pos=get_positions(info,data,'J',true);
        jab_positions=cat(1, jab_positions, temp_jab_pos);

        temp_non_pos=get_positions(info,data,'N',true);
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
   
    sent_probe_combined_elecs=sent_probe_combined_elecs.*info.sig_and_pos_chans_combine_elecs;
    wlist_probe_combined_elecs=wlist_probe_combined_elecs.*info.sig_and_pos_chans_combine_elecs;
   
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
% 
%     sent_probe_combined_elecs=sent_probe_combined_elecs.*scale_matrix;
%     wlist_probe_combined_elecs=wlist_probe_combined_elecs.*scale_matrix;

    %% Find Angles for every trial, Average angles with same probe position
    sent_angles=calc_similarities(sent_word_combined_elecs, sent_probe_combined_elecs);
    wlist_angles=calc_similarities(wlist_word_combined_elecs, wlist_probe_combined_elecs);
   
    sent_angles=cell2mat(transpose(sent_angles));
    wlist_angles=cell2mat(transpose(wlist_angles));
    sent_angles_copy=sent_angles(:,:);
    wlist_angles_copy=wlist_angles(:,:);
    
    averaged_sent_angles=zeros(9,8);
    averaged_wlist_angles=zeros(9,8);
    
    for i=0:8
        temp_sent_angles=sent_angles_copy(1:sum(sent_angles_copy==i),:);
        temp_sent_angles=mean(temp_sent_angles,1);
        temp_wlist_angles=wlist_angles_copy(1:sum(wlist_angles_copy==i),:);
        temp_wlist_angles=mean(temp_wlist_angles,1);
        
        sent_angles_copy=sent_angles_copy(1+sum(sent_angles_copy==i):end,:);
        wlist_angles_copy=wlist_anlges_copy(1+sum(wlist_angles_copy==i):end,:);
        
        averaged_sent_angles(i+1,:)=temp_sent_angles;
        averaged_wlist_angles(i+1,:)=temp_wlist_angles;
    end

    %% Create Figures
    max_sent=max(averaged_sent_angles,[],'all');
    min_sent=min(averaged_sent_angles,[],'all');
    max_wlist=max(averaged_wlist_angles,[],'all');
    min_wlist=min(averaged_wlist_angles,[],'all');

    total_max=max([max_sent,max_wlist],[],'all');
    total_min=min([min_sent,min_wlist],[],'all');

    strings=['S','W'];
    angs={averaged_sent_angles,averaged_wlist_angles};
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
end
