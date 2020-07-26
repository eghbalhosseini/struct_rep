close all
home 
data_path={'C:\Users\kirsi\Documents\data\updated_files'}; 
subject_id='AMC026';
for m=1:length(data_path)
    d_data= dir(strcat(data_path{1,m},'\',subject_id,'*_crunched_v3_compressed.mat')); 
    d_data=arrayfun(@(x) strcat(d_data(x).folder,'\',d_data(x).name),[1:length(d_data)]','uni',false);
    fprintf('%d .mat files found \n',length(d_data));
    
    for k=1:length(d_data)
        subj=load(d_data{k});
        subj_id=fieldnames(subj);
        subj=subj.(subj_id{1});
        data=subj.data;
        info=subj.info;
        
        for j=1:length(data)
            data{j,1}.stimuli_type{9,1}='preprobe';
            data{j,1}.stimuli_type{11,1}='postprobe';
        end
        subject_name=info.subject;
        session_name=info.session_name;
        eval(strcat(subject_name,'_',session_name,'.data=data;'));
        eval(strcat(subject_name,'_',session_name,'.info=info;'));
        save(d_data{k},strcat(subject_name,'_',session_name),'-v7.3');
    end
end
    
