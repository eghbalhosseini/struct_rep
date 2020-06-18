%% specify where the data is
data_path='C:\Users\kirsi\Documents\Git\UROP\struct_rep\data'; %change depending on user
%data_path='~/MyData/struct_rep/crunched/';
analysis_path=strcat(data_path,'analysis\distributed_oscilatory_power\');
%analysis_path=strcat(data_path,'analysis/distributed_oscilatory_power/');
subject_id='AMC026';
d_data= dir(strcat(data_path,'\',subject_id,'*_crunched_v2.mat')); %change '/' depending on user
fprintf(' %d .mat files were found \n', length(d_data));
d_data=arrayfun(@(x) strcat(d_data(x).folder,'\',d_data(x).name),[1:length(d_data)]','uni',false); %change '/'
 
for k=1:length(d_data) %for each participant
    subj=load(d_data{k});
    subj_id=fieldnames(subj);
    subj=subj.(subj_id{1});
    data=subj.data;
    info=subj.info;
    position_matrix=[];
    
    for j=1:length(data) %for each trial
        if isempty(data{j,1}.trial_string) %fixation trial
            position_matrix=cat(1, position_matrix, 0);
        else
            word_string=data{j,1}.trial_string(2:end);
            word_string=split(word_string,[" "]);
            probe=strip(data{j,1}.trial_probe_question);
        
            if ~any(strcmp(word_string, probe)) %probe not in sequence
                position_matrix=cat(1, position_matrix, 0);
            else %find position of probe
                for i=1:length(word_string);
                    if isequal(word_string{i,1}, probe);
                        position_matrix=cat(1, position_matrix, i);
                        break;
                    end
                end
            end
        end
    end
    %%save position matrix back to files
    info.position_matrix=position_matrix;
    subject_name=info.subject;
    session_name=info.session_name;
    eval(strcat(subject_name,'_',session_name,'.data=data;'));
    eval(strcat(subject_name,'_',session_name,'.info=info;'));
    save(d_data{k},strcat(subject_name,'_',session_name),'-v7.3');
end
        
                
            
        