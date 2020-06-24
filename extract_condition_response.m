function data_out=extract_condition_response(data,info,cond,stim)
    trial_type=info.word_type;
    cond_id=find(cellfun(@(x) x==cond,trial_type));
    data_cond=data(cond_id); %array of trials with only desired condition
    stim_loc=cellfun(@(x) find(strcmp(x.stimuli_type,stim)), data_cond,'uni',false);
    %old files -> x.signal_ave_hilbert_zs_downsample_parsed
    %new files -> x.signal_gaus_band_hilb_dec_zs_parsed
    hilb_zs_ave_cell=cellfun(@(x) x.signal_gaus_band_hilb_dec_zs_parsed, data_cond,'uni',false);
    stim_zs_ave_cell=arrayfun(@(x) hilb_zs_ave_cell{x}(stim_loc{x},:),[1:size(hilb_zs_ave_cell,1)],'uni',false );
    % reshape stim to correct form if it is not
    stim_zs_ave_cell=cellfun(@(x) cell2mat(reshape(x,1,[])),stim_zs_ave_cell,'uni',false );
    % tensor format (elec*stim(words)*trial)
    stim_zs_ave_tensor=double(cell2mat(permute(stim_zs_ave_cell,[1,3,2])));
    data_out=stim_zs_ave_tensor;  
end
