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
%% Condense signal_gaus_hilb_dec_zs from 11x5 to 11x1
for k=1:length(d_data)
    subj=load(d_data{k});
    subj_id=fieldnames(subj);
    subj=subj.(subj_id{1});
    data=subj.data;
    info=subj.info;
    
    for j=1:length(data)
        new_cell={};
        location=data{j,1}.signal_gaus_band_hilb_dec_zs_parsed;
        for i=1:size(location,1)
            temp=[location{i,1},location{i,2},location{i,3},location{i,4},location{i,5}];
            new_cell{i,1}=temp;
        end
        data{j,1}.combined_signal_gaus_zs_parsed=new_cell;
        subject_name=info.subject;
        session_name=info.session_name;
        eval(strcat(subject_name,'_',session_name,'.data=data;'));
        eval(strcat(subject_name,'_',session_name,'.info=info;'));
        save(d_data{k},strcat(subject_name,'_',session_name),'-v7.3');
    end
end
            