data_path={'C:\Users\kirsi\Documents\data\updated_files', 'C:\Users\kirsi\Dropbox\struct_rep_data'}; 
subject_id={'AMC026','AMC029','AMC031','AMC037','AMC038','AMC044'};

for m=1:length(subject_id)
    orig_d_data= dir(strcat(data_path{1,1},'\',subject_id{1,m},'*_crunched_v3_compressed.mat')); 
    orig_d_data=arrayfun(@(x) strcat(orig_d_data(x).folder,'\',orig_d_data(x).name),[1:length(orig_d_data)]','uni',false);
    new_d_data= dir(strcat(data_path{1,2},'\',subject_id{1,m},'*_crunched_v4_compressed.mat')); 
    new_d_data=arrayfun(@(x) strcat(new_d_data(x).folder,'\',new_d_data(x).name),[1:length(new_d_data)]','uni',false);
    fprintf('%d .mat files found',length(new_d_data));
    
    for k=1:length(new_d_data)
        new_subj=load(new_d_data{k});
        new_subj_id=fieldnames(new_subj);
        new_subj=new_subj.(new_subj_id{1});
        new_data=new_subj.data;
        new_info=new_subj.info;

        orig_subj=load(orig_d_data{k});
        orig_subj_id=fieldnames(orig_subj);
        orig_subj=orig_subj.(orig_subj_id{1});
        orig_data=orig_subj.data;
        orig_info=orig_subj.info;

        for j=1:length(new_data)
            new_data{j,1}.combined_electrodes=orig_data{j,1}.combined_electrodes;
            new_data{j,1}.combined_signal_gaus_zs_parsed=orig_data{j,1}.combined_signal_gaus_zs_parsed;
        end
        new_info.position_matrix=orig_info.position_matrix;
        new_info.sig_chans_combine_elecs=orig_info.sig_chans_combine_elecs;
        new_info.sig_and_pos_chans_combine_elecs=orig_info.sig_and_pos_chans_combine_elecs;

        subject_name=new_info.subject;
        session_name=new_info.session_name;
        eval(strcat(subject_name,'_',session_name,'.data=new_data;'));
        eval(strcat(subject_name,'_',session_name,'.info=new_info;'));
        save(new_d_data{k},strcat(subject_name,'_',session_name),'-v7.3');
        fprintf('added back language electrodes to %s \n', new_d_data{k});
    end
end
            
            
            