<<<<<<< HEAD
%% Add combined electrode (combine freqs) fields & position matrix to updated files

=======
<<<<<<< HEAD
data_path='C:\Users\kirsi\Documents\data';
data_path='/Users/eghbalhosseini/MyData/struct_rep/crunched';
subject_id={'AMC026','AMC029','AMC031','AMC037','AMC038','AMC044'};
window_len=75;% ms
num_division=5;
for m=1:length(subject_id)
    d_data= dir(strcat(data_path,filesep,subject_id{1,m},'*_crunched_v3.mat'));
    fprintf(' %d .mat files were found \n', length(d_data));
    d_data=arrayfun(@(x) strcat(d_data(x).folder,filesep,d_data(x).name),[1:length(d_data)]','uni',false);

=======
>>>>>>> 65c9c0a2ac7aa95b5095b6664ab413ae23142fcd
data_path='C:\Users\kirsi\Dropbox\struct_rep_data';
% subject_id={'AMC026','AMC029','AMC031','AMC037','AMC038','AMC044'};
subject_id={'AMC026'}
for m=1:length(subject_id)
    d_data= dir(strcat(data_path,'\',subject_id{1,m},'*_crunched_v4_compressed.mat'));
    fprintf(' %d .mat files were found \n', length(d_data));
    d_data=arrayfun(@(x) strcat(d_data(x).folder,'\',d_data(x).name),[1:length(d_data)]','uni',false);
    hilb_ave_cond_contrast_vec=[];
    cond_contrast_vec=[];
>>>>>>> 0a6155226019b747b2485e9052e4c3bb63d2b1b6
    for k=1:length(d_data) %for each participant
        subj=load(d_data{k});
        subj_id=fieldnames(subj);
        subj=subj.(subj_id{1});
        data=subj.data;
        info=subj.info;
        position_matrix=[];
        if ~isfield(info,'position_matrix')
    
            for j=1:length(data) %for each trial
                freqs_all=data{j,1}.signal_gaus_band_hilb_dec_zs_parsed;
                freqs_all_cell=cell(size(freqs_all,1),1);
                for i=1:size(freqs_all,1)
                    freqs_all_cell{i,1}=[freqs_all{i,1}, freqs_all{i,2}, freqs_all{i,3}, freqs_all{i,4}, freqs_all{i,5}];
                end
                elec=freqs_all_cell;
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
                data{j,1}.combined_signal_gaus_zs_parsed=freqs_all_cell;
                data{j,1}.combined_electrodes=elec_cell;

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
    end
    fprintf('one participant done \n')
end