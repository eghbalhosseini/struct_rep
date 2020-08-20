%% extract dat files 
clear all;
close all;
home;
%% 
if 1
    fprintf('adding evlab ecog tools to path \n');
    addpath('~/MyCodes/evlab_ecog_tools/');
    addpath(genpath('~/MyCodes/evlab_ecog_tools/'));
end 
%% 
 subject_name='AMC044';
 experiment_name ='SWJN';
data_path='~/MyData/ecog-sentence/subjects_raw/';
save_path='~/MyData/struct_rep/crunched/';
sub_info_path='~/MyData/struct_rep/sub_operation_info/';
d= dir([data_path,sprintf('/%s/raw/ECOG*.dat',subject_name)]);
d_files=transpose(arrayfun(@(x) {strcat(d(x).folder,'/',d(x).name)}, 1:length(d)));
fprintf(' %d .dat files were found \n', length(d))
%
d_subj_op_info=dir(strcat(sub_info_path,'/',subject_name,'_operation_info.mat'));
d_info=arrayfun(@(x) {strcat(d_subj_op_info(x).folder,'/',d_subj_op_info(x).name)}, 1:length(d_subj_op_info));

subject_op_info=load(d_info{1},sprintf('%s_op_info',subject_name));
try subject_op_info=subject_op_info.(sprintf('%s_op_info',subject_name)); end 
if ~ subject_op_info.analyzed_by_user
    subject_op_info=subject_op_info.(strcat(subject_name,'_op'));
    subject_op_info=find_noise_free_electrodes(d_files,subject_op_info);
end 

%%
for i=1:length(d_files)
    fprintf('extracting %s \n',d_files{i});
    subject_op_info=load(d_info{1},sprintf('%s_op_info',subject_name));
    try subject_op_info=subject_op_info.(sprintf('%s_op_info',subject_name)); end 
    
    output=filter_channels_using_gaussian('datafile',d_files{i},'op_info',subject_op_info);
    subject_name=d(i).folder(strfind(d(i).folder,'AMC')+[0:5]);
    session_name=d(i).name(1:end-4);     
    % start with an empty strcuture for data and info 
    dat={};
    info=struct;
    pre_trial_time=0.45; % in sec 
    % step 1: find start and end of trials 
    info.sample_rate=output.parameters.SamplingRate.NumericValue;
    info.downsample_sampling_rate=output.downsamplingrate;
    info.gaus_filt_defs=output.gaus_filt_defs;
    % 
    info.pre_trial_samples=info.sample_rate*pre_trial_time;
    info.pre_trial_samples_downsample=info.downsample_sampling_rate*pre_trial_time;
    % 
    stimuli_squence=output.parameters.Sequence.NumericValue;
    trials_value=output.parameters.Stimuli.NumericValue;
    stimuli_value=output.parameters.Stimuli.Value;
    %
    stim_types={'S','W','N','J'};
    trials_indx=cell2mat(cellfun(@(x) strcmp(x,'TrialNumber'),output.parameters.Stimuli.RowLabels,'UniformOutput',false));
    caption_indx=cell2mat(cellfun(@(x) strcmp(x,'caption'),output.parameters.Stimuli.RowLabels,'UniformOutput',false));
    wordtype_indx=cell2mat(cellfun(@(x) strcmp(x,'Condition'),output.parameters.Stimuli.RowLabels,'UniformOutput',false)) | ...
        cell2mat(cellfun(@(x) strcmp(x,'WordType'),output.parameters.Stimuli.RowLabels,'UniformOutput',false));
    StimType_indx=cell2mat(cellfun(@(x) strcmp(x,'StimType'),output.parameters.Stimuli.RowLabels,'UniformOutput',false));
    ConditionName_indx=cell2mat(cellfun(@(x) strcmp(x,'ConditionName'),output.parameters.Stimuli.RowLabels,'UniformOutput',false))  
    IsRight_indx=cell2mat(cellfun(@(x) strcmp(x,'IsRight'),output.parameters.Stimuli.RowLabels,'UniformOutput',false)) | ...
        cell2mat(cellfun(@(x) strcmp(x,'IsProbeCorrect'),output.parameters.Stimuli.RowLabels,'UniformOutput',false));
    %
    trial_for_stimuli_seq=trials_value(trials_indx,:);
    trials=unique(trial_for_stimuli_seq);
  
    trial_seq_cell={};
    for ii=1:length(trials)
        trial_stimuli_sequence=find(trial_for_stimuli_seq==trials(ii));
        trial_instance_in_sequence=strfind(stimuli_squence',trial_stimuli_sequence);
        if length(trial_instance_in_sequence)==1
            trial_seq_cell{ii,1}=stimuli_squence(trial_instance_in_sequence+[0:length(trial_stimuli_sequence)-1]);
            trial_seq_cell{ii,2}=trials(ii);
        elseif isempty(trial_instance_in_sequence)
            fprintf('the stimuli for trial %d was not find in the parameter.sequence \n',trials(ii))
        else
            fprintf('more than on instance of trial found\n');
            keyboard; 
        end
    end
    % extracting data per trial for subject
    trial_reponse=[];
    % do a transpose 
    % backward compatibility
    high_gamma_idx=find(strcmp({output.signal_gaus_bands.band},'high_gamma'));
    signal_hilbert_downsample=transpose(output.signal_gaus_bands(high_gamma_idx).hilbert_dec);
    signal_hilbert_zs_downsample=transpose(output.signal_gaus_bands(high_gamma_idx).hilbert_dec_zs);

    for k=1:length(trial_seq_cell)
        trial_indx=trial_seq_cell{k};
        % find trial type 
        wordtype=trials_value(find(wordtype_indx),trial_for_stimuli_seq==trial_seq_cell{k,2});
        wordtype(isnan(wordtype))=[];
        if ~isempty(wordtype)
            info.word_type{k,1}=stim_types{unique(wordtype)};
        else
            info.word_type{k,1}='0';
        end 
        trial=struct;
        trial_index=[];
        
        trial_downsample_index=[];
        trial_string=[];
        trial_probe=[];
        trial_type=[];
        stimuli_range=[];
        stimuli_downsample_range=[];
        stimuli_type={};
        probe_result=[];
        stimuli_string={};
        signal_hilbert_downsample_parsed={};
        signal_hilbert_zs_downsample_parsed={};
        signal_gaus_band_hilb_dec_parsed={};
        signal_gaus_band_hilb_dec_zs_parsed={};
        signal_broadband_hilb_parsed={};
        % 
        signal_pre_trial_broadband_parsed={};
        signal_pre_trial_hilbert_downsample_parsed={};
        signal_pre_trial_hilbert_zs_downsample_parsed={};
        signal_pre_trial_hilbert_pca_downsample_parsed={};
        signal_pre_trial_hilbert_pca_zs_downsample_parsed={};
        
        signal_pre_trial_bandpass_envelope_parsed={};
        signal_pre_trial_bandpass_envelope_downsample_parsed={};
        
        fprintf('adding trial %d  \n',(k))
        for kk=1:length(trial_indx)
            stimulus_index=find(output.states.StimulusCode==trial_indx(kk));
            stimuli_downsample_index=find(output.states.StimulusCodeDownsample==trial_indx(kk));
            stimuli_type{kk,1}=stimuli_value{StimType_indx,trial_indx(kk)};
            if ~isempty(stimuli_value{IsRight_indx,trial_indx(kk)})
                probe_result=[probe_result,stimuli_value{IsRight_indx,trial_indx(kk)}];
            end 
            stimuli_string{kk,1}=stimuli_value{caption_indx,trial_indx(kk)};
            trial_index=[trial_index;stimulus_index];
            trial_downsample_index=[trial_downsample_index;stimuli_downsample_index];
            % 
            stimuli_range=[stimuli_range;[min(stimulus_index),max(stimulus_index)]];
            stimuli_downsample_range=[stimuli_downsample_range;[min(stimuli_downsample_index),max(stimuli_downsample_index)]];
            %
            
            signal_hilbert_downsample_parsed{kk,1}=signal_hilbert_downsample(:,stimuli_downsample_index);
            signal_hilbert_zs_downsample_parsed{kk,1}=signal_hilbert_zs_downsample(:,stimuli_downsample_index);
            % gaus bands 
            signal_gaus_band_hilb_dec_parsed(kk,:)=arrayfun(@(x) transpose(output.signal_gaus_bands(x).hilbert_dec(stimuli_downsample_index,:)),1:size(output.signal_gaus_bands,2),'uni',false);
            signal_gaus_band_hilb_dec_zs_parsed(kk,:)=arrayfun(@(x) transpose(output.signal_gaus_bands(x).hilbert_dec_zs(stimuli_downsample_index,:)),1:size(output.signal_gaus_bands,2),'uni',false);
            temp=cellfun(@(x) x(:,stimuli_downsample_index),output.signal_broad_bands.hilbert_dec,'uni',false)';
            signal_broadband_hilb_parsed(kk,:)=temp;
           
            if strfind(stimuli_value{StimType_indx,trial_indx(kk)},'word')
                trial_string=[trial_string,' ',stimuli_value{caption_indx,trial_indx(kk)}];
            end 
            if strfind(stimuli_value{StimType_indx,trial_indx(kk)},'probe')
                trial_probe=[trial_probe,' ',stimuli_value{caption_indx,trial_indx(kk)}];
            end
            trial_type=[trial_type,' ',stimuli_value{StimType_indx,trial_indx(kk)}];
        end 
        % add pre trial samples 
        %trial.signal_pre_trial_broadband=signal_broadband(:,stimuli_range(1)+[-info.pre_trial_samples:-1]);
        pre_trial_idx=stimuli_downsample_range(1)+[-info.pre_trial_samples_downsample:-1];
        trial.(strcat('signal','_pre_trial','_hilbert_downsample'))=signal_hilbert_downsample(:,pre_trial_idx);
        trial.(strcat('signal','_pre_trial','_hilbert_zs_downsample'))=signal_hilbert_zs_downsample(:,pre_trial_idx);
        trial.(strcat('signal_ave','_pre_trial','_hilbert_downsample'))=nanmean(signal_hilbert_downsample(:,pre_trial_idx),2);
        trial.(strcat('signal_ave','_pre_trial','_hilbert_zs_downsample'))=nanmean(signal_hilbert_zs_downsample(:,pre_trial_idx),2);
        trial.(strcat('signal','_pre_trial','_gaus_band_hilb_dec'))=arrayfun(@(x) transpose(output.signal_gaus_bands(x).hilbert_dec(pre_trial_idx,:)),1:size(output.signal_gaus_bands,2),'uni',false);
        trial.(strcat('signal','_pre_trial','_gaus_band_hilb_dec_zs'))=arrayfun(@(x) transpose(output.signal_gaus_bands(x).hilbert_dec_zs(pre_trial_idx,:)),1:size(output.signal_gaus_bands,2),'uni',false);
        trial.(strcat('signal','_pre_trial','_broadband_hilb_dec'))=cellfun(@(x) x(:,pre_trial_idx),output.signal_broad_bands.hilbert_dec,'uni',false)';
        % 
        
        trial.(strcat('signal','_hilbert_downsample_parsed'))=signal_hilbert_downsample_parsed;
        trial.(strcat('signal','_gaus_band_hilb_dec_parsed'))=signal_gaus_band_hilb_dec_parsed;
        trial.(strcat('signal','_gaus_band_hilb_dec_zs_parsed'))=signal_gaus_band_hilb_dec_zs_parsed;
        trial.(strcat('signal','_broadband_hilb_dec_zs_parsed'))=signal_broadband_hilb_parsed;
        trial.(strcat('signal','_hilbert_zs_downsample_parsed'))=signal_hilbert_zs_downsample_parsed;
        trial.(strcat('signal_ave','_hilbert_downsample_parsed'))=cellfun(@(x) nanmean(x,2),signal_hilbert_downsample_parsed,'UniformOutput',false);
        trial.(strcat('signal_ave','_hilbert_zs_downsample_parsed'))=cellfun(@(x) nanmean(x,2),signal_hilbert_zs_downsample_parsed,'UniformOutput',false);
        trial.(strcat('trial','_string'))=trial_string;
        trial.(strcat('trial','_probe_question'))=trial_probe;
        trial.(strcat('trial','_probe_answer'))=probe_result;
        trial.trial_onset_sample=stimuli_range(1);
        trial.trial_onset_sample_downsampled=stimuli_downsample_range(1);
        trial.keydown=output.states.KeyDown(trial_index);
        trial.keyup=output.states.KeyUp(trial_index);
        trial.isRight=output.states.IsRight(trial_index);
        trial.signal_range=stimuli_range-min(stimuli_range(:))+1;
        trial.signal_range_downsample=stimuli_downsample_range-min(stimuli_downsample_range(:))+1;
        trial.stimuli_type=stimuli_type;
        trial.stimuli_string=stimuli_string;
        % find subject response: 
        index_isright_start = trial_index(find(diff(double(output.states.IsRight(trial_index) > 0)) == 1)+1);
        index_isright_stop  = trial_index(find(diff(double(output.states.IsRight(trial_index) > 0)) == -1));
        buffer_before = info.sample_rate * 1; % 1 sec 
        buffer_after  = info.sample_rate * 2; % 2 sec
        KeyDown = unique(output.states.KeyDown((index_isright_start-buffer_before):(index_isright_stop+buffer_after)));
        KeyDown = intersect(KeyDown,[67,77,99,109]);
        if length(KeyDown) ~= 1                    % too many key's pressed or incorrect response
           TrialResponse = 'INCORRECT_KEY';
        elseif KeyDown == 67 || KeyDown == 99      % response is yes (1)
           TrialResponse = 'RIGHT'; 
        elseif KeyDown == 77 || KeyDown == 109     % response is no  (2) 
           TrialResponse = 'WRONG'; 
        else                                       % incorrect response 
           TrialResponse = 'INCORRECT_KEY';
        end
        % 
        trial.subject_response=TrialResponse;
        info.subject_response{k,1}=TrialResponse;
        info.probe_value{k,1}=probe_result;
        dat{k,1}=trial;
        if ~contains(trial_type,'word')
            info.trial_type{k,1}='fixation';
        else
            info.trial_type{k,1}='word';
        end
        
    end
    info.subject=subject_name;
    info.session_name=session_name;
    %
    
    info.random_stim_present=output.parameters.SequenceType.NumericValue;
    info.random_stim_present_comment=output.parameters.SequenceType.Comment;
    info.(strcat('signal','_gaus_band_hilb_dec_parsed_fields'))={output.signal_gaus_bands.band};
    info.(strcat('signal','_broad_band_hilb_dec_parsed_fields'))={output.signal_broad_bands.band};
    info.gaus_band_spec=output.gaus_filt_defs;
    info.datafile=output.datafile;
    info.op_info=output.op_info;
    info.decimation_factor=output.decimation_factor;
    
    %
    info.num_of_stim_rep=output.parameters.NumberOfSequences.NumericValue;
    info.num_of_stim_rep_comment=output.parameters.NumberOfSequences.Comment;
    %
    try
    info.common_refs=output.parameters.CommonReference.NumericValue;
    info.common_refs_comment=output.parameters.CommonReference.Comment;
    end 
    % 
    try
    info.common_gnd=output.parameters.CommonGround.NumericValue;
    info.common_gnd_comment=output.parameters.CommonGround.Comment;
    end 
    % 
    info.user_comment=output.parameters.UserComment.Value;
    % 
    info.audio_presentation=output.parameters.AudioSwitch.NumericValue;
    info.audio_presentation_comment=output.parameters.AudioSwitch.Comment;
    %
    %info.filter_type=output.parameters.filter_type;
    
    % 
    info.noisy_channels=output.op_info.channel_noise_across_all_sess;
    info.unselected_channels=output.op_info.unselected_channels;
    info.selected_channels=output.op_info.clean_channels;
    % 
    info.downsample_sampling_rate=output.downsamplingrate;
    info.broadband_defs=output.gaus_filt_defs;
    valid_channels=zeros(size(subject_op_info.transmit_chan));
    valid_channels(subject_op_info.clean_channels)=1;
    info.valid_channels=valid_channels;
    info.subj_op_info=subject_op_info;
    % 
    eval(strcat(subject_name,'_',session_name,'.data=dat')) ;
    eval(strcat(subject_name,'_',session_name,'.info=info'));
    %save(strcat(d(i).folder,'/',d(i).name),'data','info','-v7.3');
    save(strcat(save_path,subject_name,'_',experiment_name,'_',session_name,'_crunched_v3.mat'),strcat(subject_name,'_',session_name),'-v7.3');
    clearvars -except d_files i subject_name d_info d experiment_name data_path save_path sub_info_path
end

%% create a compressed version of the dataset
clear all
close all
experiment_name ='SWJN';
window_ms=90;% ms
if ispc
    % kirsi's computer
    data_path='C:\Users\kirsi\Documents\Git\UROP\struct_rep\data';
    analysis_path=strcat(data_path,'analysis\distributed_oscilatory_power\');
    
else
    % eghbal's computer
    data_path='~/MyData/struct_rep/crunched/';
    analysis_path=strcat(data_path,'analysis/distributed_oscilatory_power/');
end
%
%subject_id={'AMC026'};%,'AMC029','AMC031','AMC037','AMC038','AMC044'};
subject_id={'AMC029','AMC031','AMC037','AMC038','AMC044'};
for m=1:length(subject_id)
    d_data= dir(strcat(data_path,filesep,subject_id{m},'*_crunched_v3.mat'));
    d_data=arrayfun(@(x) strcat(d_data(x).folder,filesep,d_data(x).name),[1:length(d_data)]','uni',false); %change '/'
    fprintf(' %d .mat files were found \n', length(d_data));
    for k=1:length(d_data)
        subj=load(d_data{k});
        subj_id=fieldnames(subj);
        subj=subj.(subj_id{1});
        data=subj.data;
        info=subj.info;
        f_s=info.sample_rate;
        dc_ratio=info.decimation_factor;
        data_1={};
        window_len=floor(f_s*(window_ms/1e3)/dc_ratio);
        for kk=1:length(data)
            trial=data{kk};
            trial_1=struct;
            trial_fields=fieldnames(trial);
            cell_fields=find(structfun(@iscell,trial));
            
            % add the string stuff
            non_signal_fields=find(~contains(trial_fields,'signal'));
            trash_fields=find(contains(trial_fields,{'keydown';'keyup';'isRight'}));
            non_signal_fields=setdiff(non_signal_fields,trash_fields);
            for t=non_signal_fields',trial_1.(trial_fields{t})=trial.(trial_fields{t});end
            % add the signal ave stuff
            signal_ave_fields=find(contains(trial_fields,'signal_ave'));
            for t=signal_ave_fields',trial_1.(trial_fields{t})=trial.(trial_fields{t});end
            % signal pre trial stuff
            signal_pre_fields=find(contains(trial_fields,'signal_pre'));
            for t=signal_pre_fields'
                if iscell(trial.(trial_fields{t}))
                    trial_1.(trial_fields{t})=cellfun(@(x) mean(x,2),trial.(trial_fields{t}),'uni',false);
                    % smaller window:
                    signal_win=cellfun(@(x) x(:,1:window_len*floor(size(x,2)/window_len)),trial.(trial_fields{t}),'uni',false);
                    trial_1.(strcat(trial_fields{t},'_win'))=cellfun(@(y) cell2mat(...
                        cellfun(@(x) mean(x,2),mat2cell(y,[size(y,1)],ones(1,size(y,2)/window_len)*window_len), 'uni', false)),...
                        signal_win,'uni',false);
                else
                    trial_1.(trial_fields{t})=nanmean(trial.(trial_fields{t}),2);
                end
            end
            % add the signal stuff,
            signal_fields=find(contains(trial_fields,'signal'));
            signal_fields=setdiff(signal_fields,signal_ave_fields);
            signal_fields=setdiff(signal_fields,signal_pre_fields);
            % do averaging for signal in cells
            signal_cell_fields=intersect(cell_fields,signal_fields);
            % get trial_timewidth
            word_loc=contains(trial.stimuli_type,'word');
            for t=signal_cell_fields'
                stim_time=cellfun(@(x) size(x,2),trial.(trial_fields{t}));
                word_time=unique(stim_time(word_loc));
                trial_signal=trial.(trial_fields{t});
                trial_signal_for_ave=cellfun(@(x) x(:,1:min([size(x,2),word_time])),trial_signal,'uni',false);
                if word_loc
                    assert(unique(max(cell2mat(cellfun(@(x) size(x,2),trial_signal_for_ave,'uni',false))))==word_time,'averaging window is incorrect');
                end
                trial_1.(trial_fields{t})=cellfun(@(x) mean(x,2),trial_signal_for_ave,'uni',false);
                signal_win=cellfun(@(x) x(:,1:window_len*floor(size(x,2)/window_len)),trial.(trial_fields{t}),'uni',false);
                trial_1.(strcat(trial_fields{t},'_win'))=cellfun(@(y) cell2mat(...
                    cellfun(@(x) mean(x,2),mat2cell(y,[size(y,1)],ones(1,size(y,2)/window_len)*window_len), 'uni', false)),...
                    signal_win,'uni',false);
                
                
            end
            trial_1.ave_window_time=word_time;
            data_1{kk,1}=trial_1;
            fprintf('trial %d \n',kk)
        end
        eval(strcat(info.subject,'_',info.session_name,'.data=data_1')) ;
        eval(strcat(info.subject,'_',info.session_name,'.info=info'));
        %save(strcat(d(i).folder,'/',d(i).name),'data','info','-v7.3');
        
        save(strrep(d_data{k},'crunched_v3','crunched_v4_compressed'),strcat(info.subject,'_',info.session_name),'-v7.3');
        clear data_1 data subj;
        eval(sprintf('clear %s', [info.subject,'_',info.session_name]));
        fprintf('compressed %s. \n', d_data{k});
        fprintf('one out of %d .mat files done \n',length(d_data))
    end
    fprintf('one participant done \n')
end
