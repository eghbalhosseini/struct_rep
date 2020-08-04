data_path='C:\Users\kirsi\Documents\data';
subject_id={'AMC026','AMC029','AMC031','AMC037','AMC038','AMC044'};
for m=1:length(subject_id)
    d_data= dir(strcat(data_path,'\',subject_id{1,m},'*_crunched_v3.mat'));
    fprintf(' %d .mat files were found \n', length(d_data));
    d_data=arrayfun(@(x) strcat(d_data(x).folder,'\',d_data(x).name),[1:length(d_data)]','uni',false);

    for k=1:length(d_data) %for each participant
        subj=load(d_data{k});
        subj_id=fieldnames(subj);
        subj=subj.(subj_id{1});
        data=subj.data;
        info=subj.info;
        position_matrix=[];
    
       for j=1:length(data)
            pretrial_data=data{j,1}.signal_pre_trial_gaus_band_hilb_dec_zs;
            new=cellfun(@(y) cell2mat(cellfun(@(x) mean(x,2), mat2cell(y,[size(y,1)],ones(1,5)*size(y,2)/5), 'uni', false)),pretrial_data,'uni',false);
            data{j,1}.new_window_pretrial_comb=new;

            stim_data=data{j,1}.signal_gaus_band_hilb_dec_zs_parsed;
            new=cellfun(@(y) cell2mat(cellfun(@(x) mean(x,2), mat2cell(y,[size(y,1)],ones(1,5)*size(y,2)/5), 'uni', false)),stim_data,'uni',false);
            new_combined=cell(size(new,1),1);
            for i=1:size(new,1)
                temp=new(i,:);
                temp=cell2mat(transpose(temp));
                new_combined{i,1}=temp;
            end
            data{j,1}.new_window_comb=new_combined;   
            
            if isempty(data{j,1}.trial_string) %fixation trial
                position_matrix=cat(1, position_matrix, -1);
            else
                word_string=data{j,1}.trial_string(2:end);
                word_string=split(word_string,[" "]);
                probe=strip(data{j,1}.trial_probe_question);
        
                if ~any(strcmp(word_string, probe)) %probe not in sequence
                    position_matrix=cat(1, position_matrix, 0);
                else %find position of probe
                    probe_position=find(strcmp(word_string,probe));
                    if length(probe_position)>1
                        info.word_type{j,1}='P';
                        probe_position=probe_position(1);
                        position_matrix=cat(1,position_matrix, probe_position);
                    else
                        position_matrix=cat(1,position_matrix, probe_position);
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
        fprintf('one out of %d .mat files done \n',length(d_data))
    end
    fprintf('one participant done \n')
end
       