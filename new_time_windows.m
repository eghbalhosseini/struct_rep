function output=new_time_windows(combine_participants,correct,lang_resp,stim)
    data_path=%Put your data path here 
    subject_id={'AMC026','AMC029','AMC031','AMC037','AMC038','AMC044'};
    
    if combine_participants
        combine_elecs_all_sent_word=[];
        combine_elecs_all_wlist_word=[];
      
        combine_elecs_all_sent_probe=[];
        combine_elecs_all_wlist_probe=[];
    end
    
    for m=1:length(subject_id)
        d_data= dir(strcat(data_path,'\',subject_id{1,m},'*_crunched_v3.mat')); 
        d_data=arrayfun(@(x) strcat(d_data(x).folder,'\',d_data(x).name),[1:length(d_data)]','uni',false);
        fprintf('%d .mat files found',length(d_data));

        for k=1:length(d_data)
            subj=load(d_data{k});
            subj_id=fieldnames(subj);
            subj=subj.(subj_id{1});
            data=subj.data;
            info=subj.info;

            sent_window_word_tens=[];
            wlist_window_word_tens=[];

            sent_window_probe_tens=[];
            wlist_window_probe_tens=[];

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
            end

            if correct
                data_out=extract_condition_response(data,info,'S','word',true,true);
                sent_window_word_tens=cat(3,sent_window_word_tens,data_out);

                data_out=extract_condition_response(data,info,'W','word',true,true);
                wlist_window_word_tens=cat(3,wlist_window_word_tens,data_out);

                data_out=extract_condition_response(data,info,'S',stim,true,true);
                sent_window_probe_tens=cat(3,sent_window_probe_tens,data_out);

                data_out=extract_condition_response(data,info,'W',stim,true,true);
                wlist_window_probe_tens=cat(3,wlist_window_probe_tens,data_out);
            else
                data_out=extract_condition_response(data,info,'S','word',false,true);
                sent_window_word_tens=cat(3,sent_window_word_tens,data_out);

                data_out=extract_condition_response(data,info,'W','word',false,true);
                wlist_window_word_tens=cat(3,wlist_window_word_tens,data_out);

                data_out=extract_condition_response(data,info,'S',stim,false,true);
                sent_window_probe_tens=cat(3,sent_window_probe_tens,data_out);

                data_out=extract_condition_response(data,info,'W',stim,false,true);
                wlist_window_probe_tens=cat(3,wlist_window_probe_tens,data_out);
            end
        end
        
        %% Sort tensors according to probe positions
        %Create vector with all positions across participants for each condition
        sent_positions=[];
        wlist_positions=[];
    
        for k=1:length(d_data)
            subj=load(d_data{k});
            subj_id=fieldnames(subj);
            subj=subj.(subj_id{1});
            data=subj.data;
            info=subj.info;
            if correct
                temp_sent_pos=get_positions(info,data,'S',true);
                sent_positions=cat(1, sent_positions, temp_sent_pos);

                temp_wlist_pos=get_positions(info,data,'W',true);
                wlist_positions=cat(1, wlist_positions, temp_wlist_pos);
            else
                temp_sent_pos=get_positions(info,data,'S',false);
                sent_positions=cat(1, sent_positions, temp_sent_pos);

                temp_wlist_pos=get_positions(info,data,'W',false);
                wlist_positions=cat(1, wlist_positions, temp_wlist_pos);
            end
        end

        %Sort pos vecs ascending order, sort tensors the same way
        [sent_positions, index]=sort(sent_positions);
        sent_window_word_tens=sent_window_word_tens(:,:,index);
        sent_window_probe_tens=sent_window_probe_tens(:,:,index);

        [wlist_positions, index]=sort(wlist_positions);
        wlist_window_word_tens=wlist_window_word_tens(:,:,index);
        wlist_window_probe_tens=wlist_window_probe_tens(:,:,index);

        %% Average trials at each probe position
        % Find indices where probe position changes
        sent_changes=diff(sent_positions);
        sent_change_indices=find(ismember(sent_changes,1));
        sent_change_indices=sent_change_indices+1;

        wlist_changes=diff(wlist_positions);
        wlist_change_indices=find(ismember(wlist_changes,1));
        wlist_change_indices=wlist_change_indices+1;

        %Take average of trials at each probe position
        sent_window_word_tens=probe_pos_ave_trials(sent_change_indices, sent_window_word_tens);
        sent_window_probe_tens=probe_pos_ave_trials(sent_change_indices, sent_window_probe_tens); 

        wlist_window_word_tens=probe_pos_ave_trials(wlist_change_indices, wlist_window_word_tens);
        wlist_window_probe_tens=probe_pos_ave_trials(wlist_change_indices, wlist_window_probe_tens);
        
        %% Lang Responsive
        if lang_resp
            sent_window_word_tens=sent_window_word_tens.*repmat(info.sig_and_pos_chans_combine_elecs,1,40);
            wlist_window_word_tens=wlist_window_word_tens.*repmat(info.sig_and_pos_chans_combine_elecs,1,40);

            sent_window_probe_tens=sent_window_probe_tens.*repmat(info.sig_and_pos_chans_combine_elecs,1,5);
            wlist_window_probe_tens=wlist_window_probe_tens.*repmat(info.sig_and_pos_chans_combine_elecs,1,5);
           
        else  %only use valid channels
            scale_matrix=zeros(5*length(info.valid_channels),1);
            for i=1:length(info.valid_channels)
                temp=repmat(info.valid_channels(i),5,1);
                scale_matrix(1+5*(i-1):5*i)=temp;
            end
            sent_window_word_tens=sent_window_word_tens.*repmat(scale_matrix,1,40);
            wlist_window_word_tens=wlist_window_word_tens.*repmat(scale_matrix,1,40);

            sent_window_probe_tens=sent_window_probe_tens.*repmat(scale_matrix,1,5);
            wlist_window_probe_tens=wlist_window_probe_tens.*repmat(scale_matrix,1,5);
        end
        
        if combine_participants
            combine_elecs_all_sent_word=cat(1,combine_elecs_all_sent_word, sent_window_word_tens);
            combine_elecs_all_wlist_word=cat(1,combine_elecs_all_wlist_word, wlist_window_word_tens);

            combine_elecs_all_sent_probe=cat(1,combine_elecs_all_sent_probe, sent_probe_combined_elecs);
            combine_elecs_all_wlist_probe=cat(1,combine_elecs_all_wlist_probe, wlist_probe_combined_elecs);
     
            break %from m loop -> only need one figure
        else
            %not combined subs -> make figures for separate subs
        end
    end
    if combine_participants
        %% Compute cosine distance
        %sentence
        word_tensor=combine_elecs_all_sent_word;
        probe_tensor=combine_elecs_all_sent_probe;
        sent_angles=angle_new_windows(word_tensor,probe_tensor);

        %wordlist
        word_tensor=combine_elecs_all_wlist_word;
        probe_tensor=combine_elecs_all_wlist_probe;
        wlist_angles=angle_new_windows(word_tensor,probe_tensor);

        %% Generate figure
        strings={'S','W'};
        angs={sent_angles, wlist_angles};
        for h=1:length(angs)
            figure;
            for i=1:length(angs{1,h})
                for j=1:length(angs{1,h}{1,i})
                    subplot(length(angs{1,h}),length(angs{1,h}{1,i}),j*i+(7-(j-1))*(i-1));
                    imagesc(angs{1,h}{1,i}{j,1});
                end
            end    
        end
 
        starter=%your data path here (specify probe type w/ stim input variabe)
        if ~lang_resp & ~correct
            figname=starter;
        elseif ~lang_resp & correct
            figname=strcat(starter,'_correct');
        elseif lang_resp & ~correct
            figname=strcat(starter,'_lang_resp');
        else
            figname=strcat(starter,'_correct_lang_resp');
        end
        savefig(figname);
    end
    output=figname;
end
            
            
            
            
        
        
            
            
            