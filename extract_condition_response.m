function data_out=extract_condition_response(data,info,cond,stim,correct_response,large_file)
    trial_type=info.word_type;
    pos_right=find(strcmp(info.subject_response,'RIGHT'));
    pos_wrong=find(strcmp(info.subject_response,'WRONG'));
    pos_desired=sort([pos_right;pos_wrong]);
    trial_type=trial_type(pos_desired); %remove fixation trials from data
    data=data(pos_desired);
    if correct_response
        indices=[]; %add data indices where response matches whether probe is present
        for i=1:length(data)
            if data{i,1}.trial_probe_answer=='1' %probe is present
                if data{i,1}.subject_response=='RIGHT' %response=present
                    indices=[indices,i];
                end
            elseif data{i,1}.trial_probe_answer=='0' %probe not present
                if data{i,1}.subject_response=='WRONG' %response=not present
                    indices=[indices,i];
                end
            elseif data{i,1}.trial_probe_answer==data{i,1}.subject_response 
                indices=[indices,i]; %response same as accepted answer
            end
        end
        trial_type=trial_type(indices);
        data=data(indices); %only include correct trials in data             
    end
    cond_id=find(cellfun(@(x) x==cond,trial_type));
    data_cond=data(cond_id); %array of trials with only desired condition
    if stim(1:4)=='pret'
        if large_file
            hilb_zs_ave_cell=cellfun(@(x) cell2mat(transpose(x.signal_pre_trial_gaus_band_hilb_dec_zs_win)), data_cond,'uni',false);
        else
            hilb_zs_ave_cell=cellfun(@(x) cell2mat(transpose(x.signal_pre_trial_gaus_band_hilb_dec_zs)), data_cond,'uni',false);
        end
        stim_zs_ave_cell=arrayfun(@(x) hilb_zs_ave_cell{x},[1:size(hilb_zs_ave_cell,1)],'uni',false );
        stim_zs_ave_tensor=double(cell2mat(permute(stim_zs_ave_cell,[1,3,2])));
        data_out=stim_zs_ave_tensor;  
    else %stim not pretrial
        if large_file
            hilb_zs_ave_cell=cellfun(@(x) x.combined_win, data_cond,'uni',false);
        else
            hilb_zs_ave_cell=cellfun(@(x) x.combined_electrodes, data_cond,'uni',false);
        end
        stim_loc=cellfun(@(x) find(strcmp(x.stimuli_type,stim)), data_cond,'uni',false);
        stim_zs_ave_cell=arrayfun(@(x) hilb_zs_ave_cell{x}(stim_loc{x},:),[1:size(hilb_zs_ave_cell,1)],'uni',false );
        stim_zs_ave_cell=cellfun(@(x) cell2mat(reshape(x,1,[])),stim_zs_ave_cell,'uni',false );
        stim_zs_ave_tensor=double(cell2mat(permute(stim_zs_ave_cell,[1,3,2])));
        data_out=stim_zs_ave_tensor;
    end   
end