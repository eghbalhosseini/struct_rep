close all
home 
%% specify where the data is
if ispc
    % kirsi's computer 
    data_path='C:\Users\kirsi\Documents\Git\UROP\struct_rep\data'; 
    analysis_path=strcat(data_path,'analysis\distributed_oscilatory_power\');
    subject_id='AMC026';
    d_data= dir(strcat(data_path,'\',subject_id,'*_crunched_v3_compressed.mat')); 
    d_data=arrayfun(@(x) strcat(d_data(x).folder,'\',d_data(x).name),[1:length(d_data)]','uni',false); %change '/'
else 
    % eghbal's computer 
    data_path='~/MyData/struct_rep/crunched/';
    analysis_path=strcat(data_path,'analysis/distributed_oscilatory_power/');
    subject_id='AMC026';
    d_data= dir(strcat(data_path,'/',subject_id,'*_crunched_v3_compressed.mat')); 
    d_data=arrayfun(@(x) strcat(d_data(x).folder,'/',d_data(x).name),[1:length(d_data)]','uni',false); %change '/'
end 

for k=1:length(d_data)
    subj=load(d_data{k});
    subj_id=fieldnames(subj);
    subj=subj.(subj_id{1});
    data=subj.data;
    info=subj.info;
    
    for j=1:length(data)
        elec=data{j,1}.combined_signal_gaus_zs_parsed;
        elec_cell=cell(length(elec),1);
        for i=1:length(elec)
            pos=elec{i,1};
            pos_mat=zeros(5*length(pos),1);
            for h=1:length(pos)
                temp=transpose(pos(h,:));
                pos_mat(h+4*(h-1):5*h)=temp;
            end
            elec_cell{i,1}=pos_mat;
        end
        data{j,1}.combined_electrodes=elec_cell;
        subject_name=info.subject;
        session_name=info.session_name;
        eval(strcat(subject_name,'_',session_name,'.data=data;'));
        eval(strcat(subject_name,'_',session_name,'.info=info;'));
        save(d_data{k},strcat(subject_name,'_',session_name),'-v7.3');
    end
fprintf('Completed one file\n')
end

                    
                    
            
        